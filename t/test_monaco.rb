
require 'csv_to_popolo'
require 'minitest/autorun'
require 'json'

describe 'monaco' do
  subject { Popolo::CSV.new('t/data/monaco.csv') }

  let(:pers) { subject.data[:persons] }
  let(:orgs) { subject.data[:organizations] }
  let(:mems) { subject.data[:memberships] }

  it 'should have have one person' do
    pc = pers.find_all { |p| p[:id] == 'Philippe-CLERISSI' }
    pc.size.must_equal 1
  end

  it 'should have have two memberships' do
    pc = mems.find_all { |p| p[:person_id] == 'Philippe-CLERISSI' }
    pc.size.must_equal 2
  end

  it 'should have one membership for an unknown party' do
    pc = mems.find_all { |p| p[:person_id] == 'Philippe-CLERISSI' }
    pc.find_all { |m| m[:on_behalf_of_id] == 'party/unknown' }.size.must_equal 1
  end


  it 'should have no warnings' do
    subject.data[:warnings].must_be_nil
  end
end
