require 'csv_to_popolo'
require 'minitest/autorun'

describe 'multivalue_separator' do
  subject { Popolo::CSV.new('t/data/multiple_contacts_in_cells.csv') }

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
    cameron[:links].count.must_equal 2
    cameron[:links][0][:url].must_equal 'https://twitter.com/David_Cameron'
    cameron[:links][0][:note].must_equal 'twitter'
    cameron[:links][1][:url].must_equal 'https://twitter.com/Number10gov'
    cameron[:links][1][:note].must_equal 'twitter'
    # Then the contact_details:
    twitter_contacts = cameron[:contact_details].select { |c| c[:type] == 'twitter' }
    twitter_contacts.count.must_equal 2
    twitter_contacts[0][:value].must_equal 'David_Cameron'
    twitter_contacts[1][:value].must_equal 'Number10gov'
  end

end
