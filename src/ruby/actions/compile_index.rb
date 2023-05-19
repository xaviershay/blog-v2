require 'erb'
require 'yaml'
require "zlib"

require 'support/hash_to_ostruct'
require 'support/load_index_metadata'

INDEX_TEMPLATE = ERB.new(File.read("src/erb/index.html.erb"))

def compile_index(layout_file, metadata_file, out)
  metadata = load_index_metadata(metadata_file)

  @site = hash_to_ostruct(metadata)

  @content = INDEX_TEMPLATE.result(binding)
  @title = "Xavier Shay"
  @subtitle = "Hello! I write here."
  @class = "page-index"

  layout_template = ERB.new(File.read(layout_file))
  html = layout_template.result(binding)
  Zlib::GzipWriter.open(out) do |f|
    f.write(html)
  end
end
