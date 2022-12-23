require 'spec_helper'

RSpec.describe "the blog" do
  describe 'home page' do
    before(:all) { visit '/' }
    it('has title') { expect(page).to have_content(/Xavier Shay/i) }
    it('has index of posts') do
      expect(page).to have_content("2021: A Review")
      expect(page).to have_content("A System for Email")
    end

    it 'segments posts by year'
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

  describe 'custom youtube tag' do
    describe 'processing' do
      before(:all) { visit '/articles/2015-reading-list.html' }
      it('has removed tag') { expect(page).to_not have_content("YOUTUBE") }
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

  describe 'atom feed' do
    before(:all) { visit "/feed.xml" }
    it('has id') { expect(page).to have_xpath("//feed/id") }
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
end
