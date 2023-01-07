$s = Process.clock_gettime(Process::CLOCK_MONOTONIC)

$LOAD_PATH.unshift File.expand_path("./src/ruby", File.dirname(__FILE__))

require 'build_plan'

require 'actions/book'
require 'actions/post'
require 'actions/book_index'

require 'actions/compile_index'
require 'actions/compile_index_metadata'
require 'actions/compile_atom'

HOST = ENV.fetch("HOST", "https://blog.xaviershay.com")

DIGEST_FILE = File.expand_path(".digests.json", File.dirname(__FILE__))

SRC_FILES = Dir["src/ruby/**/*.rb"]
STATIC_FILES = Dir["src/static/**/*.{js,css}"]
POST_FILES = Dir["data/posts/*.md"]
BOOK_FILES = Dir["data/books/*.md"]

def gfile(opts, &block)
  # opts[opts.keys.first] += SRC_FILES
  file(opts, &block)
end

post_metadata_files = []
post_fragment_files = []

book_metadata_files = []
book_fragment_files = []

build_plan = BuildPlan.new(digest_file: DIGEST_FILE)
BuildPlan.logger.level = Logger::INFO

site_files = []

build_plan.load do
  STATIC_FILES.each do |file|
    target = File.join("out/site", file["src/static".length..-1])

    gfile target => [File.dirname(target), file] do
      contents = File.read(file)
      Zlib::GzipWriter.open(target) {|f| f.write(contents) }
    end
  end

  Actions::Post.new.tap do |builder|
    POST_FILES.map do |file|
      name = File.basename(file, ".md").split('-', 4).drop(3).first
      out = "out/site/articles/#{name}.html"
      post_metadata_files <<
        (metadata = "out/metadata/posts/#{File.basename(file)}.yml")
      post_fragment_files <<
        (fragment = "out/html/posts/#{name}.html")
      template = "src/erb/post.html.erb"


      grouped_file 'Post Metadata', metadata => [
        File.dirname(metadata),
        file
      ] do
        builder.markdown_to_metadata(file, metadata)
      end

      grouped_file "Post Fragments", fragment => [
        File.dirname(fragment),
        file,
        template,
        'out/metadata/book_index.yml'
      ] do
        builder.markdown_to_html_fragment(file, fragment)
      end

      grouped_file "Post Pages", out => [
        file,
        metadata,
        fragment,
        template,
        'out/metadata/index.yml',      # Archive cross links
        'out/metadata/book_index.yml', # Reading graphs
        File.dirname(out)
      ] do
        builder.compile_erb(template, fragment, metadata, out)
      end
    end
  end

  begin
    gfile 'out/metadata/index.yml' => [
      'out/metadata/posts'
    ] + post_metadata_files do
      compile_index_metadata(post_metadata_files, "out/metadata/index.yml")
    end

    gfile 'out/site/index.html' => [
      'out/metadata/index.yml',
      'src/erb/index.html.erb',
      'out/site'
    ] do
      compile_index('out/metadata/index.yml', 'out/site/index.html')
    end

    gfile 'out/site/feed.xml' => [
      'src/erb/feed.xml.erb',
      'out/site',
      'out/metadata/index.yml'
    ] + post_fragment_files do
      compile_atom("out/site/feed.xml")
    end
  end

  Actions::Book.new.tap do |builder|
    BOOK_FILES.each do |input|
      name = File.basename(input, ".md")
      book_metadata_files <<
        (metadata = "out/metadata/books/#{File.basename(input)}.yml")
      book_fragment_files <<
        (fragment = "out/html/books/#{name}.html")
      template = "src/erb/book.html.erb"
      out = "out/site/books/#{name}.html"

      grouped_file "Book Metadata", metadata => [File.dirname(metadata), input] do
        builder.markdown_to_metadata(input, metadata)
      end

      grouped_file "Book Fragments", fragment => [File.dirname(fragment), input] do
        builder.markdown_to_html_fragment(input, fragment)
      end

      grouped_file "Book Pages", out => [
        metadata,
        fragment,
        template,
        File.dirname(out)
      ] do
        builder.compile_erb(template, metadata, fragment, out)
      end
    end
  end

  Actions::BookIndex.new.tap do |builder|
    gfile 'out/metadata/book_index.yml' => [
      'out/metadata/books',
      'out/metadata/index.yml',
    ] + book_metadata_files do
      compile_book_index_metadata(
        book_metadata_files,
        "out/metadata/index.yml",
        "out/metadata/book_index.yml"
      )
    end

    gfile 'out/site/books/index.html' => [
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

    gfile 'out/site/books/feed.xml' => [
      'src/erb/feed.xml.erb',
      'out/site/books',
      'out/metadata/book_index.yml'
    ] + book_fragment_files do
      builder.compile_atom(
        'src/erb/feed.xml.erb',
        'out/metadata/book_index.yml',
        'out/html/books',
        'out/site/books/feed.xml'
      )
    end
  end
end

SITE_FILES = build_plan.tasks.keys.select {|x| x.start_with?("out/site") }
DIRS = build_plan.tasks.values
  .select {|x| x.is_a?(BuildPlan::Target::IntermediaryFile) }
  .map {|x| File.dirname(x.target) }
  .uniq

build_plan.load do
  DIRS.each do |d|
    directory d
  end

  task "build" => SITE_FILES do
    # Just do this everytime, it's quick and not worth replicating rsync
    # functionality inside this file.
    `rsync -a data/images out/site/`
  end
end

build_plan.build "build"


build_plan.save_digests!(DIGEST_FILE)
