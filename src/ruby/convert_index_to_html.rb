require 'erb'
require 'date'
require 'ostruct'
require "zlib"

INDEX_TEMPLATE = ERB.new(File.read("src/erb/index.html.erb"))

def hash_to_ostruct(x)
  case x
  when Hash
    OpenStruct.new(x.transform_values {|y| hash_to_ostruct(y) })
  when Array
    x.map {|y| hash_to_ostruct(y) }
  else
    x
  end
end

def convert_index_to_html
  out = "out/site/index.html"

  metadata = YAML.load_file("out/metadata/index.yml", permitted_classes: [Date])
  metadata["posts"].each do |p|
    p["date"] = DateTime.parse(p["date"])
  end
  @site = hash_to_ostruct(metadata)

  html = INDEX_TEMPLATE.result
  Zlib::GzipWriter.open(out) do |f|
    f.write(html)
  end
end
