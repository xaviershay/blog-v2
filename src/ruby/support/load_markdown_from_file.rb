require 'yaml'
require 'date'

YAML_FRONTMATTER_REGEX = /\A(---\s*\n.*?\n?)^---\s*\n/m

def truncate(str, n)
  return str if str.length < n

  str[0..n] + "…"
end

def load_markdown_from_file2(input_file)
  raw = File.read(input_file, encoding: 'utf-8')

  match = raw.match(YAML_FRONTMATTER_REGEX)

  if match
    metadata = YAML.load(match[0], permitted_classes: [Date])
    data = match.post_match

    [metadata, data]
  else
    raise "Invalid markdown file: #{input_file}"
  end
end
