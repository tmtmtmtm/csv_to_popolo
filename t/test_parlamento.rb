
require 'csv_to_popolo'
require 'minitest/autorun'
require 'json'

describe 'parlamento' do
  subject { Popolo::CSV.new('t/data/italy.csv') }

  let(:ppl)  { subject.data[:persons] }
  let(:orgs) { subject.data[:organizations] }
  let(:mems) { subject.data[:memberships] }

  describe 'Grasso' do
    let(:member) { ppl.find { |i| i[:id] == '687024' } }
    let(:pmems)  { mems.select { |m| m[:person_id] == member[:id] } }

    it 'should have the correct name' do
      member[:name].must_include 'Pietro'
    end

    it 'should have the correct family_name' do
      member[:family_name].must_equal 'Grasso'
    end

    it 'should have correct party info' do
      leg_mem = pmems.find { |m| m[:role] == 'member' }
      party = orgs.find { |o| o[:id] == leg_mem[:on_behalf_of_id] }
      party[:name].must_equal 'Partito Democratico'
      party[:classification].must_equal 'party'
    end

    it 'should represent correct region' do
      leg_mem = pmems.find { |m| m[:role] == 'member' }
      leg_mem[:area_id].must_equal 'area/lazio'
      subject.data[:areas].find { |a| a[:id] == leg_mem[:area_id] }[:name].must_equal 'Lazio'
    end

    it 'is in the legislature' do
      leg_mem = pmems.find { |m| m[:role] == 'member' }
      leg_mem[:organization_id].must_equal 'legislature'
    end
  end

  describe 'Boldrini' do
    let(:member) { ppl.find { |i| i[:id] == '686427' } }
    let(:pmems)  { mems.select { |m| m[:person_id] == member[:id] } }

    it 'should have the correct name' do
      member[:name].must_include 'Laura'
    end

    it 'should have the correct family_name' do
      member[:family_name].must_equal 'Boldrini'
    end

    it 'should have correct party info' do
      leg_mem = pmems.find { |m| m[:role] == 'member' }
      party = orgs.find { |o| o[:id] == leg_mem[:on_behalf_of_id] }
      party[:name].must_equal 'Sinistra ecologia e libertà'
      party[:classification].must_equal 'party'
    end

    it 'should represent correct region' do
      leg_mem = pmems.find { |m| m[:role] == 'member' }
      subject.data[:areas].find { |a| a[:id] == leg_mem[:area_id] }[:name].must_equal 'Sicilia 2'
    end

    it 'is in the legislature' do
      leg_mem = pmems.find { |m| m[:role] == 'member' }
      leg_mem[:organization_id].must_equal 'legislature'
    end
  end

  describe 'validation' do
    it 'should skip the house column' do
      subject.data[:warnings][:skipped].must_include :house
    end
  end
end
