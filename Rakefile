require 'digest/md5'
require 'yaml'

require_relative "./src/ruby/generate_index_metadata"
require_relative "./src/ruby/generate_post_metadata"
require_relative "./src/ruby/convert_post_to_html"

post_files = Dir["data/posts/*.md"]

# https://github.com/mattmassicotte/rake-multifile
module RakeMultifile
  class MultiFileTask < Rake::FileTask
    private
    def invoke_prerequisites(task_args, invocation_chain)
      invoke_prerequisites_concurrently(task_args, invocation_chain)
    end
  end
end

def multifile(*args, &block)
  RakeMultifile::MultiFileTask.define_task(*args, &block)
end

directory 'out/site/articles'
directory 'out/metadata/posts'

post_metadata_files = post_files.map do |file|
  name = File.basename(file, ".md").split('-', 4).drop(3).first
  "out/metadata/posts/#{File.basename(file)}.yml"
end

multifile 'out/metadata/index.yml' =>
            ['out/metadata/posts'] + post_metadata_files do
  generate_index_metadata(post_metadata_files)
end

out_files = post_files.map do |file|
  name = File.basename(file, ".md").split('-', 4).drop(3).first
  out = "out/site/articles/#{name}.html"
  metadata = "out/metadata/posts/#{File.basename(file)}.yml"
  template = "src/template.html"

  file metadata => [File.dirname(metadata), file] do
    generate_post_metadata(file)
  end

  file out => [
    file,
    metadata,
    template,
    "src/header.html",
    "src/footer.html",
    File.dirname(out)
  ] do
    convert_post_to_html(file)
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
  sh "rsync -a src/static/ out/site/"
end

desc "Remove all generated files"
task :clean do
  rm_rf "out"
end

task default: :build
