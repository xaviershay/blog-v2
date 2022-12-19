require 'rspec'
require 'capybara'
require 'capybara/rspec'

Capybara.configure do |c|
  c.run_server = false
  c.default_driver = ENV.fetch("DRIVER", "selenium_chrome_headless").to_sym
  c.app_host = ENV.fetch("APP_HOST", "https://blog.xaviershay.com")
  c.default_max_wait_time = 1
end

RSpec.configure do |c|
  c.define_derived_metadata do |meta|
    meta[:aggregate_failures] = true
  end
end
