require 'spec_helper'

feature 'home page' do
  it 'shows a title' do
    visit '/'
    expect(page).to have_content(/Xavier Shay/i)
  end

  it 'shows an index of all posts' do
    visit '/'
    click_link 'A System for Email'
    expect(page).to have_content("A System for Email")
    expect(page).to have_content("you need to be able to move fast")
  end

  it 'has posts at consistent urls' do
    visit '/articles/a-system-for-email.html'
    expect(page).to have_content("A System for Email")
    expect(page).to have_content("you need to be able to move fast")
  end

  it 'segments posts by year'
end
