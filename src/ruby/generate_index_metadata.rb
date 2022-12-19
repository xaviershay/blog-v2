require 'yaml'
require 'date'

posts = []

# TODO: Read files from args
Dir["data/posts/*.md"].each do |file|
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
  metadata["day"] = metadata["date"].to_date

  unless metadata["slug"]
    metadata["slug"] = File.basename(file.split('-', 4).drop(3).first.to_s, ".md")
  end
  metadata["url"] = "/articles/#{metadata["slug"]}.html"

  File.write("out/metadata/posts/#{File.basename(file)}.yml", metadata.to_yaml)
  posts << metadata
end
posts = posts.sort_by {|x| x.fetch("date") }.reverse
yaml = {"title" => "unused", "posts" => posts}.to_yaml
File.write("out/metadata/index.yml", yaml)
# title: UNUSED, suppressing a pandoc warning
# blah: Yo
# posts:
#   - title: Post 1
#     date: 2022-02-10
#     slug: post-1
#   - title: Post 2
#     date: 2022-02-19
#     slug: post-2
