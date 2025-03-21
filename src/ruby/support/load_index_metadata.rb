require 'yaml'

def load_index_metadata(metadata_file)
  metadata = YAML.load_file(metadata_file)
  (metadata["posts"] + metadata['factorio_reviews'] + metadata['trip_reports']).each do |p|
    p["date"] = DateTime.parse(p["date"])
  end
  metadata
end

def load_book_index_metadata(metadata_file)
  metadata = YAML.load_file(metadata_file, permitted_classes: [Date])
  metadata["readings"].each do |p|
    p["finished_at"] = ensure_date(p["finished_at"])
  end
  metadata
end
