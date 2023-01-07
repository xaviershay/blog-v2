require 'zlib'

files = Dir['old_site/**/*.html']

files.each do |file|
  new_file = file.gsub("old_site", "new_site")

  Zlib::GzipReader.open(file) {|of|
    Zlib::GzipReader.open(new_file) {|nf|
      if of.read != nf.read
        puts file
      end
    }
  }
end
