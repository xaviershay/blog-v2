require 'kramdown'

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

# <x-youtube> tag that embeds a youtube video with optional caption. Adds a
# <div> wrapper to allow for mobile responsiveness.
Kramdown::Parser::Html::HTML_CONTENT_MODEL_BLOCK << "x-youtube"
Kramdown::Parser::Html::HTML_CONTENT_MODEL["x-youtube"] = :block
Kramdown::Parser::Html::HTML_BLOCK_ELEMENTS << "x-youtube"
Kramdown::Parser::Html::HTML_ELEMENT["x-youtube"] = true

class Kramdown::Converter::PostHtml < Kramdown::Converter::Html
  def convert_html_element(el, indent)
    case el.value
    when "x-youtube"
      href = el.attr['href']
      title = el.children.map {|x| convert(x, indent) }.join.strip
      caption = title.length > 0 ? "<figcaption>#{title}</figcaption>" : ""
      id = href.split('/').last

      <<-HTML.lines.map {|x| (" " * indent) + x }.join
<figure>
  <div class='embed-youtube'>
    <iframe width="560" height="315" src="https://www.youtube.com/embed/#{id}" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
  </div>
  #{caption}
</figure>
      HTML
    else
      super
    end
  end
end

