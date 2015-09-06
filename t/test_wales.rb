require 'csv_to_popolo'
require 'minitest/autorun'

describe 'welsh assembly' do
  subject { Popolo::CSV.new('t/data/welsh_assembly.csv') }
  let(:pers) { subject.data[:persons] }
  let(:orgs) { subject.data[:organizations] }
  let(:mems) { subject.data[:memberships] }

  describe 'Asghar' do
    let(:asghar) { pers.find { |i| i[:id] == 'person/130' } }

    it 'should have the correct name' do
      asghar[:name].must_equal 'Mohammad Asghar'
    end

    it 'should have other_names' do
      asghar[:other_names].class.must_equal Array
      asghar[:other_names].count.must_equal 1
      asghar[:other_names].first.class.must_equal Hash
      asghar[:other_names].first[:name].must_equal 'Oscar'
    end

    it 'should have a phone number' do
      asghar[:contact_details].class.must_equal Array
      asghar[:contact_details].count.must_equal 1
      asghar[:contact_details].first.class.must_equal Hash
      asghar[:contact_details].first[:type].must_equal 'phone'
      asghar[:contact_details].first[:value].must_equal '01633 220022'
    end

    it 'should have a website' do
      asghar[:links].class.must_equal Array
      asghar[:links].count.must_equal 1
      asghar[:links].first.class.must_equal Hash
      asghar[:links].first[:url].must_equal 'http://www.senedd.assemblywales.org/mgUserInfo.aspx?UID=130'
      asghar[:links].first[:note].must_equal 'website'
    end
  end

  describe 'Parties' do
    let(:parties) { orgs.select { |o| o[:classification] == 'party' } }

    it 'should have unique parties' do
      names = parties.map { |p| p[:name] }
      names.count.must_equal names.uniq.count
    end
  end

  describe 'Legislature' do
    let(:assembly) { orgs.select { |o| o[:classification] == 'legislature' } }

    it 'should have one legislature' do
      assembly.count.must_equal 1
    end

    it 'should have a correctly named legislature' do
      assembly.first[:name].must_equal 'Legislature'
    end
  end

  describe 'First Minister' do
    let(:executive) { orgs.find { |o| o[:id] == 'executive' } }
    let(:fmin) { pers.find   { |p| p[:id] == 'person/102' } }
    let(:fmem) { mems.select { |m| m[:person_id] == fmin[:id] } }

    it 'should have two memberships' do
      fmem.count.must_equal 2
    end

    it 'should have Assembly membership' do
      fmem.find { |m| m[:role] == 'member' }[:area_id].must_equal 'area/bridgend'
    end

    it 'should have Executive membership' do
      execm = fmem.select { |m| m[:organization_id] == executive[:id] }
      execm.count.must_equal 1
      execm.first[:role].must_equal 'The First Minister'
    end
  end

  describe 'validation' do
    it 'should have skipped unknown columns' do
      subject.data[:warnings][:skipped].must_include :en_title
    end
  end
end
