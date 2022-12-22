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
end
