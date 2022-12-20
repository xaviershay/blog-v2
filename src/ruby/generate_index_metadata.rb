require 'yaml'
require 'date'

def generate_index_metadata(post_metadata)
  posts = []

  post_metadata.each do |post|
    metadata = YAML.load(File.read(post), permitted_classes: [Date])
    posts << metadata
  end
  posts = posts.sort_by {|x| x.fetch("date") { raise x.inspect } }.reverse
  yaml = {"title" => "unused", "posts" => posts}.to_yaml
  File.write("out/metadata/index.yml", yaml)
end
