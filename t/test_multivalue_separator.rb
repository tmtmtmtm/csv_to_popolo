require 'csv_to_popolo'
require 'minitest/autorun'

describe 'multivalue_separator' do
  subject { Popolo::CSV.new('t/data/multiple_values_in_cells.csv') }

  let(:pers) { subject.data[:persons] }
  let(:cameron) { pers.find { |p| p[:name] == 'David Cameron' } }
  let(:doe) { pers.find { |p| p[:name] == 'John Doe' } }

  it 'should find both mobile numbers for John Doe' do
    doe[:contact_details].count.must_equal 3
    cell_contacts = doe[:contact_details].select { |c| c[:type] == 'cell' }
    cell_contacts[0][:value].must_equal '777'
    cell_contacts[1][:value].must_equal '888'
  end

  it 'should output two email addresses for David Cameron and set the top-level email field' do
    cameron[:email].must_equal 'camerond@parliament.uk'
    email_contacts = cameron[:contact_details].select { |c| c[:type] == 'email' }
    email_contacts.count.must_equal 2
    email_contacts[0][:value].must_equal 'camerond@parliament.uk'
    email_contacts[1][:value].must_equal 'info@davidcameron.com'
  end

  it 'should include multiple Twitter usernames in both contact_details and links' do
    # Check the links first...
    twitter_links = cameron[:links].select { |l| l[:note] == 'twitter' }
    twitter_links.count.must_equal 2
    twitter_links[0][:url].must_equal 'https://twitter.com/David_Cameron'
    twitter_links[1][:url].must_equal 'https://twitter.com/Number10gov'
    # Then the contact_details:
    twitter_contacts = cameron[:contact_details].select { |c| c[:type] == 'twitter' }
    twitter_contacts.count.must_equal 2
    twitter_contacts[0][:value].must_equal 'David_Cameron'
    twitter_contacts[1][:value].must_equal 'Number10gov'
  end

  it 'should include both Facebook usernames for David Cameron' do
    facebook_links = cameron[:links].select { |l| l[:note] == 'facebook' }
    facebook_links.count.must_equal 3
    facebook_links[0][:url].must_equal 'https://facebook.com/DavidCameronOfficial'
    facebook_links[1][:url].must_equal 'https://facebook.com/SomeOtherDavidCameron'
    facebook_links[2][:url].must_equal 'https://facebook.com/UnqualifiedDavidCameron'
  end

end
