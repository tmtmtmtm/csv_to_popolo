
require 'csv_to_popolo'
require 'minitest/autorun'
require 'json'

describe "eduskunta" do

  subject { 
    Popolo::CSV.new('t/data/eduskunta_mini.csv')
  }

  let(:aho)  { subject.data[:persons].find { |i| i[:id] == '104' } }
  let(:mems) { subject.data[:memberships].find_all { |i| i[:person_id] == '104' } }

  it "should have the correct name" do
    aho[:name].must_equal 'Aho Esko'
  end

  it "should have the correct id" do
    aho[:id].must_equal '104'
  end

  it "should have the correct family name" do
    aho[:family_name].must_equal 'Aho'
  end

  it "should have the correct given names" do
    aho[:given_name].must_equal 'Esko Tapani'
  end

  it "should have the correct dob" do
    aho[:birth_date].must_equal '1954-05-20'
  end

  it "should have no legislative membership" do
    mems.count.must_equal 0
  end

  it "should have no legislative Organization" do
    subject.data[:organizations].find_all { |o| o[:classification] == 'legislature' }.count.must_equal 0
  end

  it "should have no executive Organization" do
    subject.data[:organizations].find_all { |o| o[:classification] == 'executive' }.count.must_equal 0
  end

  it "should have no warnings" do
    subject.data[:warnings].must_be_nil
  end

end


