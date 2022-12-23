require 'digest/md5'
require 'yaml'

$LOAD_PATH.unshift "src/ruby"

require 'support/multifile'

require 'actions/markdown_to_metadata'
require 'actions/markdown_to_html_fragment'

require 'actions/compile_index_metadata'

require 'actions/compile_post'
require 'actions/compile_index'
require 'actions/compile_atom'

HOST = ENV.fetch("HOST", "https://blog.xaviershay.com")

POST_FILES = Dir["data/posts/*.md"]
FRAGMENT_FILES = POST_FILES.map do |x|
  "out/html/posts/#{File.basename(x, ".md").split('-', 4).drop(3).first}.html"
end

directory 'out/site/articles'
directory 'out/metadata/posts'
directory 'out/html/posts'

POST_METADATA_FILES = POST_FILES.map do |file|
  name = File.basename(file, ".md").split('-', 4).drop(3).first
  "out/metadata/posts/#{File.basename(file)}.yml"
end

OUT_FILES = POST_FILES.map do |file|
  name = File.basename(file, ".md").split('-', 4).drop(3).first
  out = "out/site/articles/#{name}.html"
  metadata = "out/metadata/posts/#{File.basename(file)}.yml"
  fragment = "out/html/posts/#{name}.html"
  template = "src/erb/post.html.erb"

  file metadata => [File.dirname(metadata), file] do
    markdown_to_metadata(file, metadata)
  end

  file fragment => [File.dirname(fragment), file, template] do
    markdown_to_html_fragment(file, fragment)
  end

  # Technically this should depend on index metadata as well for changes to
  # site metadata (such as for relevant posts) but since Rake is purely mtime
  # based, and our metadata is mixed in with content, this would trigger a
  # rebuild of everything for any source change even if metadata doesn't
  # change.
  #
  # Unlikely to be an issue in practice since we'll do a clean build before
  # deploy anyway.
  file out => [
    file,
    metadata,
    fragment,
    template,
    File.dirname(out)
  ] do
    compile_post(fragment, metadata, out)
  end
  out
end

multifile 'out/metadata/index.yml' => [
  'out/metadata/posts'
] + POST_METADATA_FILES do
  compile_index_metadata(POST_METADATA_FILES, "out/metadata/index.yml")
end

file 'out/site/index.html' => [
  'out/metadata/index.yml',
  'src/erb/index.html.erb',
  'out/site'
] do
  compile_index('out/metadata/index.yml', 'out/site/index.html')
end

file 'out/site/feed.xml' => [
  'src/erb/feed.xml.erb',
  'out/site',
  'out/metadata/index.yml'
] + FRAGMENT_FILES do
  compile_atom("out/site/feed.xml")
end

desc "Compile all files"
task :build => ['out/site/index.html', 'out/site/feed.xml'] + OUT_FILES do
  # Just do this everytime, it's quick and not worth replicating rsync
  # functionality inside this file.
  sh "rsync -a data/images out/site/"
  sh "rsync -a src/static/ out/site/"
end

desc "Remove all generated files"
task :clean do
  rm_rf "out"
  rm_rf "tmp"
end

task default: :build
