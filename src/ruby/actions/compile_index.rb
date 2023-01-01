require 'erb'
require 'yaml'
require "zlib"

require 'support/hash_to_ostruct'
require 'support/load_index_metadata'

INDEX_TEMPLATE = ERB.new(File.read("src/erb/index.html.erb"))

def compile_index(metadata_file, out)
  metadata = load_index_metadata(metadata_file)

  @site = hash_to_ostruct(metadata)

  html = INDEX_TEMPLATE.result(binding)
  Zlib::GzipWriter.open(out) do |f|
    f.write(html)
  end
end
