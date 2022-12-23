require 'yaml'
require 'date'

def compile_index_metadata(post_metadata, out)
  posts = []
  yearly_archives = {}

  post_metadata.each do |post|
    metadata = YAML.load(File.read(post))
    %w(reading-list year-review).each do |yearly_type|
      if metadata['tags'].include?(yearly_type)
        yearly_archives[yearly_type] ||= []

        summary = {
          "url" => metadata.fetch("url")
        }
        summary["year"] = metadata["year"] || DateTime.parse(metadata["date"]).year
        yearly_archives[yearly_type] << summary
      end
    end
    posts << metadata
  end
  posts = posts.sort_by {|x| x.fetch("date") { raise x.inspect } }.reverse
  yaml = {"yearly_archives" => yearly_archives, "posts" => posts}.to_yaml
  File.write(out, yaml)
end
