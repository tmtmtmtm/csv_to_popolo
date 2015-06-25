
require 'csv_to_popolo'
require 'minitest/autorun'
require 'json'

describe 'Bhutan' do
  subject { Popolo::CSV.new('t/data/malaysia.csv') }

  let(:ppl)  { subject.data[:persons] }
  let(:orgs) { subject.data[:organizations] }
  let(:mems) { subject.data[:memberships] }
  let(:legm) { mems.select { |m| m[:role] == 'member' } }

  describe 'Shaharuddin Ismail' do
    it 'should have one legislative membership' do
      legm.count { |m| m[:person_id] == 'person/shaharuddin_ismail' }.must_equal 1
    end

    it 'should have a source' do
      lm = legm.find { |m| m[:person_id] == 'person/shaharuddin_ismail' }
      lm[:area][:name].must_equal 'Kangar, Perlis'
      lm[:area][:id].must_equal 'P002'
    end
  end
end
