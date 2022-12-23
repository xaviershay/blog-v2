require 'erb'
require 'zlib'
require 'time'

ATOM_TEMPLATE = ERB.new(File.read("src/erb/feed.xml.erb"))

# https://github.com/jekyll/jekyll/blob/master/lib/jekyll/filters.rb#L77
def xml_escape(input)
  input.to_s.encode(:xml => :attr).gsub(%r!\A"|"\Z!, "")
end

def generate_atom_feed(out)
  metadata = YAML.load_file("out/metadata/index.yml", permitted_classes: [Date])
  metadata["posts"].each do |p|
    p["date"] = DateTime.parse(p["date"])
    p["body_html"] = File.read("out/html/posts/#{p["slug"]}.html")
  end

  metadata = hash_to_ostruct(metadata)

  @posts = metadata.posts.take(20)

  html = ATOM_TEMPLATE.result
  Zlib::GzipWriter.open(out) do |f|
    f.write(html)
  end
end
