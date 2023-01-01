require 'spec_helper'

RSpec.describe "the blog" do
  describe 'home page' do
    before(:all) { visit '/' }
    it('has title') { expect(page).to have_content(/Xavier Shay/i) }
    it('has index of posts') do
      expect(page).to have_content("2021 Review")
      expect(page).to have_content("A System for Email")
    end

    it 'segments posts by year' do
      expect(page).to have_xpath("//h2[text()='2022']")
    end
  end

  describe 'post page' do
    before(:all) { visit '/articles/a-system-for-email.html' }
    it('has title') { expect(page).to have_content("A System for Email") }
    it('has date') { expect(page).to have_content("Nov 22, 2020") }
    it('has content') {
      expect(page).to have_content("you need to be able to move fast")
    }

    it('has feature image credit') {
      expect(page).to have_content("Person Using Silver Laptop")
      expect(page).to have_content("John Schnobrich")
    }

    it('has opengraph tags to support card preview on FB, Twitter, et al') do
      expect(page).to have_xpath("//head/meta[@property='og:title']")
      expect(page).to have_xpath("//head/meta[@property='og:description']")
      expect(page).to have_xpath("//head/meta[@property='og:image']")
    end
  end

  describe 'book index page' do
    before(:all) { visit '/books/' }
    it('has title') { expect(page).to have_content("Books I've Read") }
  end

  describe 'book page' do
    before(:all) { visit '/books/getting-together.html' }

    it('has opengraph tags to support card preview on FB, Twitter, et al') do
      expect(page).to have_xpath("//head/meta[@property='og:title']")
      expect(page).to have_xpath("//head/meta[@property='og:description']")
      expect(page).to have_xpath("//head/meta[@property='og:image']")
    end
  end

  describe 'custom youtube tag' do
    describe 'processing' do
      before(:all) { visit '/articles/2015-reading-list.html' }
      it('has removed tag') { expect(page).to_not have_content("x-youtube") }
      it('has included an iframe') { expect(page).to have_xpath('//iframe') }
    end

    it 'is used everywhere instead of hardcoded iframe embed' do
      posts = `grep -rl "<iframe" data/posts`.lines
      expect(posts).to eq([])
    end

    it 'is used everywhere instead of hardcoded object embed' do
      posts = `grep -rl "<object" data/posts`.lines
      expect(posts).to eq([])
    end
  end

  describe 'custom reading graphs tag' do
    describe 'processing' do
      before(:all) { visit '/articles/2022-reading-list.html' }
      it('has removed tag') { expect(page).to_not have_content("x-reading-graphs") }
      it('has included chart') { expect(page).to have_xpath("//table[contains(@class,'charts-css')]") }
    end
  end

  describe 'atom feed' do
    before(:all) { visit "/feed.xml" }
    it('has id') { expect(page).to have_xpath("//feed/id[text()='#{APP_HOST}']") }
    it('has title') { expect(page).to have_xpath("//feed/title") }
    it('has author') {
      expect(page).to have_xpath("//feed/author/name")
      expect(page).to have_xpath("//feed/author/uri")
      expect(page).to have_xpath("//feed/author/email")
    }

    it('does not include html in ID') do
      expect(page).to_not have_xpath("//feed/entry/id[contains(text(), '.html')]")
    end

    it('includes /articles prefix in ID') do
      expect(page).to have_xpath("//feed/entry/id[contains(text(), '/articles/')]")
    end
  end

  describe 'book atom feed' do
    before(:all) { visit "/books/feed.xml" }
    it('has id') { expect(page).to have_xpath("//feed/id[text()='#{APP_HOST}/books/']") }
    it('has title') { expect(page).to have_xpath("//feed/title[contains(text(), 'Books')]") }
    it('has author') {
      expect(page).to have_xpath("//feed/author/name")
      expect(page).to have_xpath("//feed/author/uri")
      expect(page).to have_xpath("//feed/author/email")
    }

    it('does not include html in ID') do
      expect(page).to_not have_xpath("//feed/entry/id[contains(text(), '.html')]")
    end

    it('includes /books prefix in ID') do
      expect(page).to have_xpath("//feed/entry/id[contains(text(), '/books/')]")
    end
  end
end
