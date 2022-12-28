require 'cgi'

def h(input)
  CGI.escapeHTML input
end
