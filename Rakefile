post_files = Dir["data/posts/*.md"]

directory 'out/site/articles'
directory 'out/metadata/posts'

file 'out/metadata/index.yml' => ['out/metadata/posts'] + post_files do
  ruby "src/ruby/generate_index_metadata.rb"
end

out_files = post_files.map do |file|
  name = File.basename(file, ".md").split('-', 4).drop(3).first
  out = "out/site/articles/#{name}.html"
  metadata = "out/metadata/posts/#{File.basename(file)}.yml"
  template = "src/template.html"

  file metadata => ['out/metadata/index.yml']

  file out => [ metadata , template, File.dirname(out) ] do

    cmd = <<-EOS.gsub(/\n|\s+/, " ")
      pandoc
        --template #{template}
        --metadata-file=#{metadata}
        #{file}
        | gzip > #{out}
    EOS
    sh cmd
  end
  out
end

file 'out/site/index.html' => ['out/metadata/index.yml', 'src/index.html', 'out/site'] do
  cmd = <<-EOS.gsub(/\n|\s+/, " ")
      echo "" |
      pandoc
        --template src/index.html
        --metadata-file=out/metadata/index.yml
        | gzip > out/site/index.html
  EOS

  sh cmd
end

desc "Compile all files"
multitask :build => ['out/site/index.html'] + out_files do
  # Just do this everytime, it's quick and not worth replicating rsync
  # functionality inside this file.
  sh "rsync -a data/images out/site/"
end

desc "Remove all generated files"
task :clean do
  rm_rf "out"
end

task default: :build
