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
      x['categories'] = x['categories'].dup
      x['finished_at'] = date
      year = Date.parse(date).year
      stats[year] ||= {
        'ratings' => Array.new(5, 0),
        'pages' => Array.new(10, 0),
        'page_total' => 0,
        'book_total' => 0,
        'categories' => Hash.new
      }
      stats[year]['page_total'] += metadata.fetch('pages')
      stats[year]['book_total'] += 1
      stats[year]['ratings'][metadata.fetch('rating') - 1] += 1
      stats[year]['pages'][(metadata.fetch('pages') / 100.0).floor] += 1
      categories = metadata.fetch('categories')
      categories = ["other"] if categories.empty?
      increment = 1 / categories.size.to_f
      categories.each do |category|
        stats[year]['categories'][category] ||= 0
        stats[year]['categories'][category] += increment
      end
      readings << x
    end
  end
  readings = readings.sort_by {|x| x.fetch("finished_at") }.reverse
  yaml = {"stats" => stats, "readings" => readings}.to_yaml
  File.write(out, yaml)
end
