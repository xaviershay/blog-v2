require 'kramdown'

require 'support/load_markdown_from_file'

module Actions; end
class Actions::Book
  def load_markdown(input)
    load_markdown_from_file2(input)
  end

  def markdown_to_metadata(input, output)
    metadata, _ = *load_markdown(input)

    File.write(output, metadata.to_yaml)
  end

  def markdown_to_html_fragment(input, output)
    _, data = load_markdown(input)

    doc = Kramdown::Document.new(data)

    html = doc.to_html

    File.write(output, html)
  end
end
