require 'erb'
require 'date'
require 'kramdown'
require 'ostruct'
require "zlib"

YAML_FRONTMATTER_REGEX = /\A(---\s*\n.*?\n?)^---\s*\n/m

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

POST_TEMPLATE = ERB.new(File.read("src/erb/post.html.erb"))

def convert_post_to_html(file)
  raw = File.read(file)
  name = File.basename(file, ".md").split('-', 4).drop(3).first
  out = "out/site/articles/#{name}.html"

  match = raw.match(YAML_FRONTMATTER_REGEX)
  if match
    metadata = YAML.load(match[0])

    metadata['date'] = Date.parse(file.split('-', 4).take(3).join('-'))
    data = match.post_match

    doc = Kramdown::Document.new(data)

    @post = hash_to_ostruct(metadata)

    @post.body_html = doc.to_html
    html = POST_TEMPLATE.result

    Zlib::GzipWriter.open(out) do |f|
      f.write(html)
    end
  else
    raise "No frontmatter: #{file}"
  end
end

