require 'rspec'
require 'set'
require 'tmpdir'
require 'digest/md5'

require 'pp'

RSpec.describe 'builder' do
  around(:each) do |example|
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        example.run
      end
    end
  end

  let(:builder) { Builder.new }

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
    unchanging_file "source1.txt", "hello"

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
    unchanging_file "source1.txt", "hello"

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
end

class Builder
  module Target
    class Base
      attr_reader :target, :deps

      def initialize(target, deps)
        @target = target
        @deps = deps
      end

      def walk(tasks, forward, backward, parent)
        deps.each do |dep|
          tasks.fetch(dep).walk(tasks, forward, backward, self)
          forward[target] << dep
        end

        backward[target] << parent.target if parent
      end
    end

    class IntermediaryFile < Base
      def id
        target
      end
    end

    class SourceFile < Base
      attr_reader :target

      def initialize(target)
        super(target, [])
      end

      def id
        target
      end
    end
  end

  def initialize
    @digests = {}
    @tasks = {}
  end

  def register_file(path, digest)
    digests[path] = digest
  end

  def load(&block)
    instance_exec(&block)
  end

  def build(*targets)
    forward = Hash.new {|h, k| h[k] = Set.new }
    backward = Hash.new {|h, k| h[k] = Set.new }

    targets.each do |target|
      tasks.fetch(target).walk(tasks, forward, backward, nil)
    end

    # TODO: Build loop
  end

  def file(opts)
    opts.each do |target, deps|
      deps = [*deps]
      deps.each do |dep|
        # Generate default source file targets if target hasn't been defined
        # yet.  Defining it explicitly later on will override this default.
        task = Target::SourceFile.new(dep)
        tasks[task.id] ||= task
      end
      task = Target::IntermediaryFile.new(target, deps)
      tasks[task.id] = task
    end
  end

  attr_reader :digests, :tasks
end
