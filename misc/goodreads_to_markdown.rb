require 'nokogiri'
require 'http'
require 'json'
require 'date'
require 'yaml'
require 'csv'

def cache(key, &block)
  filename = "cache/#{key.gsub(/[^a-zA-Z\d]/, '--')}"
  if File.exists?(filename)
    Marshal.load(File.read(filename))
  else
    contents = block.call(key)
    File.write(filename, Marshal.dump(contents))
    contents
  end
end

doc = Nokogiri::HTML(File.read('data/goodreads-scrape.html'))

enriched = {}
CSV.foreach('data/goodreads-export-enriched.csv', headers: true) do |row|
  obj = []
  obj << 'fantasy' if row['Fantasy'].to_s.length > 0
  obj << 'sci-fi' if row['Sci-Fi'].to_s.length > 0
  # obj << 'fiction' if row['Fiction'].to_s.length > 0
  obj << 'non-fiction' if row['Non-Fiction'].to_s.length > 0
  obj << 'literature' if row['Literature'].to_s.length > 0
  enriched[row['Book Id']] = obj
end

BASE = "https://openlibrary.org"

Response = Struct.new(:code, :body)

OVERRIDES = {
  8393116 => "OL16135310W",
  45154547 => "OL20832939W",
  45047384 => "OL20656224W",
  24233708 => "OL19649395W",
  33361943 => "OL20071029W",
  27276428 => "OL17762235W",
  43352954 => "OL20639540W",
  #43075560 => "", Mortgage Meltdown: Mapping the Past, Present, and Future of Fannie Mae
  18218384 => "OL1947904W",
  2666  => "OL1925470W",
  36307634 => "OL19070821W",
  22299763 => "OL17597665W",
  23437156 => "OL17332479W",
  14061957 => "OL17293267W",
  14061955 => "OL2626368W", 
  10194157 => "OL16239519W",
  34602136 => "OL21156417W",
  44020966 => "OL20840033W",
  12074927 => "OL17400059W",
  30141085 => "OL25736603W",
  18890191 => "OL29544330M",
  54114318 => "OL21399105W",
  41085049 => "OL20896432W",
  #33246443 => "", # World's Best: Coaching with the Kookaburras and the Hockeyroos
  13651    => "OL59863W", #  The Dispossessed: An Ambiguous Utopia
  39286958 => "OL19746884W", #  Measure What Matters
  139069   => "OL874159W", # Endurance: Shackleton's Incredible Voyage
  40874032 => "OL17332806W", #  Vicious (Villains, #1)
  32109569 => "OL26770283M", #  We Are Legion (We Are Bob) (Bobiverse, #1)
  25489625 => "OL31380291W", #  Between the World and Me
  40053431 => "OL19351310W", #  Exactly: How Precision Engineers Created the Modern World
  8153988  => "OL2189633M", #  The Eye of the World (The Wheel of Time, #1)
}

books = doc.css('#booksBody tr.review').map do |row|
  shelves = row.css('.field.shelves .value .shelfLink').map(&:text)
  next unless shelves.include?("read")

  dates_read = begin
    raw = row.css('.field.date_read .value .date_read_value').map(&:text)
    raw.map do |date_raw|
      begin
        Date.parse(date_raw).to_s
      rescue
        raise "#{date_raw} is not a date!"
      end
    end
  end

  next unless dates_read.any?

  gr_id = row.css('.field.cover .value div').attr('data-resource-id').value
  isbn = row.css('.field.isbn .value').text.strip
  title = row.css('.field.title .value a').attr('title').value
  author_backwards = row.css('.field.author .value a').text
  author = begin
             x = author_backwards.split(', ', 2)
             x.reverse.join(" ")
           end
  short_title = title.split(':').first


  ol_id = OVERRIDES[gr_id.to_i]

  ol = if ol_id
    response = cache("/books/#{ol_id}") {|path|
      url = "#{BASE}#{path}.json"
      puts "Fetching #{url}"
      raw = HTTP.follow.get(url)
      Response.new(raw.code, raw.body.to_s)
    }
    case response.code
    when 200, 302
      JSON.parse(response.body)
    when 404
      raise "404, bad ol id in overrides"
    else
      raise "Unhandled response code: #{response.code}"
    end
  elsif isbn.length > 0
    response = cache("/isbn/#{isbn}") {|path|
      url = "#{BASE}#{path}.json"
      puts "Fetching #{url}"
      raw = HTTP.follow.get(url)
      Response.new(raw.code, raw.body.to_s)
    }
    case response.code
    when 200, 302
      JSON.parse(response.body)
    when 404
      puts "not found by ISBN, abandoning"
      $stderr.puts "MISSING: #{gr_id} #{title}"
      next
    else
      raise "Unhandled response code: #{ol_data.code}"
    end
  else
    ol_id = begin
      query = URI.encode_www_form(q: %|title:"#{short_title}" author:"#{author}"|)
      path = %|/search.json?#{query}|
      puts path
      response = cache(path) {|path|
        url = "#{BASE}#{path}"
        puts "Fetching #{url}"
        raw = HTTP.follow.get(url)
        Response.new(raw.code, raw.body.to_s)
      }
      parsed = JSON.parse(response.body)
      case parsed["numFound"]
      when 1
        doc = parsed['docs'][0]
        raise "#{doc['type']}" unless doc['type'] == "work"
        ol_id = doc['key'].split('/').last
      when 0
        puts "not found"
      else
        puts "Ambiguous match"
      end
    end

    unless ol_id
      $stderr.puts "MISSING: #{gr_id} #{title}"
      next
    end

    response = cache("/books/#{ol_id}") {|path|
      url = "#{BASE}#{path}.json"
      puts "Fetching #{url}"
      raw = HTTP.follow.get(url)
      Response.new(raw.code, raw.body.to_s)
    }
    case response.code
    when 200, 302
      JSON.parse(response.body)
    when 404
      raise "404, trying another method"
    else
      raise "Unhandled response code: #{response.code}"
    end
  end

  {
    title: title,
    author: author,
    categories: enriched.fetch(gr_id),
    openlibrary: {
      key: ol["key"].split('/').last,
      title: ol["title"],
      pages: ol['number_of_pages'],
      full_title: ol["full_title"]
    },
    rating: row.css('.field.rating .value .stars').attr('data-rating').value.to_i,
    isbn: isbn,
    asin: row.css('.field.asin .value').text.strip,
    pages: row.css('.field.num_pages .value').text.gsub('pp', '').strip,
    review: row.css('.field.review .value span').last
      &.inner_html
      &.gsub("<br>", "\n")
      &.gsub("&gt;", ">"),
    dates_read: dates_read,
  }
end.compact

`mkdir -p out`
books.each do |book|
  pages = book[:pages].to_i
  title = book[:openlibrary][:title]
  slug = title.downcase.gsub(/[^a-z0-9]+/, '-')
  if pages == 0
    $stderr.puts "PAGE ERROR: #{title}"
  end
  metadata = {
    "id" => book[:openlibrary][:key],
    "slug" => slug,
    "title" => title,
    "author" => book[:author],
    "rating" => book[:rating],
    "pages" => book[:pages].to_i,
    "categories" => book[:categories],
    "reads" => book[:dates_read].map {|x| {"finished_at" => x}}
  }
  content = book.fetch(:review)

  puts "Writing #{slug}.md"
  raw = <<-EOS
#{metadata.to_yaml.gsub(/\n\Z/, '')}
---
#{content}
  EOS
  File.write("../data/books/#{slug}.md", raw)
end
