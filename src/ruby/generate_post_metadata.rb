require 'yaml'
require 'date'

def generate_post_metadata(input)
  metadata, data = load_markdown_from_file(input)

  File.write("out/metadata/posts/#{File.basename(input)}.yml", metadata.to_yaml)
end
