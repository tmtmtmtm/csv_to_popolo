
require 'csv_to_popolo'
require 'minitest/autorun'
require 'json'

describe 'Bhutan' do
  subject { Popolo::CSV.new('t/data/bhutan.csv') }

  let(:ppl)  { subject.data[:persons] }
  let(:orgs) { subject.data[:organizations] }
  let(:mems) { subject.data[:memberships] }
  let(:legm) { mems.select { |m| m[:role] == 'member' } }

  let(:pm) { ppl.find { |i| i[:id] == '1'  } }
  let(:mp) { ppl.find { |i| i[:id] == '20' } }

  describe 'The Prime Minster' do
    it 'should have two memberships' do
      mems.count { |m| m[:person_id] == pm[:id] }.must_equal 2
    end

    it 'should have Legislative Membership sources' do
      lm = mems.find { |m| m[:person_id] == pm[:id] && m[:organization_id] == 'legislature' }
      lm[:sources].count.must_equal 1
      lm[:sources].first[:url].must_include 'www.nab.gov.bt'
    end

    it 'should not have Executive Membership sources' do
      em = mems.find { |m| m[:person_id] == pm[:id] && m[:organization_id] == 'executive' }
      em[:sources].must_be_nil
    end

    it 'should have no Person source' do
      pm[:sources].must_be_nil
    end
  end

  describe 'A Plain MP' do
    it 'should have only one membership' do
      mems.count { |m| m[:person_id] == mp[:id] }.must_equal 1
    end

    it 'should have a legislative membership' do
      legm.find { |m| m[:person_id] == mp[:id] }[:organization_id].must_equal 'legislature'
    end
  end

  # Allow multiple parties with same name, as long as different IDs
  describe 'Same-named orgs' do
    it 'should have three parties' do
      parties = orgs.select { |o| o[:classification] == 'party' }
      parties.count.must_equal 3
      parties.select { |o| o[:name] == "People's Democratic Party" }.count.must_equal 2
    end
  end

  describe 'validation' do
    it 'should have no warnings' do
      subject.data[:warnings].must_be_nil
    end
  end
end
