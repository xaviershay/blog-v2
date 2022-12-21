require 'rspec'

RSpec.configure do |c|
  c.define_derived_metadata do |meta|
    meta[:aggregate_failures] = true
  end
end

APP_HOST = ENV.fetch("APP_HOST", "https://blog.xaviershay.com")

require 'nokogiri'
require 'net/http'

def visit(path)
  url = APP_HOST + path
  uri = URI.parse(url)
  response = Net::HTTP.get_response(uri)
  html = response.body
  @page = Nokogiri::HTML(html)
end

def page
  @page
end

RSpec::Matchers.define :have_content do |expected|
  match do |actual|
    actual.xpath("//text()").any? {|x| x.text.match(expected) }
  end

  def format_actual(actual)
    "\n" + actual
             .xpath("//text()")
             .map(&:text)
             .select {|x| x.strip.length > 0 }
             .join("\n")
  end

  failure_message do |actual|
    "expected that #{format_actual(actual)} would include #{expected}"
  end

  failure_message_when_negated do |actual|
    "expected that #{format_actual(actual)} would not include #{expected}"
  end
end
