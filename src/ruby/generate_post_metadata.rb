require 'yaml'
require 'date'

def generate_post_metadata(file)
  contents = File.read(file).lines
  raise "invalid header: #{file}" unless contents[0] == "---\n"
  raw_metadata = contents.drop(1).take_while {|x| x != "---\n" }.join
  metadata = YAML.load(raw_metadata, permitted_classes: [Date])
  unless metadata["date"]
    metadata["date"] = DateTime.parse(file)
  end
  if metadata["date"].is_a?(String)
    metadata["date"] = DateTime.parse(metadata["date"])
  end
  metadata["day"] = metadata["date"].to_date.strftime("%b %e, %Y")
  metadata["date"] = metadata["date"].iso8601
  metadata["source"] = file

  unless metadata["slug"]
    metadata["slug"] = File.basename(file.split('-', 4).drop(3).first.to_s, ".md")
  end
  metadata["url"] = "/articles/#{metadata["slug"]}.html"

  File.write("out/metadata/posts/#{File.basename(file)}.yml", metadata.to_yaml)
end
