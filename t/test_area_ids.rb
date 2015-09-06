
require 'csv_to_popolo'
require 'minitest/autorun'
require 'json'

describe 'Bhutan' do
  subject { Popolo::CSV.new('t/data/malaysia.csv') }

  let(:ppl)   { subject.data[:persons] }
  let(:orgs)  { subject.data[:organizations] }
  let(:areas) { subject.data[:areas] }
  let(:mems)  { subject.data[:memberships] }
  let(:legm)  { mems.select { |m| m[:role] == 'member' } }

  describe 'Shaharuddin Ismail' do
    it 'should have one legislative membership' do
      legm.count { |m| m[:person_id] == 'person/shaharuddin_ismail' }.must_equal 1
    end

    it 'should have a source' do
      lm = legm.find { |m| m[:person_id] == 'person/shaharuddin_ismail' }
      lm[:area_id].must_equal 'P002'
      area = areas.find { |a| a[:id] == lm[:area_id] }
      area[:name].must_equal 'Kangar, Perlis'
      area[:type].must_equal 'constituency'
    end
  end
end
