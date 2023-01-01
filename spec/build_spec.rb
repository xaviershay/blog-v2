require 'rspec'
require 'tmpdir'

$LOAD_PATH.unshift File.expand_path("../src/ruby", File.dirname(__FILE__))

require 'build_plan'

RSpec.describe BuildPlan do
  around(:each) do |example|
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        example.run
      end
    end
  end

  before :each do
    BuildPlan.logger = Logger.new("/dev/null")
  end

  let(:builder) { BuildPlan.new }

  def unchanging_file(path, contents)
    builder.register_file(path, Digest::MD5.hexdigest(contents))
    File.write(path, contents)
  end

  def changing_file(path, contents, new_contents)
    builder.register_file(path, Digest::MD5.hexdigest(contents))
    File.write(path, new_contents)
  end


  it 'does not build anything when dependencies have not changed' do
    unchanging_file "source.txt", "hello"
    unchanging_file "target.txt", "hello"

    run = false
    builder.load do
      file "target.txt" => "source.txt" do
        run = true
      end
    end
    builder.build "target.txt"

    expect(run).to eq(false)
  end

  describe 'builds when dependencies have changed' do
    example 'single dependency' do
      changing_file "source.txt", "hello", "goodbye"
      unchanging_file "target.txt", "hello"

      run = false
      builder.load do
        file "target.txt" => "source.txt" do
          run = true
        end
      end
      builder.build "target.txt"

      expect(run).to eq(true)
    end

    example 'multiple dependencies one changed' do
      unchanging_file "source1.txt", "hello"
      changing_file "source2.txt", "hello", "goodbye"
      unchanging_file "target.txt", "hello"

      run = false
      builder.load do
        file "target.txt" => %w(source1.txt source2.txt) do
          run = true
        end
      end
      builder.build "target.txt"

      expect(run).to eq(true)
    end
  end

  it 'builds intermediary file if file does not exist' do
    unchanging_file "source.txt", "hello"

    run = false
    builder.load do
      file "target.txt" => "source.txt" do
        run = true
      end
    end
    builder.build "target.txt"

    expect(run).to eq(true)
  end

  it 'only builds tasks once' do
    changing_file "source.txt", "hello", "goodbye"

    run = 0
    builder.load do
      file "intermediary.txt" => "source.txt" do
        run += 1
      end

      file "target1.txt" => "intermediary.txt" do
      end

      file "target2.txt" => "intermediary.txt" do
      end
    end
    builder.build "target1.txt", "target2.txt"

    expect(run).to eq(1)
  end

  it 'can build directories' do
    builder.load do
      directory "out"
    end
    builder.build "out"

    expect(Dir.exists?("out")).to eq(true)
  end

  it 'does not generate file again on subsequent run' do
    digest_file = ".digests.json"
    changing_file "source.txt", "hello", "goodbye"
    unchanging_file "target.txt", "hello"

    run = 0
    builder.load do
      file "target.txt" => "source.txt" do
        FileUtils.cp("source.txt", "target.txt")
        run += 1
      end
    end
    builder.build "target.txt"
    builder.save_digests!(digest_file)

    builder = BuildPlan.new(digest_file: digest_file)
    builder.load do
      file "target.txt" => "source.txt" do
        FileUtils.cp("source.txt", "target.txt")
        run += 1
      end
    end
    builder.build "target.txt"

    expect(run).to eq(1)
  end
end

