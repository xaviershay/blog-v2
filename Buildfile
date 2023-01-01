$LOAD_PATH.unshift File.expand_path("./src/ruby", File.dirname(__FILE__))

require 'build_plan'

require 'actions/book'
require 'actions/book_index'

require 'actions/compile_index_metadata'

DIGEST_FILE = File.expand_path(".digests.json", File.dirname(__FILE__))

BOOK_FILES = Dir["data/books/*.md"]

build_plan = BuildPlan.new(digest_file: DIGEST_FILE)
BuildPlan.logger.level = Logger::INFO

build_plan.load do
  begin
    builder = Actions::Book.new

    BOOK_METADATA_FILES = BOOK_FILES.map do |input|
      metadata = "out/metadata/books/#{File.basename(input)}.yml"

      file metadata => [File.dirname(metadata), input] do
        builder.markdown_to_metadata(input, metadata)
      end

      metadata
    end

    file 'out/metadata/book_index.yml' => [
      'out/metadata/books',
      'out/metadata/index.yml',
    ] + BOOK_METADATA_FILES do
      compile_book_index_metadata(
        BOOK_METADATA_FILES,
        "out/metadata/index.yml",
        "out/metadata/book_index.yml"
      )
    end
  end
end

DIRS = build_plan.tasks.values
  .select {|x| x.is_a?(BuildPlan::Target::IntermediaryFile) }
  .map {|x| File.dirname(x.target) }
  .uniq

build_plan.load do
  DIRS.each do |d|
    directory d
  end
end

build_plan.build "out/metadata/book_index.yml"

build_plan.save_digests!(DIGEST_FILE)
