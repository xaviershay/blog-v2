require 'kramdown'

require 'support/load_markdown_from_file'

def markdown_to_html_fragment(input, output)
  metadata, data = load_markdown_from_file(input)

  out = File.join("out/site", metadata.fetch("url"))

  doc = Kramdown::Document.new(data)

  html = doc.to_html

  html.gsub!(/{{\s*YOUTUBE\s+(.*?)(?:\s+(.*?))?\s*}}/mi) do |match|
    caption = "<em>#{$2}</em>" if $2
    id = $1.split('/').last
    <<-EOS
      <figure>
      <div class='embed-youtube'>
        <iframe width="560" height="315" src="https://www.youtube.com/embed/#{id}" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
      </div>
        <figcaption>#{caption}</figcaption>
      </figure>
    EOS
  end

  # TODO: Actually generate these
 #  book_data = {
 #    2022 => {
 #      'ratings' => [ 0, 1, 13, 15, 9 ],
 #      'pages' => [ 0, 2, 7, 13, 7, 4, 1, 2, 1, 1 ]
 #    }
 #  }
  html.gsub!(/{{\s*READINGGRAPHS\s+(\d+)\s*}}/mi) do |match|
    year = $1
    book_data = YAML.load_file("out/metadata/book_index.yml").fetch('stats')
    
    if data = book_data[year.to_i]
      ratings = data.fetch('ratings')
      m = ratings.max.to_f
      rating_rows = ratings.map.with_index {|n, index|
        <<-EOS
          <tr>
            <th scope='row'>#{index + 1}</th>
            <td style='--size:#{n / m};'><span class='data'>#{n}</span></td>
          </tr>
        EOS
      }.join("\n")

      pages = data.fetch('pages')
      m = pages.max.to_f
      pages_rows = pages.map.with_index {|n, index|
        <<-EOS
          <tr>
            <th scope='row'>#{(index + 1) * 100}</th>
            <td style='--size:#{n / m};'><span class='data'>#{n}</span></td>
          </tr>
        EOS
      }.join("\n")

      styles = "charts-css data-spacing-1 column show-labels"
      <<-EOS
        <figure class='reading-analysis'>
          <div>
            <table class='ratings-histogram #{styles}'>
              <caption>Ratings</caption>
              <tbody>
                #{rating_rows}
              </tbody>
            </table>
            <table class='pages-histogram #{styles}'>
              <caption>Length</caption>
              <tbody>
                #{pages_rows}
              </tbody>
            </table>
          </div>
          <figcaption>
            Histogram of ratings (left) and length in pages (right).
          </figcaption>
        </figure>
      EOS
    else
      ""
    end
  end

  File.write(output, html)
end
