require 'webrick'
require 'set'

prefix = "out/site"
KNOWN_FILES = Set
  .new(Dir["#{prefix}/**/*"]
  .select {|x| File.file?(x) }
  .map {|x| x[prefix.length..-1] })

GZIP_EXTS = Set.new(%w(.html))

# Some content types are gzip'd on disk, since that's the format we need to
# upload to AWS and have them serve correctly. This servlet "knows" which
# formats are gzip'd and sets content encoding header appropriately.
class Server < WEBrick::HTTPServlet::DefaultFileHandler
  def do_GET(req, res)
    super(req, res)
    ext = File.extname(req.path)

    if GZIP_EXTS.include?(ext) || ext.empty?
      res['Content-Encoding'] = 'gzip'
    end
  end
end
server = WEBrick::HTTPServer.new(:Port => 4001)

server.mount '/', Server, File.join(prefix, 'index.html')
KNOWN_FILES.each do |file|
  server.mount file, Server, File.join(prefix, file)
end

trap("INT") {
  server.shutdown
}

server.start
