
require 'csv_to_popolo'
require 'minitest/autorun'
require 'json'

describe 'UK' do
  subject { Popolo::CSV.new('t/data/uk-hoc.csv') }

  describe 'Iain Duncan Smith' do

    let(:ids)   { subject.data[:persons].find { |i| i[:id] == 'person/Q302486' } }
    let(:names) { Hash[ids[:other_names].select { |n| n[:note] == 'multilingual' }.map { |n| [n[:lang], n[:name]] }] }

    it 'should have a default name' do
      ids[:name].must_equal 'Iain Duncan Smith'
    end

    it 'should be set in Ukrainian' do
      names['uk'].must_equal 'Іан Данкан Сміт' 
    end

    it 'should set code back correctly' do
      # comes in as 'name__de_ch'
      names['de-ch'].must_equal 'Iain Duncan Smith'
    end

  end
end
