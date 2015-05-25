
require 'csv_to_popolo'
require 'minitest/autorun'
require 'json'

describe 'riigikogu' do
  subject { Popolo::CSV.new('t/data/riigikogu-members.csv') }

  let(:orgs)  { subject.data[:organizations] }

  describe 'arto' do
    let(:arto)  { subject.data[:persons].find { |i| i[:name] == 'Arto Aas' } }
    let(:mems)  { subject.data[:memberships].select { |m| m[:person_id] == arto[:id] } }

    it 'should have a record' do
      arto.class.must_equal Hash
    end

    it 'should have the correct id' do
      arto[:id].must_equal 'person/fe748f4d-3f50-4af8-8069-92a460978d2b'
    end

    it 'should have correct faction info' do
      mems.count.must_equal 1
      leg_mem = mems.find { |m| m[:role] == 'member' }

      party = orgs.find { |o| o[:id] == leg_mem[:on_behalf_of_id] }
      party[:name].must_equal 'Eesti Reformierakonna fraktsioon'
      party[:classification].must_equal 'party'
    end

    it 'should represent correct region' do
      mem = mems.find { |m| m[:role] == 'member' }
      mem[:area][:name].must_include 'Tallinna Kesklinna'
    end

    it 'should have no start and end dates' do
      mem = mems.find { |m| m[:role] == 'member' }
      mem[:start_date].must_be_nil
      mem[:end_date].must_be_nil
    end
  end

  describe 'rein' do
    let(:rein)  { subject.data[:persons].find { |i| i[:name] == 'Rein Aidma' } }
    let(:mems)  { subject.data[:memberships].select { |m| m[:person_id] == rein[:id] } }

    it 'should have start_date' do
      mems.count.must_equal 1
      mem = mems.find { |m| m[:role] == 'member' }
      mem[:start_date].must_equal '2011-04-02'
      mem[:end_date].must_be_nil
    end
  end

  describe 'andres' do
    let(:andres) { subject.data[:persons].find { |i| i[:name] == 'Andres Jalak' } }
    let(:mems)   { subject.data[:memberships].select { |m| m[:person_id] == andres[:id] } }

    it 'should have start_date and end_date' do
      mem = mems.find { |m| m[:role] == 'member' }
      mem[:start_date].must_equal '2011-12-06'
      mem[:end_date].must_equal '2014-03-26'
    end
  end

  describe 'tõnis' do
    let(:tonis) { subject.data[:persons].find { |i| i[:name] == 'Tõnis Kõiv' } }

    it 'should handle unicode names' do
      tonis[:name].must_equal 'Tõnis Kõiv'
    end
  end
end
