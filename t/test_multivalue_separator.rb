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
    cameron[:contact_details].count.must_equal 2
    cameron[:contact_details][0][:type].must_equal 'email'
    cameron[:contact_details][0][:value].must_equal 'camerond@parliament.uk'
    cameron[:contact_details][1][:type].must_equal 'email'
    cameron[:contact_details][1][:value].must_equal 'info@davidcameron.com'
  end

end
