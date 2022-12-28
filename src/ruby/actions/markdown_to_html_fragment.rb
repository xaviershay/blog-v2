require 'kramdown'

require 'support/load_markdown_from_file'

def markdown_to_html_fragment(input, output)
  metadata, data = load_markdown_from_file(input)

  out = File.join("out/site", metadata.fetch("url"))

  book_data = YAML.load_file("out/metadata/book_index.yml").fetch('stats')
  doc = Kramdown::Document.new(data, :book_data => book_data)

  html = doc.to_post_html

  File.write(output, html)
end
