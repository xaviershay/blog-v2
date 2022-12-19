require 'webrick'
require 'set'

MIME_TYPES = {
  "html" => "text/html"
}
prefix = "out/site"
KNOWN_FILES = Set.new(Dir["#{prefix}/**/*"].select {|x| File.file?(x) }.map {|x| x[prefix.length..-1] })
puts KNOWN_FILES

def mime_type_for(ext)
  MIME_TYPES.fetch(ext, "text/plain")
end

# class Server < WEBrick::HTTPServlet::AbstractServlet
#   def do_GET (request, response)
#     ext = File.extname(request.path)[1..-1]
# 
#     if KNOWN_FILES.include?(request.path)
#       path = "out/site#{request.path}"
#       content = File.read(path)
#       response.status = 200
#       puts ext
#       response['Content-Type'] = mime_type_for(ext)
#       response.body = 'Hello, World! ' + request.path
#     else
#       response.status = 404
#       response.body = 'Not Found'
#     end
#   end
# 
#   def do_POST (request, response)
#     puts "this is a post request who received #{request.body}"
#   end
# end
GZIP_EXTS = Set.new(%w(.html))

class Server < WEBrick::HTTPServlet::DefaultFileHandler
  def do_GET(req, res)
    super(req, res)
    ext = File.extname(req.path)
    res['Content-Encoding'] = 'gzip' if GZIP_EXTS.include?(ext)
  end
end
server = WEBrick::HTTPServer.new(:Port => 4001)

KNOWN_FILES.each do |file|
  server.mount file, Server, File.join(prefix, file)
end

trap("INT") {
    server.shutdown
}

server.start
