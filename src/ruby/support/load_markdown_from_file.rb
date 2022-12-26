require 'yaml'
require 'date'

YAML_FRONTMATTER_REGEX = /\A(---\s*\n.*?\n?)^---\s*\n/m

def truncate(str, n)
  return str if str.length < n

  str[0..n] + "…"
end

def load_markdown_from_file(input_file)
  raw = File.read(input_file)

  match = raw.match(YAML_FRONTMATTER_REGEX)
  if match
    metadata = YAML.load(match[0], permitted_classes: [Date])
    data = match.post_match

    unless metadata["date"]
      metadata["date"] = DateTime.parse(File.basename(input_file))
    end
    if metadata["date"].is_a?(String)
      metadata["date"] = DateTime.parse(metadata["date"])
    end
    metadata["date"] = metadata["date"].iso8601
    metadata["summary"] = metadata["description"] || truncate(data, 120)
    metadata["card_image"] =
      metadata.fetch("image", {}).values_at("card", "feature").compact.first
    metadata["source"] = input_file
    metadata["tags"] ||= []
    metadata.fetch("image", {}).values_at("card", "feature").compact.first
    if metadata["image"] && metadata["image"]["feature_credit"]
      metadata["image"]["feature_credit"]["emphasis"] = true
    end

    unless metadata["slug"]
      metadata["slug"] =
        File.basename(input_file.split('-', 4).drop(3).first.to_s, ".md")
    end
    metadata["url"] = "/articles/#{metadata["slug"]}.html"

    [metadata, data]
  else
    raise "Invalid markdown file: #{input_file}"
  end
end
