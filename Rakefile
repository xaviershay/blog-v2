require 'digest/md5'
require 'yaml'
require 'zlib'

$LOAD_PATH.unshift "src/ruby"

require 'support/multifile'

require 'actions/markdown_to_metadata'
require 'actions/markdown_to_html_fragment'

require 'actions/compile_index_metadata'

require 'actions/book'
require 'actions/book_index'
require 'actions/compile_post'
require 'actions/compile_index'
require 'actions/compile_atom'

HOST = ENV.fetch("HOST", "https://blog.xaviershay.com")

STATIC_FILES = Dir["src/static/**/*.{js,css}"]
POST_FILES = Dir["data/posts/*.md"]
BOOK_FILES = Dir["data/books/*.md"]
FRAGMENT_FILES = POST_FILES.map do |x|
  "out/html/posts/#{File.basename(x, ".md").split('-', 4).drop(3).first}.html"
end
BOOK_FRAGMENT_FILES = BOOK_FILES.map do |x|
  "out/html/books/#{File.basename(x, ".md")}.html"
end

directory 'out/site/articles'
directory 'out/site/css'
directory 'out/site/js'
directory 'out/site/books'
directory 'out/metadata/posts'
directory 'out/metadata/books'
directory 'out/html/posts'
directory 'out/html/books'

site_files = []
site_files += STATIC_FILES.map do |file|
  target = File.join("out/site", file["src/static".length..-1])

  file target => [File.dirname(target), file] do
    contents = File.read(file)
    Zlib::GzipWriter.open(target) {|f| f.write(contents) }
  end

  target
end

POST_METADATA_FILES = POST_FILES.map do |file|
  "out/metadata/posts/#{File.basename(file)}.yml"
end

BOOK_METADATA_FILES = BOOK_FILES.map do |file|
  "out/metadata/books/#{File.basename(file)}.yml"
end

site_files += POST_FILES.map do |file|
  name = File.basename(file, ".md").split('-', 4).drop(3).first
  out = "out/site/articles/#{name}.html"
  metadata = "out/metadata/posts/#{File.basename(file)}.yml"
  fragment = "out/html/posts/#{name}.html"
  template = "src/erb/post.html.erb"

  file metadata => [File.dirname(metadata), file] do
    markdown_to_metadata(file, metadata)
  end

  file fragment => [File.dirname(fragment), file, template, 'out/metadata/book_index.yml'] do
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

site_files += BOOK_FILES.map do |file|
  name = File.basename(file, ".md")
  out = "out/site/books/#{name}.html"
  metadata = "out/metadata/books/#{File.basename(file)}.yml"
  fragment = "out/html/books/#{name}.html"
  template = "src/erb/book.html.erb"

  builder = Actions::Book.new

  file metadata => [File.dirname(metadata), file] do
    builder.markdown_to_metadata(file, metadata)
  end

  file fragment => [File.dirname(fragment), file] do
    builder.markdown_to_html_fragment(file, fragment)
  end

  file out => [
    metadata,
    fragment,
    template,
    File.dirname(out)
  ] do
    builder.compile_erb(template, metadata, fragment, out)
  end

  out
end

multifile 'out/metadata/index.yml' => [
  'out/metadata/posts'
] + POST_METADATA_FILES do
  compile_index_metadata(POST_METADATA_FILES, "out/metadata/index.yml")
end

begin
  builder = Actions::BookIndex.new
  multifile 'out/metadata/book_index.yml' => [
    'out/metadata/books'
  ] + BOOK_METADATA_FILES do
    compile_book_index_metadata(BOOK_METADATA_FILES, "out/metadata/book_index.yml")
  end

  file 'out/site/books/index.html' => [
    'out/metadata/book_index.yml',
    'src/erb/book_index.html.erb',
    'out/site/books'
  ] do
    builder.compile_erb(
      'src/erb/book_index.html.erb',
      'out/metadata/book_index.yml',
      'out/site/books/index.html'
    )
  end
  site_files << "out/site/books/index.html"

  file 'out/site/books/feed.xml' => [
    'src/erb/feed.xml.erb',
    'out/site/books',
    'out/metadata/book_index.yml'
  ] + BOOK_FRAGMENT_FILES do
    builder.compile_atom(
      'src/erb/feed.xml.erb',
      'out/metadata/book_index.yml',
      'out/html/books',
      'out/site/books/feed.xml'
    )
  end
  site_files << 'out/site/books/feed.xml'
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
task :build => ['out/site/index.html', 'out/site/feed.xml'] + site_files do
  # Just do this everytime, it's quick and not worth replicating rsync
  # functionality inside this file.
  sh "rsync -a data/images out/site/"
end

desc "Remove all generated files"
task :clean do
  rm_rf "out"
  rm_rf "tmp"
end

task default: :build
