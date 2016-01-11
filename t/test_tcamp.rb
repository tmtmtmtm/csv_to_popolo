
require 'csv_to_popolo'
require 'minitest/autorun'
require 'json'

describe 'tcamp' do
  subject     { Popolo::CSV.new('t/data/tcamp.csv') }
  let(:orgs)  { subject.data[:organizations] }

  describe 'steiny' do
    let(:steiny) { subject.data[:persons].first }
    let(:mems)   { subject.data[:memberships].select { |m| m[:person_id] == steiny[:id] } }

    it 'should remap the given name' do
      steiny[:given_name].must_equal 'Tom'
    end

    it 'should remap the family name' do
      steiny[:family_name].must_equal 'Steinberg'
    end

    it 'should rename the org name' do
      leg_mem = mems.find { |m| m[:role] == 'member' }
      party = orgs.find { |o| o[:id] == leg_mem[:on_behalf_of_id] }
      party[:name].must_equal 'mySociety'
    end

    it 'should standardise the twitter handle' do
      steiny[:contact_details].find { |c| c[:type] == 'twitter' }[:value].must_equal 'steiny'
    end

    it 'should have a phone number' do
      steiny[:contact_details].find { |c| c[:type] == 'cell' }[:value].must_equal 'tomsphone'
    end

    it 'should have no fax' do
      steiny[:contact_details].find { |c| c[:type] == 'fax' }.must_be_nil
    end

    it 'should have a wikipedia page' do
      steiny[:links].find { |l| l[:note] == 'wikipedia' }[:url].must_equal 'http://en.wikipedia.org/wiki/Tom_Steinberg'
    end

    it 'should have identifiers' do
      steiny[:identifiers].find { |l| l[:scheme] == 'tcampid' }[:identifier].must_equal '14'
      steiny[:identifiers].select { |l| l[:scheme] == 'efp' and l[:identifier] == 'a40' }.count.must_equal 1
      # TODO: later, when we combine Person records separately...
      steiny[:identifiers].select { |l| l[:scheme] == 'efp' and l[:identifier] == 'a50' }.count.must_equal 0
    end
  end

  describe 'ellen' do
    let(:ellen)  { subject.data[:persons][1] }

    it 'should standardise the twitter handle' do
      ellen[:contact_details].find { |c| c[:type] == 'twitter' }[:value].must_equal 'EllnMllr'
    end

    it 'should have a phone number' do
      ellen[:contact_details].find { |c| c[:type] == 'cell' }[:value].must_equal 'ellensphone'
    end

    it 'should have no fax' do
      ellen[:contact_details].find { |c| c[:type] == 'fax' }[:value].must_equal 'ellensfax'
    end

    it 'should have an identifier' do
      ellen[:identifiers].find { |l| l[:scheme] == 'tcampid' }[:identifier].must_equal '10'
      ellen[:identifiers].find { |l| l[:scheme] == 'efp' }[:identifier].must_equal 'c49'
    end
  end

  describe 'orgless' do
    let(:orgless) { subject.data[:persons].last }
    let(:mems)    { subject.data[:memberships].select { |m| m[:person_id] == orgless[:id] } }

    it 'should have no family name name' do
      orgless[:family_name].must_be_nil
    end

    it "shouldn't have a twitter handle" do
      orgless[:contact_details].must_be_nil
    end

    it 'should only have one legislative membership' do
      mems.count.must_equal 1
    end

    it 'should not have an identifier' do
      orgless.key?(:identifiers).must_equal false
    end
  end

  describe 'combo' do
    let(:ids) { subject.data[:persons].map { |p| p[:id] } }

    it 'should give everyone unique ids' do
      ids.length.must_equal 3
      ids.uniq.length.must_equal 3
    end

    it 'should generate ids' do
      ids.first.must_equal 'tom_steinberg'
    end
  end

  describe 'validation' do
    it 'should have no warnings' do
      subject.data[:warnings].must_be_nil
    end
  end
end
