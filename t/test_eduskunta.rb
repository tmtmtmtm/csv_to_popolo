#!/usr/bin/ruby

require 'csv_to_popolo'
require 'minitest/autorun'

describe "eduskunta" do

  subject { 
    Popolo::CSV.from_file('t/data/eduskunta.csv')
  }

  let(:ahde)  { subject.data[:persons].find { |i| i[:id] == 104 } }

  it "should have the correct name" do
    ahde[:name].must_equal 'Aho Esko'
  end

  it "should have the correct family name" do
    ahde[:family_name].must_equal 'Aho'
  end

  it "should have the correct given names" do
    ahde[:given_name].must_equal 'Esko Tapani'
  end

  it "should have the correct dob" do
    ahde[:birth_date].must_equal '1954-05-20'
  end

  it "should only have bare legislative membership" do
    ahde[:memberships].count.must_equal 1
    ahde[:memberships].first[:role].must_equal 'representative'
  end

end
