require 'kramdown'

# Add a custom <x-spoiler> tag that converts into a <details> block with
# automatically generated <summary>

# Modifying these constants isn't documented and is likely brittle, but there
# isn't another great way to do it.
#
# See https://github.com/gettalong/kramdown/issues/694#issuecomment-1366202209
Kramdown::Parser::Html::HTML_CONTENT_MODEL_BLOCK << "x-spoiler"
Kramdown::Parser::Html::HTML_CONTENT_MODEL["x-spoiler"] = :block
Kramdown::Parser::Html::HTML_BLOCK_ELEMENTS << "x-spoiler"
Kramdown::Parser::Html::HTML_ELEMENT["x-spoiler"] = true

class Kramdown::Converter::BookHtml < Kramdown::Converter::Html
  def convert_html_element(el, indent)
    if el.value == "x-spoiler"
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

