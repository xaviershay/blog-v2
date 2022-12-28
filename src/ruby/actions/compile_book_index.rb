require 'erb'
require 'yaml'
require "zlib"

require 'support/hash_to_ostruct'
require 'support/load_index_metadata'

BOOK_INDEX_TEMPLATE = ERB.new(File.read("src/erb/book_index.html.erb"))

module BookSiteMethods
  def yearly_stats
    @yearly_stats ||= stats.sort_by(&:first).filter {|k, v| k > 2009 }
  end
end

def compile_book_index(metadata_file, out)
  metadata = load_book_index_metadata(metadata_file)

  @site = hash_to_ostruct(metadata)
  @site.extend(BookSiteMethods)

  html = BOOK_INDEX_TEMPLATE.result
  Zlib::GzipWriter.open(out) do |f|
    f.write(html)
  end
end
