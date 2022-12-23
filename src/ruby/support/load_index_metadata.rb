require 'yaml'

def load_index_metadata(metadata_file)
  metadata = YAML.load_file(metadata_file)
  metadata["posts"].each do |p|
    p["date"] = DateTime.parse(p["date"])
  end
  metadata
end
