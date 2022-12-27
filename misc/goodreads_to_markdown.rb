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
  43075560 => "OL44959390M", # Mortgage Meltdown: Mapping the Past, Present, and Future of Fannie Mae
  18218384 => "OL2863025M", # Mathematics for the nonmathematician
  2666  => "OL1925470W",
  36307634 => "OL19070821W",
  22299763 => "OL17597665W",
  23437156 => "OL17332479W",
  14061957 => "OL17293267W",
  14061955 => "OL2626368W",
  10194157 => "OL16239519W",
  34602136 => "OL28641102M",
  44020966 => "OL20840033W",
  12074927 => "OL17400059W",
  30141085 => "OL25736603W",
  18890191 => "OL29544330M",
  54114318 => "OL21399105W",
  41085049 => "OL20896432W",
  33246443 => "OL44958366M", # World's Best: Coaching with the Kookaburras and the Hockeyroos
  13651    => "OL59863W", #  The Dispossessed: An Ambiguous Utopia
  39286958 => "OL19746884W", #  Measure What Matters
  139069   => "OL874159W", # Endurance: Shackleton's Incredible Voyage
  40874032 => "OL17332806W", #  Vicious (Villains, #1)
  32109569 => "OL26770283M", #  We Are Legion (We Are Bob) (Bobiverse, #1)
  25489625 => "OL31380291W", #  Between the World and Me
  40053431 => "OL19351310W", #  Exactly: How Precision Engineers Created the Modern World
  8153988  => "OL2189633M", #  The Eye of the World (The Wheel of Time, #1)
  12982713 => 'OL16495247W', # El Narco: Inside Mexico's Criminal Insurgency
  42267971 => 'OL44958593M', # Eliud Kipchoge - History's fastest marathoner: An insight into the Kenyan life that shapes legends
  36556202 => 'OL28202924M', # The Coddling of the American Mind: How Good Intentions and Bad Ideas Are Setting Up a Generation for Failure
  8249187 => 'OL14993212W', # Bright Shiny Morning
  35016990 => 'OL20199686W', # The End of the World Running Club
  38908293 => 'OL1895753W', # Red Moon
  20190519 => 'OL25651604M', # Age of Ambition: Chasing Fortune, Truth, and Faith in the New China
  36500398 => 'OL32198773M', # The Order of Time
  29584452 => 'OL25034040W', # The Underground Railroad
  38897904 => 'OL9232188M', # Cryptonomicon
  41431734 => 'OL4300550W', # The Dream Machine
  23450640 => 'OL3259371W', # The Man Who Walked Through Time: The Story of the First Trip Afoot Through the Grand Canyon (Vintage Departures)
  6589085 => 'OL679266W', # Anansi Boys
  20025567 => 'OL17635445W', # The Prize: Who's in Charge of America's Schools?
  40876575 => 'OL27689776W', # Utopia for Realists: How We Can Build the Ideal World
  32970931 => 'OL24715437W', # The Spider Network: The Wild Story of a Math Genius, a Gang of Backstabbing Bankers, and One of the Greatest Scams in Financial History
  38117105 => 'OL19774355W', # The Monster Baru Cormorant (The Masquerade, #2)
  18831377 => 'OL16572140W', # The New Geography of Jobs
  40611510 => 'OL7952998W', # The Last Lecture
  38799469 => 'OL17892614W', # Bad Blood: Secrets and Lies in a Silicon Valley Startup
  37655127 => 'OL27358713M', # Black Edge: Inside Information, Dirty Money, and the Quest to Bring Down the Most Wanted Man on Wall Street
  30007916 => 'OL17797130W', # A Gentleman in Moscow
  20528604 => 'OL17558854W', # The Rise of Superman: Decoding the Science of Ultimate Human Performance
  28700715 => 'OL27371991M', # The Cosmic Web: Mysterious Architecture of the Universe
  37761175 => 'OL47320M', # A People's History of the United States
  39913669 => 'OL19745058W', # The Battle For Paradise: Puerto Rico Takes on the Disaster Capitalists
  35404824 => 'OL27340415M', # North: Finding My Way While Running the Appalachian Trail
  8343753 => 'OL8135246W', # To the Edge: A Man, Death Valley, and the Mystery of Endurance
  40004706 => 'OL17828326W', # Evicted: Poverty and Profit in the American City
  6088007 => 'OL27258W', # Neuromancer (Sprawl, #1)
  20787425 => 'OL16929196W', # Reinventing Organizations: A Guide to Creating Organizations Inspired by the Next Stage of Human Consciousness
  25251264 => 'OL20494296W', # On Palestine
  13183999 => 'OL16298712W', # Extra Virginity: The Sublime and Scandalous World of Olive Oil
  34445060 => 'OL20166987W', # Janesville: An American Story
  6323016 => 'OL4311885W', # Boyd: The Fighter Pilot Who Changed the Art of War
  6451669 => 'OL24752012W', # Altered Carbon (Takeshi Kovacs, #1)
  10809340 => 'OL5829273W', # The Happiness Hypothesis: Finding Modern Truth in Ancient Wisdom
  10814191 => 'OL15680047W', # The Most Human Human
  34593435 => 'OL20170111W', # Exoplanets: Diamond Worlds, Super Earths, Pulsar Planets, and the New Search for Life beyond Our Solar System
  35696749 => 'OL17062644W', # Ancillary Justice (Imperial Radch, #1)
  16160706 => 'OL16489931W', # Steal Like an Artist: 10 Things Nobody Told You About Being Creative
  25884323 => 'OL20003842W', # Aurora
  18245960 => 'OL25840917M', # The Three-Body Problem (Remembrance of Earth’s Past, #1)
  34599304 => 'OL20053398W', # Asteroid Hunters (TED Books)
  34039808 => 'OL17834026W', # Oathbringer (The Stormlight Archive, #3)
  18219313 => 'OL19920887W', # Encounter with Tiber
  22816087 => 'OL17829905W', # Seveneves
  12802745 => 'OL25690739M', # The Better Angels of Our Nature: Why Violence Has Declined
  17786270 => 'OL22322511M', # Out of the Crises
  6521829 => 'OL3783464W', # Generation Kill
  33411603 => 'OL26499490W', # Away with Words: An Irreverent Tour Through the World of Pun Competitions
  6567239 => 'OL15335590W', # High Fidelity
  21943284 => 'OL24505310W', # Zeroes
  25927585 => 'OL17543143W', # The Secret Life of Musical Notation: Defying Interpretive Traditions (Amadeus)
  31138556 => 'OL26247313M', # Homo Deus: A History of Tomorrow
  19887474 => 'OL17363125W', # The Fifth Season (The Broken Earth, #1)
  21955107 => 'OL25692795W', # Running and Stuff
  28684704 => 'OL25936656M', # Dark Matter
  6303927 => 'OL38501W', # Snow Crash
  25600228 => 'OL20475117W', # The Traitor Baru Cormorant (The Masquerade, #1)
  8702101 => 'OL14991370W', # Ghost: Confessions of a Counterterrorism Agent
  11421926 => 'OL7969104W', # Clockers
  18940614 => 'OL19707566W', # Senlin Ascends (The Books of Babel, #1)
  20150777 => 'OL16813053W', # Words of Radiance (The Stormlight Archive, #2)
  18663149 => 'OL17074648W', # Abaddon's Gate (Expanse, #3)
  95558 => 'OL109524W', # Solaris
  27833494 => 'OL19773866W', # Dark Money: The Hidden History of the Billionaires Behind the Rise of the Radical Right
  18188241 => 'OL44958794M', # Fundamental Chess Patterns
  23692271 => 'OL17075811W', # Sapiens: A Brief History of Humankind
  21611 => 'OL271163W', # The Forever War (The Forever War, #1)
  25813921 => 'OL20244267W', # Grit: Passion, Perseverance, and the Science of Success
  18891113 => 'OL15172684W', # What Got You Here Won't Get You There
  40745 => 'OL2003465W', # Mindset: The New Psychology of Success
  20448494 => 'OL19991282W', # Racing Weight (The Racing Weight Series)
  18581676 => 'OL28671263W', # Be Slightly Evil: A Playbook for Sociopaths (Ribbonfarm Roughs)
  18581690 => 'OL28670515W', # The Gervais Principle: The Complete Series, with a Bonus Essay on Office Space (Ribbonfarm Roughs)
  10984768 => 'OL24144598W', # Tempo: Timing, Tactics and Strategy in Narrative-Driven Decision-Making
  12067 => 'OL453936W', # Good Omens: The Nice and Accurate Prophecies of Agnes Nutter, Witch
  11324722 => 'OL20355235W', # The Righteous Mind: Why Good People Are Divided by Politics and Religion
  18401393 => 'OL17091839W', # The Martian
  16049171 => 'OL28966677W', # Don't Go To Law School (Unless): A Law Professor's Inside Guide to Maximizing Opportunity and Minimizing Risk
  15622 => 'OL275128W', # Native Son
  17905709 => 'OL32166590M', # The Narrow Road to the Deep North
  11389457 => 'OL16151796W', # Writing Movies for Fun and Profit: How We Made a Billion Dollars at the Box Office and You Can, Too!
  10345973 => 'OL27028617M', # Cyropaedia: the education of Cyrus
  6581994 => 'OL1821254W', # The E-Myth Revisited: Why Most Small Businesses Don't Work and What to Do About It
  8125726 => 'OL2463051W', # The Goal: A Process of Ongoing Improvement
  17938142 => 'OL2929969W', # Town Smokes
  86147 => 'OL18322283M', # Bright Lights, Big City
  18901790 => 'OL44958880M', # Posterior Chain Linked: Don't Lift Without It (Simple Strength Book 6)
  17830292 => 'OL44958928M', # Squat Every Day
  17279627 => 'OL44959078M', # Disequilibrium
  17306293 => 'OL17366206W', # Shift (Silo, #2)
  13453029 => 'OL19790424W', # Wool Omnibus (Silo, #1)
  7640261 => 'OL15568568W', # Sex at Dawn: The Prehistoric Origins of Modern Sexuality
  17280927 => 'OL44959139M', # Work out lose weight and stop being single
  17166225 => 'OL19629024W', # The Miracle Morning: The Not-So-Obvious Secret Guaranteed to Transform Your Life: Before 8AM
  23419 => 'OL107928W', # The Consolations of Philosophy
  4407 => 'OL679360W', # American Gods (American Gods, #1)
  10374 => 'OL25118521M', # Hard-Boiled Wonderland and the End of the World
  13306525 => 'OL44959190M', # Ikigai
  242472 => 'OL3295030W', # The Black Swan: The Impact of the Highly Improbable
  10557318 => 'OL19644560W', # Running on Empty: An Ultramarathoner's Story of Love, Loss, and a Record-Setting Run Across America
  12978407 => 'OL44959278M', # The Long Run
  262731 => 'OL18149735W', # The Definitive Book of Body Language
  13274256 => 'OL44959327M', # Betterness: Economics for Humans
  4395 => 'OL23205W', # The Grapes of Wrath
  4138 => 'OL2693098W', # Naked
  9938211 => 'OL24531400M', # The 4-Hour Body: An Uncommon Guide to Rapid Fat-Loss, Incredible Sex, and Becoming Superhuman
  5048174 => 'OL20288512W', # 2BR02B
  320 => 'OL274505W', # One Hundred Years of Solitude
  6289283 => 'OL13805586W', # Born to Run: A Hidden Tribe, Superathletes, and the Greatest Race the World Has Never Seen
  1713426 => 'OL9302660W', # Predictably Irrational: The Hidden Forces That Shape Our Decisions
  119787 => 'OL103123W', # Fahrenheit 451
}.filter {|k, v| v.length > 0 }

books = doc.css('#booksBody tr.review').map do |row|
  shelves = row.css('.field.shelves .value .shelfLink').map(&:text)
  next unless shelves.include?("read")
  rating = row.css('.field.rating .value .stars').attr('data-rating').value.to_i
  next unless rating > 0
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
      raise "404, bad ol id in overrides for #{gr_id} #{title}: #{ol_id}"
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
      $stderr.puts "#{gr_id} => '', # #{title}"
      next
    else
      raise "Unhandled response code: #{ol_data.code}"
    end
  else
    ol_id = begin
      query = URI.encode_www_form(q: %|title:"#{short_title}" author:"#{author}"|)
      path = %|/search.json?#{query}|
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
      else
      end
    end

    unless ol_id
      $stderr.puts "#{gr_id} => '', # #{title}"
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
  pages = (book[:openlibrary][:pages] || book[:pages]).to_i
  title = book[:openlibrary][:title]
  slug = title.downcase.gsub(/[^a-z0-9]+/, '-')
  if pages == 0
    puts book.inspect
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

  # puts "Writing #{slug}.md"
  raw = <<-EOS
#{metadata.to_yaml.gsub(/\n\Z/, '')}
---
#{content}
  EOS
  File.write("../data/books/#{slug}.md", raw)
end
