require 'yaml'
require 'date'

def compile_index_metadata(post_metadata, out)
  posts = []
  factorio_reviews = []
  trip_reports = []
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
    if metadata['tags'].include?('factorio')
      summary = {
        "url" => metadata.fetch("url"),
        "title" => metadata.fetch("title"),
        "date" => metadata.fetch("date")
      }
      factorio_reviews << summary
    end
    if metadata['tags'].include?('trip-report')
      summary = {
        "url" => metadata.fetch("url"),
        "title" => metadata.fetch("title"),
        "date" => metadata.fetch("date")
      }
      trip_reports << summary
    end
    posts << metadata
  end
  posts = posts
    .reject {|x| x['draft'] }
    .sort_by {|x| x.fetch("date") { raise x.inspect } }
    .reverse
  yaml = {
    "yearly_archives"  => yearly_archives,
    "posts"            => posts,
    "factorio_reviews" => factorio_reviews,
    "trip_reports"     => trip_reports
  }.to_yaml
  File.write(out, yaml)
end

def compile_book_index_metadata(book_metadata, post_index_metadata, out)
  readings = []
  stats = {}

  post_index = YAML.load_file(post_index_metadata, permitted_classes: [Date])
  year_reviews = post_index
    .fetch('yearly_archives')
    .fetch("reading-list")
    .map {|x| [x.fetch('year'), x.fetch('url')] }
    .to_h

  book_metadata.each do |book|
    metadata = YAML.load_file(book, permitted_classes: [Date])
    metadata.fetch('reads').each do |read|
      read['started_at'] = ensure_date(read['started_at'])
      read['finished_at'] = ensure_date(read['finished_at'])
      read['abandoned_at'] = ensure_date(read['abandoned_at'])
      date = read.fetch('finished_at') || read.fetch("abandoned_at").dup
      if date
        percentage = read.fetch('percentage', 100)
        pages = metadata.fetch('pages') * percentage.to_f / 100
        x = metadata.except('reads')
        x['slug'] = File.basename(book, ".md.yml")
        categories = x['categories'].dup
        if categories.delete('other')
          categories << 'literature'
        end
        x['categories'] = categories
        x['finished_at'] = date.dup
        x['started_at'] = read['started_at']
        x['abandoned_at'] = read['abandoned_at']
        x['percentage'] = read['percentage']
        year = date.year
        stats[year] ||= {
          'ratings' => Array.new(5, 0),
          'pages' => Array.new(10, 0),
          'page_total' => 0,
          'book_total' => 0,
          'categories' => Hash.new
        }
        stats[year]['page_total'] += pages
        stats[year]['book_total'] += 1
        rating = metadata.fetch('rating')
        unless rating
          raise "Book is finished but no rating: #{x['slug']}"
        end
        stats[year]['ratings'][rating - 1] += 1
        stats[year]['pages'][(pages / 100.0).floor] += 1
        categories = ["literature"] if categories.empty?
        increment = 1 / categories.size.to_f
        categories.each do |category|
          stats[year]['categories'][category] ||= 0
          stats[year]['categories'][category] += increment
        end
        readings << x
      end
    end
  end
  readings = readings.sort_by {|x| x.fetch("finished_at") || x.fetch("abandoned_at") }.reverse
  yaml = {
    "year_reviews" => year_reviews,
    "stats" => stats.filter {|k, v| k > stats.keys.max - 15},
    "readings" => readings
  }.to_yaml
  File.write(out, yaml)
end

def ensure_date(x)
  case x
  when nil then nil
  when String then Date.parse(x)
  when Date then x
  else
    raise "Unknown class: #{x.inspect}"
  end
end
