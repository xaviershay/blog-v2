require 'kramdown'
require 'support/tikz'

# Custom tag processing. We use HTML5 custom tag rules, but pre-process them
# before they actually get into HTML output. Easier that way, but in theory
# could also handle in HTML (i.e. if we switch parsers and need an alternate).
#
# Modifying Kramdown constants isn't documented and is likely brittle, but
# there isn't another great way to do it.
#
# See https://github.com/gettalong/kramdown/issues/694#issuecomment-1366202209

# <x-spoiler> tag that converts into a <details> block with automatically
# generated <summary>
Kramdown::Parser::Html::HTML_CONTENT_MODEL_BLOCK << "x-spoiler"
Kramdown::Parser::Html::HTML_CONTENT_MODEL["x-spoiler"] = :block
Kramdown::Parser::Html::HTML_BLOCK_ELEMENTS << "x-spoiler"
Kramdown::Parser::Html::HTML_ELEMENT["x-spoiler"] = true

class Kramdown::Converter::BookHtml < Kramdown::Converter::Html
  def convert_html_element(el, indent)
    case el.value
    when "x-spoiler"
      summary = Kramdown::Element.new(:html_element, "summary", nil)
      summary.children << Kramdown::Element.new(:text, "Spoiler", nil)
      el.children.unshift summary
      el.value = "details"
      super(el, indent)
    else
      super
    end
  end
end

# <x-tikz> tag that compiles TikZ source to an SVG image wrapped in a
# <figure class='tikz'>. Uses :raw content model so that the LaTeX source
# (which contains blank lines) is preserved as-is rather than being parsed
# into separate block elements.
Kramdown::Parser::Html::HTML_CONTENT_MODEL["x-tikz"] = :raw
Kramdown::Parser::Html::HTML_BLOCK_ELEMENTS << "x-tikz"
Kramdown::Parser::Html::HTML_ELEMENT["x-tikz"] = true

# <x-youtube> tag that embeds a youtube video with optional caption. Adds a
# <div> wrapper to allow for mobile responsiveness.
Kramdown::Parser::Html::HTML_CONTENT_MODEL_BLOCK << "x-youtube"
Kramdown::Parser::Html::HTML_CONTENT_MODEL["x-youtube"] = :block
Kramdown::Parser::Html::HTML_BLOCK_ELEMENTS << "x-youtube"
Kramdown::Parser::Html::HTML_ELEMENT["x-youtube"] = true

# <x-reading-graphs year='2022'> tag that expands to a standard set of charts.
# Requires chart data to be passed through document options.
Kramdown::Parser::Html::HTML_ELEMENT["x-reading-graphs"] = true

class Kramdown::Converter::PostHtml < Kramdown::Converter::Html
  def convert_html_element(el, indent)
    case el.value
    when "x-tikz"
      tikz_code = el.children.select {|c| c.type == :text }.map(&:value).join.strip
      figcaption_el = el.children.find {|c| c.type == :html_element && c.value == "figcaption" }
      figcaption_html = figcaption_el ? "\n  <figcaption>#{inner(figcaption_el, indent)}</figcaption>" : ""
      slug = options.fetch(:slug)
      url = TikzCompiler.svg_url(tikz_code, slug)
      options[:tikz_produced]&.push(url)
      "<figure class='tikz'>\n  <img src='#{url}' alt=''/>#{figcaption_html}\n</figure>\n"
    when "x-youtube"
      href = el.attr['href']
      title = el.children.map {|x| convert(x, indent) }.join.strip
      caption = title.length > 0 ? "<figcaption>#{title}</figcaption>" : ""
      id = href.split('/').last
      id = id.split('=').last # account for watch= style urls

      <<-HTML
        <figure>
          <div class='embed-youtube'>
            <iframe width="560" height="315" src="https://www.youtube.com/embed/#{id}" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
          </div>
          #{caption}
        </figure>
      HTML
    when "x-reading-graphs"
      book_data = options.fetch(:book_data)
      year = el.attr['year']
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
    else
      super
    end
  end
end

