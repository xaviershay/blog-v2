Dir["data/posts/*.md"].each do |file|
  contents = File.read(file)

  contents.gsub!(/{{\s*YOUTUBE\s+(.*?)(?:\s+(.*?))?\s*}}/mi) do |match|
    inner = $2.strip
    "<x-youtube href='#{$1}'>\n#{inner}#{"\n" if inner.length > 0}</x-youtube>"
  end

  File.write(file, contents)
end
