require 'spec_helper'

feature 'home page' do
  it 'shows a title' do
    visit '/'
    expect(page).to have_content(/Xavier Shay/i)
  end
end
