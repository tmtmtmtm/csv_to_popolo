
require 'csv_to_popolo'
require 'minitest/autorun'
require 'json'

describe 'eduskunta' do
  subject { Popolo::CSV.new('t/data/eduskunta.csv') }

  let(:pers) { subject.data[:persons] }
  let(:orgs) { subject.data[:organizations] }
  let(:mems) { subject.data[:memberships] }

  let(:ahde) { pers.find     { |p| p[:id] == 'person/104' } }
  let(:amms) { mems.select { |m| m[:person_id] == 'person/104' } }
  let(:kesk) { orgs.find     { |o| o[:name] == 'Finnish Centre Party' } }

  it 'should set party name correctly' do
    kesk[:name].must_equal 'Finnish Centre Party'
  end

  it 'should set party id correctly' do
    kesk[:id].must_equal 'kesk'
  end

  it 'should have legislative membership' do
    pm = amms.select { |m| m[:organization_id] == 'legislature' }
    pm.size.must_equal 1
    pm.first[:role].must_equal 'member'
    pm.first[:on_behalf_of_id].must_equal 'kesk'
  end

  it 'should have legislative Organization' do
    orgs.count { |o| o[:classification] == 'legislature' }.must_equal 1
  end

  it 'should have no executive Organization' do
    orgs.count { |o| o[:classification] == 'executive' }.must_equal 0
  end

  it 'should have no warnings' do
    subject.data[:warnings].must_be_nil
  end
end
