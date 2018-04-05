require 'csv_to_popolo'
require 'minitest/autorun'

describe 'Wikimedia links' do
  subject { Popolo::CSV.new('t/data/australia.csv') }
  let(:abbott) { subject.data[:persons].find { |p| p[:name] == 'Tony Abbott' } }

  it 'should have a French Wikipedia link' do
    link = abbott[:links].find { |l| l[:note] == 'Wikipedia (fr)' }
    link[:url].must_equal 'https://fr.wikipedia.org/wiki/Tony_Abbott'
  end

  it 'should have an English Quote link' do
    link = abbott[:links].find { |l| l[:url] == 'https://en.wikiquote.org/wiki/Tony_Abbott' }
    link[:note].must_equal 'Wikiquote (en)'
  end

  it 'should have a Russian News link' do
    link = abbott[:links].find { |l| l[:note] == 'Wikinews (ru)' }
    link[:url].must_equal 'https://ru.wikinews.org/wiki/Категория:Тони_Эбботт'
  end

  it 'should have a Wikimedia Commons link' do
    links = abbott[:links].map { |l| l[:url] }.select { |url| url.include? 'commons' }
    links.must_include 'https://commons.wikimedia.org/wiki/Category:Tony_Abbott'
  end
end
