
require 'csv_to_popolo'
require 'minitest/autorun'
require 'json'

describe 'parlamento' do
  subject { Popolo::CSV.new('t/data/italy.csv') }

  let(:ppl)  { subject.data[:persons] }
  let(:orgs) { subject.data[:organizations] }
  let(:mems) { subject.data[:memberships] }

  describe 'Grasso' do
    let(:member) { ppl.find { |i| i[:id] == 'person/687024' } }
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
      leg_mem[:area][:name].must_equal 'Lazio'
    end

    it 'should be in correct chamber' do
      leg_mem = pmems.find { |m| m[:role] == 'member' }
      chamber = orgs.find { |o| o[:id] == leg_mem[:organization_id] }
      chamber[:name].must_equal 'Senate'
    end
  end

  describe 'Boldrini' do
    let(:member) { ppl.find { |i| i[:id] == 'person/686427' } }
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
      leg_mem[:area][:name].must_equal 'Sicilia 2'
    end

    it 'should be in correct chamber' do
      leg_mem = pmems.find { |m| m[:role] == 'member' }
      chamber = orgs.find { |o| o[:id] == leg_mem[:organization_id] }
      chamber[:name].must_equal 'Chamber of Deputies'
    end
  end

  describe 'validation' do
    it 'should have no warnings' do
      subject.data[:warnings].must_be_nil
    end
  end
end
