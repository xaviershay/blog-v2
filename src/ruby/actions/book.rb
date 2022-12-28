require 'support/kramdown'
require 'support/builder'

require 'support/load_markdown_from_file'

require 'kramdown/parser/kramdown'

class Actions::Book < Builder
  def load_markdown(input)
    load_markdown_from_file2(input)
  end

  def markdown_to_metadata(input, output)
    metadata, _ = *load_markdown(input)

    File.write(output, metadata.to_yaml)
  end

  def markdown_to_html_fragment(input, output)
    _, data = load_markdown(input)

    doc = Kramdown::Document.new(data, parse_block_html: true)

    html = doc.to_book_html

    File.write(output, html)
  end

  def compile_erb(template, metadata, fragment, output)
    fragment = File.read(fragment)
    metadata = YAML.load_file(metadata)

    @book = hash_to_ostruct(metadata).extend(BookMethods)
    @book.body_html = fragment

    erb = load_template(template)

    html = erb.result(binding)

    write_gzip(output, html)
  end

  module BookMethods
    def url
      "/books/#{slug}.html"
    end

    def date
      DateTime.parse(finished_at)
    rescue
      raise "No finished_at, maybe using outside of index context?"
    end

    def updated_at
      Date.parse(reads.flat_map(&:finished_at).compact.max)
    end

    def summary
      stars
    end

    def stars
      rating.times.map {|_| "★" }.join +
        (5 - rating).times.map {|_| "☆" }.join
    end
  end
end
