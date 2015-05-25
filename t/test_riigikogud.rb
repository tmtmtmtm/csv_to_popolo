require 'csv_to_popolo'
require 'minitest/autorun'
require 'json'

describe 'riigikogu' do
  subject { Popolo::CSV.new('t/data/riigikogu-multi.csv') }

  let(:pers) { subject.data[:persons] }
  let(:orgs) { subject.data[:organizations] }
  let(:mems) { subject.data[:memberships] }
  let(:legm) { mems.select { |m| m[:role] == 'member' } }

  describe 'riigikogu' do
    let(:riigikogu) { orgs.find { |o| o[:classification] == 'legislature' } }
    let(:terms) { riigikogu[:legislative_periods] }

    it 'should have two terms' do
      terms.count.must_equal 2
    end

    it 'should have know them as legislative periods' do
      terms.first[:classification].must_equal 'legislative period'
    end

    it 'should have the right names' do
      terms.map { |t| t[:name].split.last }.sort.must_equal %w(XII XIII)
    end
  end

  describe 'arto in XII and XIII' do
    let(:arto) { pers.find { |i| i[:name] == 'Arto Aas' } }
    let(:amms) { legm.select { |m| m[:person_id] == arto[:id] } }

    it 'should have the correct id' do
      arto[:id].must_equal 'person/fe748f4d-3f50-4af8-8069-92a460978d2b'
    end

    it 'should have two legislative memberships' do
      amms.count.must_equal 2
    end

    it 'should have been in Riigikogu XII' do
      mem = amms.find { |m| m[:legislative_period_id] == 'term/riigikogu_xii' }
      party = orgs.find { |o| o[:id] == mem[:on_behalf_of_id] }
      party[:name].must_equal 'Eesti Reformierakonna fraktsioon'
      party[:classification].must_equal 'party'
    end

    it 'should have been in Riigikogu XIII' do
      mem = amms.find { |m| m[:legislative_period_id] == 'term/riigikogu_xiii' }
      party = orgs.find { |o| o[:id] == mem[:on_behalf_of_id] }
      party[:name].must_equal 'Eesti Reformierakonna fraktsioon'
      party[:classification].must_equal 'party'
    end
  end

  describe 'rein in XII' do
    let(:rein) { pers.find { |i| i[:name] == 'Rein Aidma' } }
    let(:amms) { legm.select { |m| m[:person_id] == rein[:id] } }

    it 'should have one legislative membership' do
      amms.count.must_equal 1
    end

    it 'should have been in Riigikogu XII' do
      amms.first[:legislative_period_id].must_equal 'term/riigikogu_xii'
    end

    it 'should have start_date' do
      amms.count.must_equal 1
      amms.first[:start_date].must_equal '2011-04-02'
      amms.first[:end_date].must_be_nil
    end
  end

  describe 'savisaar in XIII' do
    let(:edgar) { pers.find { |i| i[:name] == 'Edgar Savisaar' } }
    let(:amms)  { legm.select { |m| m[:person_id] == edgar[:id] } }

    it 'should have one legislative membership' do
      amms.count.must_equal 1
    end

    it 'should have been in Riigikogu XIII' do
      amms.first[:legislative_period_id].must_equal 'term/riigikogu_xiii'
    end
  end

  describe 'validation' do
    it 'should have no warnings' do
      subject.data[:warnings].must_be_nil
    end
  end
end
