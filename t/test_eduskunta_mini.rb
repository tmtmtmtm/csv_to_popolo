require 'csv_to_popolo'
require 'minitest/autorun'
require 'json'

describe 'eduskunta' do
  subject { Popolo::CSV.new('t/data/eduskunta_mini.csv') }

  let(:pers) { subject.data[:persons] }
  let(:orgs) { subject.data[:organizations] }
  let(:mems) { subject.data[:memberships] }

  let(:aho)  { pers.find { |i| i[:id] == '104' } }
  let(:amms) { mems.select { |i| i[:person_id] == '104' } }

  let(:ahde) { pers.find { |i| i[:id] == '103' } }

  it 'should have the correct name' do
    aho[:name].must_equal 'Aho Esko'
  end

  it 'should have alternate names' do
    alts = aho[:other_names].find_all { |n| n[:note] == 'alternate' }
    alts.count.must_equal 1
    alts.first[:name].must_equal 'Esko Aho'
  end

  it 'should be able to have multiple alternates' do
    alts = ahde[:other_names].find_all { |n| n[:note] == 'alternate' }
    alts.count.must_equal 2
    alts.sort_by { |n| n[:name] }.first[:name].must_equal 'Matti Ahde'
    alts.sort_by { |n| n[:name] }.last[:name].must_equal 'Matti Allan Ahde'
  end

  it 'should have the correct id' do
    aho[:id].must_equal '104'
  end

  it 'should have the correct family name' do
    aho[:family_name].must_equal 'Aho'
  end

  it 'should have the correct given names' do
    aho[:given_name].must_equal 'Esko Tapani'
  end

  it 'should have the correct dob' do
    aho[:birth_date].must_equal '1954-05-20'
  end

  it 'should have one legislative membership' do
    amms.count.must_equal 1
  end

  it 'should have one legislative Organization' do
    orgs.count { |o| o[:classification] == 'legislature' }.must_equal 1
  end

  it 'should have no executive Organization' do
    orgs.count { |o| o[:classification] == 'executive' }.must_equal 0
  end

  it 'should have no warnings' do
    subject.data[:warnings].must_be_nil
  end
end
