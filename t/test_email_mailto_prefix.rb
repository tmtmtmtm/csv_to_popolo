
require 'csv_to_popolo'
require 'minitest/autorun'

describe 'email: value' do
  subject { Popolo::CSV.new('t/data/dominican_republic.csv') }
  let(:persons) { subject.data[:persons] }
  let(:person1) { persons[2] }

  it 'should not be prefixed with mailto:' do
    person1[:email].wont_include 'mailto:'
  end
end

describe ':contact_details email value' do
  subject { Popolo::CSV.new('t/data/dominican_republic.csv') }
  let(:persons) { subject.data[:persons] }
  let(:person1) { persons[2] }

  it 'should not be prefixed with mailto:' do
    person1[:contact_details][0][:value].wont_include 'mailto:'
  end
end
