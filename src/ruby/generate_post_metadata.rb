require 'yaml'
require 'date'

def truncate(str, n)
  return str if str.length < n

  str[0..n] + "…"
end

def generate_post_metadata(file)
  raw = File.read(file)
  match = raw.match(YAML_FRONTMATTER_REGEX)
  raise "invalid header: #{file}" unless match
  metadata = YAML.load(match[0], permitted_classes: [Date])
  content = match.post_match
  unless metadata["date"]
    metadata["date"] = DateTime.parse(file)
  end
  if metadata["date"].is_a?(String)
    metadata["date"] = DateTime.parse(metadata["date"])
  end
  metadata["day"] = metadata["date"].to_date.strftime("%b %e, %Y")
  metadata["date"] = metadata["date"].iso8601
  metadata["summary"] = metadata["description"] || truncate(content, 120)
  metadata["card_image"] = metadata.fetch("image", {}).values_at("card", "feature").compact.first
  metadata["source"] = file

  unless metadata["slug"]
    metadata["slug"] = File.basename(file.split('-', 4).drop(3).first.to_s, ".md")
  end
  metadata["url"] = "/articles/#{metadata["slug"]}.html"

  File.write("out/metadata/posts/#{File.basename(file)}.yml", metadata.to_yaml)
end
