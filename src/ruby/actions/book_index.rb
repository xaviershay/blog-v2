require 'support/builder'
require 'actions/book'

require 'support/load_index_metadata'

class Actions::BookIndex < Builder
  def compile_erb(template, metadata_file, output)
    metadata = load_book_index_metadata(metadata_file)

    @site = hash_to_ostruct(metadata)
    @site.extend(BookSiteMethods)
    @site.readings.each do |book|
      book.extend(Actions::Book::BookMethods)
    end

    html = load_template(template).result(binding)
    write_gzip output, html
  end

  def compile_atom(template, metadata, fragment_dir, output)
    metadata = YAML.load_file(metadata)
    metadata = hash_to_ostruct(metadata)

    @id = File.join(HOST, "/books/")
    @title = "Xavier Shay's Books"
    @posts = metadata.readings.take(20)
    @posts.each do |book|
      book.extend(Actions::Book::BookMethods)
      book.body_html =
        "<p>#{book.stars}</p>\n" +
        File.read(File.join(fragment_dir, book.slug + '.html'))
    end

    erb = load_template(template)
    html = erb.result(binding)

    write_gzip output, html
  end

  module BookSiteMethods
    def yearly_stats
      @yearly_stats ||= stats.sort_by(&:first).filter {|k, v| k > 2009 }
    end
    
    def recommendations_for(year)
      year_reviews[year]
    end
  end
end
