
require 'csv_to_popolo'
require 'minitest/autorun'
require 'json'

describe 'UK' do
  subject { Popolo::CSV.new('t/data/uk-hoc.csv') }

  describe 'Iain Duncan Smith' do

    let(:ids)   { subject.data[:persons].find { |i| i[:id] == 'Q302486' } }
    let(:names) { Hash[ids[:other_names].select { |n| n[:note] == 'multilingual' }.map { |n| [n[:lang], n[:name]] }] }

    it 'should have a default name' do
      ids[:name].must_equal 'Iain Duncan Smith'
    end

    it 'should have no blank names' do
      ids[:other_names].find_all { |n| n[:name].to_s.empty? }.count.must_equal 0
    end

    it 'should be set in Ukrainian' do
      names['uk'].must_equal 'Іан Данкан Сміт' 
    end

    it 'should also have several Wikipedia links' do
      ids[:links].find { |l| l[:note] == 'Wikipedia (en)' }[:url].must_equal 'https://en.wikipedia.org/wiki/Iain_Duncan_Smith'
      ids[:links].find { |l| l[:note] == 'Wikipedia (zh)' }[:url].must_equal 'https://zh.wikipedia.org/wiki/施志安'
    end

    it 'should not have missing Wikipedia links' do
      ids[:links].find { |l| l[:note] == 'Wikipedia (eo)' }.must_be_nil
    end

    it 'should skip empty Wikipedia links' do
      ids[:links].find { |l| l[:note] == 'Wikipedia (ksh)' }.must_be_nil
    end

    it 'should set code back correctly' do
      # comes in as 'name__de_ch'
      names['de-ch'].must_equal 'Iain Duncan Smith'
    end

    it 'should not have an image' do
      ids[:images].must_be_nil
    end
  end

  describe 'Diane Abbot' do
    let(:da)   { subject.data[:persons].find { |i| i[:id] == 'Q153454' } }

    it 'should standardise facebook links' do
      da[:links].find { |l| l[:note] == 'facebook' }[:url].must_equal 'https://facebook.com/Dianeabbott'
    end
  end

end
