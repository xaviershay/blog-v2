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
end
