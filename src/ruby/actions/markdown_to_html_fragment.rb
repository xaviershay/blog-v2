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

  File.write(output, html)
end
