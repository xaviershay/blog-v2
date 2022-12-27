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

def compile_book_index_metadata(book_metadata, out)
  readings = []
  stats = {}

  book_metadata.each do |book|
    metadata = YAML.load(File.read(book))
    metadata.fetch('reads').each do |read|
      date = read.fetch('finished_at')
      x = metadata.except('reads')
      x['finished_at'] = date
      year = Date.parse(date).year
      stats[year] ||= {
        'ratings' => Array.new(5, 0),
        'pages' => Array.new(10, 0)
      }
      stats[year]['ratings'][metadata.fetch('rating') - 1] += 1
      stats[year]['pages'][(metadata.fetch('pages') / 100.0).floor] += 1
      readings << x
    end
  end
  readings = readings.sort_by {|x| x.fetch("finished_at") }.reverse
  pp stats
  yaml = {"stats" => stats, "readings" => readings}.to_yaml
  File.write(out, yaml)
end
