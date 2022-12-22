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
    @post = hash_to_ostruct(metadata)
    data = match.post_match

    doc = Kramdown::Document.new(data)

    # TODO: DRY up with convert_index_to_html
    metadata = YAML.load_file("out/metadata/index.yml", permitted_classes: [Date])
    metadata["posts"].each do |p|
      p["date"] = DateTime.parse(p["date"])
    end
    @site = hash_to_ostruct(metadata)


    @post.body_html = doc.to_html
    # TODO: We actually need the whole site metadata for things like recent
    # posts, archive links, etc...
    html = POST_TEMPLATE.result

    html.gsub!(/{{\s*YOUTUBE\s+(.*?)(?:\s+(.*?))?\s*}}/mi) do |match|
      caption = "<em>#{$2}</em>" if $2
      id = $1.split('/').last
      <<-EOS
        <figure>
        <div class='embed-youtube'>
          <iframe width="560" height="315" src="https://www.youtube.com/embed/#{id}" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
        </div>
          <figcaption>#{caption}</figcaption>
        </figure>
      EOS
    end

    Zlib::GzipWriter.open(out) do |f|
      f.write(html)
    end
  else
    raise "No frontmatter: #{file}"
  end
end

