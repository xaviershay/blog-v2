$LOAD_PATH.unshift File.expand_path("./src/ruby", File.dirname(__FILE__))

require 'build_plan'

require 'actions/book'

DIGEST_FILE = File.expand_path(".digests.json", File.dirname(__FILE__))

BOOK_FILES = Dir["data/books/*.md"]
BOOK_METADATA_FILES = BOOK_FILES.map do |file|
  "out/metadata/books/#{File.basename(file)}.yml"
end

book_metadata_files = []

build_plan = BuildPlan.new(digest_file: DIGEST_FILE)

build_plan.load do
  begin
    builder = Actions::Book.new

    BOOK_FILES.each do |input|
      book_metadata_files <<
        (metadata = "out/metadata/books/#{File.basename(input)}.yml")

      file metadata => [File.dirname(metadata), input] do
        builder.markdown_to_metadata(input, metadata)
      end
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

build_plan.build "out/metadata/books/getting-together.md.yml"

build_plan.save_digests!(DIGEST_FILE)
