#!/usr/bin/ruby

require 'csv_to_popolo'
require 'minitest/autorun'
require 'json'
require 'json-schema'

describe "eduskunta" do

  subject { 
    Popolo::CSV.new('t/data/eduskunta.csv')
  }

  let(:ahde)  { subject.data[:persons].find           { |p| p[:id] == '104' } }
  let(:mems)  { subject.data[:memberships].find_all   { |m| m[:person_id] == '104' } }
  let(:kesk)  { subject.data[:organizations].find     { |o| o[:name] == 'Finnish Centre Party' } }

  it "should set party name correctly" do
    kesk[:name].must_equal 'Finnish Centre Party'
  end

  it "should set party id correctly" do
    kesk[:id].must_equal 'kesk'
  end

  it "should only have correct party membership" do
    pm = mems.find_all { |m| m[:role] == 'representative' }
    pm.count.must_equal 1
    pm.first[:organization_id].must_equal 'kesk'
  end

  it "should have legislative Organization" do
    subject.data[:organizations].find_all { |o| o[:classification] == 'legislature' }.count.must_equal 1
  end

  it "should have no executive Organization" do
    subject.data[:organizations].find_all { |o| o[:classification] == 'executive' }.count.must_equal 0
  end

  it "should have no warnings" do
    subject.data[:warnings].must_be_nil
  end

  it "should validate" do
    json = JSON.parse(subject.data.to_json)
    %w(person organization membership).each do |type|
      JSON::Validator.fully_validate("http://www.popoloproject.com/schemas/#{type}.json", json[type + 's'], :list => true).must_be :empty?
    end
  end

end
