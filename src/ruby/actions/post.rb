require 'support/kramdown'

class Actions::Post < Builder
  def load_markdown(input)
    load_markdown_from_file2(input)
  end

  def markdown_to_metadata(input, output)
    metadata, data = *load_markdown_from_file2(input)

    unless metadata["date"]
      metadata["date"] = DateTime.parse(File.basename(input))
    end
    if metadata["date"].is_a?(String)
      metadata["date"] = DateTime.parse(metadata["date"])
    end
    metadata["date"] = metadata["date"].iso8601
    metadata["summary"] = metadata["description"] || truncate(data, 120)
    metadata["card_image"] =
      metadata.fetch("image", {}).values_at("card", "feature").compact.first
    metadata["source"] = input
    metadata["tags"] ||= []
    metadata.fetch("image", {}).values_at("card", "feature").compact.first
    if metadata["image"] && metadata["image"]["feature_credit"]
      metadata["image"]["feature_credit"]["emphasis"] = true
    end

    unless metadata["slug"]
      metadata["slug"] =
        File.basename(input.split('-', 4).drop(3).first.to_s, ".md")
    end
    metadata["url"] = "/articles/#{metadata["slug"]}.html"
    File.write(output, metadata.to_yaml)
  end

  def markdown_to_html_fragment(input, output)
    _, data = load_markdown(input)

    doc = Kramdown::Document.new(data, :book_data => book_data)

    html = doc.to_post_html

    File.write(output, html)
  end

  def compile_erb(template, fragment_file, metadata_file, out)
    fragment = File.read(fragment_file)
    metadata = YAML.load_file(metadata_file)
    metadata['date'] = DateTime.parse(metadata['date'])

    name = metadata['slug']

    @post = hash_to_ostruct(metadata).extend(PostMethods)
    @post.body_html = fragment

    @site = site

    erb = load_template(template)
    html = erb.result(binding)

    write_gzip(out, html)
  end

  def site
    @site ||= hash_to_ostruct(load_index_metadata("out/metadata/index.yml"))
  end

  def book_data
    @book_data ||= book_data = YAML
      .load_file("out/metadata/book_index.yml", permitted_classes: [Date])
      .fetch('stats')
  end

  module PostMethods
    def all_credits
     ([
        self.image&.feature_credit,
     ] + (self.credits || [])).compact
    end
  end
end
