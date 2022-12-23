require 'support/load_markdown_from_file'

def markdown_to_metadata(input, output)
  metadata, _ = *load_markdown_from_file(input)

  File.write(output, metadata.to_yaml)
end
