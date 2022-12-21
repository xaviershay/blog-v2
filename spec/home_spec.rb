require 'spec_helper'

RSpec.describe 'home page' do
  it 'includes expected content and metadata' do
    visit '/'
    # Title
    expect(page).to have_content(/Xavier Shay/i)
    # Post title
    expect(page).to have_content("A System for Email")
  end

  it 'segments posts by year'
end

RSpec.describe 'URL structure' do
  it 'has posts at consistent urls' do
    visit '/articles/a-system-for-email.html'
    expect(page).to have_content("A System for Email")
    expect(page).to have_content("you need to be able to move fast")
  end
end
