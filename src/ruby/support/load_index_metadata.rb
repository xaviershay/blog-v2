require 'yaml'

def load_index_metadata(metadata_file)
  metadata = YAML.load_file(metadata_file)
  metadata["posts"].each do |p|
    p["date"] = DateTime.parse(p["date"])
  end
  metadata
end

def load_book_index_metadata(metadata_file)
  metadata = YAML.load_file(metadata_file)
  metadata["readings"].each do |p|
    p["finished_at"] = DateTime.parse(p["finished_at"])
  end
  metadata
end
