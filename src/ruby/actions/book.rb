require 'kramdown'
require 'erb'
require 'yaml'
require 'zlib'

require 'support/load_markdown_from_file'
require 'support/hash_to_ostruct'

module Actions; end
class Actions::Book
  def initialize
    @templates = {}
  end

  def load_markdown(input)
    load_markdown_from_file2(input)
  end

  def markdown_to_metadata(input, output)
    metadata, _ = *load_markdown(input)

    File.write(output, metadata.to_yaml)
  end

  def markdown_to_html_fragment(input, output)
    _, data = load_markdown(input)

    doc = Kramdown::Document.new(data)

    html = doc.to_html

    File.write(output, html)
  end

  def compile_erb(template, metadata, fragment, output)
    fragment = File.read(fragment)
    metadata = YAML.load_file(metadata)

    @book = hash_to_ostruct(metadata).extend(BookMethods)
    @book.body_html = fragment

    erb = load_template(template)

    html = erb.result(binding)

    Zlib::GzipWriter.open(output) do |f|
      f.write(html)
    end
  end

  module BookMethods
    def updated_at
      Date.parse(reads.flat_map(&:finished_at).compact.max)
    end

    def cover_id
      cover || id
    end
  end

  protected

  def load_template(file)
    @templates[file] ||= ERB.new(File.read(file))
  end
end
