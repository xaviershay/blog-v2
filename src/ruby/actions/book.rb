require 'kramdown'
require 'erb'
require 'yaml'
require 'zlib'

require 'support/load_markdown_from_file'
require 'support/hash_to_ostruct'
require 'support/html_utils'

require 'kramdown/parser/kramdown'

Kramdown::Parser::Html::HTML_CONTENT_MODEL_BLOCK << "x-spoiler"
Kramdown::Parser::Html::HTML_CONTENT_MODEL["x-spoiler"] = :block
Kramdown::Parser::Html::HTML_BLOCK_ELEMENTS << "x-spoiler"
Kramdown::Parser::Html::HTML_ELEMENT["x-spoiler"] = true

class Kramdown::Converter::BookHtml < Kramdown::Converter::Html
  def convert_html_element(el, indent)
    if el.value == "x-spoiler"
      summary = Kramdown::Element.new(:html_element, "summary", nil)
      summary.children << Kramdown::Element.new(:text, "Spoiler", nil)
      el.children.unshift summary
      el.value = "details"
      super(el, indent)
    else
      super
    end
  end
end

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

    Zlib::GzipWriter.open(output) do |f|
      f.write(html)
    end
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

  protected

  def load_template(file)
    @templates[file] ||= ERB.new(File.read(file))
  end
end
