require 'rspec'
require 'fileutils'

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

$failure_counter = 0

def write_failed_html(doc)
  FileUtils.mkdir_p("tmp")
  file_name = "tmp/failed_html_#{$failure_counter}.html"
  File.write(file_name, actual.to_html)
  $failure_counter += 1
  file_name
end

RSpec::Matchers.define :have_content do |expected|
  match do |actual|
    actual.xpath("//text()").map(&:text).join(" ").gsub(/\s+/, " ").match(expected)
  end

  failure_message do |actual|
    "expected that #{write_failed_html(actual)} would include #{expected}"
  end

  failure_message_when_negated do |actual|
    "expected that #{write_failed_html(actual)} would not include #{expected}"
  end
end

RSpec::Matchers.define :have_xpath do |expected|
  match do |actual|
    actual.xpath(expected).length >= 1
  end

  failure_message do |actual|
    "expected that #{write_failed_html(actual)} would have xpath #{expected}"
  end

  failure_message_when_negated do |actual|
    FileUtils.mkdir_p("tmp")
    file_name = "tmp/failed_html_#{$failure_counter}.html"
    File.write(file_name, actual.to_html)
    $failure_counter += 1
    "expected that #{write_failed_html(actual)} would not include #{expected}"
  end
end
