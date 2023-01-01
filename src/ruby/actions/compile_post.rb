require 'date'
require 'erb'
require 'yaml'

require 'support/load_index_metadata'

POST_TEMPLATE = ERB.new(File.read("src/erb/post.html.erb"))

module PostMethods
  def all_credits
   ([
      self.image&.feature_credit,
   ] + (self.credits || [])).compact
  end
end

def compile_post(fragment_file, metadata_file, out)
  fragment = File.read(fragment_file)
  metadata = YAML.load_file(metadata_file)
  metadata['date'] = DateTime.parse(metadata['date'])

  name = metadata['slug']

  @post = hash_to_ostruct(metadata).extend(PostMethods)
  @post.body_html = fragment

  metadata = load_index_metadata("out/metadata/index.yml")

  @site = hash_to_ostruct(metadata)

  html = POST_TEMPLATE.result(binding)

  Zlib::GzipWriter.open(out) do |f|
    f.write(html)
  end
end
