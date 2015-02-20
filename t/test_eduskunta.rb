#!/usr/bin/ruby

require 'csv_to_popolo'
require 'minitest/autorun'

describe "eduskunta" do

  subject { 
    Popolo::CSV.from_file('t/data/eduskunta.csv')
  }

  let(:ahde)  { subject.data[:persons].find           { |p| p[:id] == 104 } }
  let(:mems)  { subject.data[:memberships].find_all   { |m| m[:person_id] == 104 } }
  let(:kesk)  { subject.data[:organizations].find     { |o| o[:name] == 'Finnish Centre Party' } }

  it "should set party name correctly" do
    kesk[:name].must_equal 'Finnish Centre Party'
  end

  it "should set party id correctly" do
    kesk[:id].must_equal 'kesk'
  end

  it "should only have correct party membership" do
    pm = mems.find_all { |m| m[:role] == 'party representative' }
    pm.count.must_equal 1
    pm.first[:organization_id].must_equal 'kesk'
  end

end
