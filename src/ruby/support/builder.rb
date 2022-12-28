require 'zlib'
require 'erb'
require 'yaml'

require 'support/hash_to_ostruct'
require 'support/html_utils'

module Actions; end

class Builder
  def initialize
    @templates = {}
  end

  def write_gzip(filename, data)
    Zlib::GzipWriter.open(filename) do |f|
      f.write(data)
    end
  end

  protected

  def load_template(file)
    @templates[file] ||= begin
      erb = ERB.new(File.read(file))
      erb.filename = File.expand_path(file)
      erb
    end
  end
end
