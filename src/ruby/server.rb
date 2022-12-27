require 'webrick'
require 'set'

require 'support/gzip_exts'

PREFIX = "out/site"
KNOWN_FILES = Set
  .new(Dir["#{PREFIX}/**/*"]
  .select {|x| File.file?(x) }
  .map {|x| x[PREFIX.length..-1] })

GZIP_EXTS_SET = Set.new(GZIP_EXTS)

# Some content types are gzip'd on disk, since that's the format we need to
# upload to AWS and have them serve correctly. This servlet "knows" which
# formats are gzip'd and sets content encoding header appropriately.
class Server < WEBrick::HTTPServlet::DefaultFileHandler
  def do_GET(req, res)
    to_match = @local_path[PREFIX.length .. -1]

    if req.path == to_match || req.path == "/" && to_match == "/index.html"
      super(req, res)
      ext = File.extname(req.path)

      if GZIP_EXTS_SET.include?(ext) || ext.empty?
        res['Content-Encoding'] = 'gzip'
      end
    else
      res.status = 404
      res['Content-Type'] = 'text/plain'
      res.body = "Not Found"
    end
  end
end
server = WEBrick::HTTPServer.new(:Port => 4001)

server.mount '/books/', Server, File.join(PREFIX, 'books/index.html')
KNOWN_FILES.each do |file|
  server.mount file, Server, File.join(PREFIX, file)
end
server.mount '/', Server, File.join(PREFIX, 'index.html')

trap("INT") {
  server.shutdown
}

server.start
