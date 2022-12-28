require 'erb'
require 'yaml'
require 'zlib'

require 'support/hash_to_ostruct'
require 'actions/book'

module Actions; end
class Actions::BookIndex
  def initialize
    @templates = {}
  end

  def compile_atom(template, metadata, fragment_dir, output)
    metadata = YAML.load_file(metadata)
    metadata = hash_to_ostruct(metadata)

    @id = File.join(HOST, "/books/")
    @title = "Xavier Shay's Books"
    @posts = metadata.readings.take(20)
    @posts.each do |book|
      book.extend(Actions::Book::BookMethods)
      book.body_html =
        "<p>#{book.stars}</p>\n" +
        File.read(File.join(fragment_dir, book.slug + '.html'))
    end

    erb = load_template(template)
    html = erb.result(binding)

    Zlib::GzipWriter.open(output) do |f|
      f.write(html)
    end
  end

  protected

  def load_template(file)
    @templates[file] ||= ERB.new(File.read(file))
  end
end
