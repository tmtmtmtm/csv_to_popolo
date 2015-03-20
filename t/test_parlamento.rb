#!/usr/bin/ruby

require 'csv_to_popolo'
require 'minitest/autorun'
require 'json'
require 'json-schema'
require 'pry'

describe "parlamento" do

  subject { 
    Popolo::CSV.new('t/data/italy.csv')
  }

  let(:ppl)  { subject.data[:persons] }
  let(:orgs) { subject.data[:organizations] }
  let(:mems) { subject.data[:memberships] }

  # 687024,Grasso Pietro,Grasso,Partito Democratico,Lazio,Senate

  describe "grasso" do

    let(:member) { ppl.find { |i| i[:id] == '687024' } }
    let(:pmems)  { mems.find_all { |m| m[:person_id] == member[:id] } }

    it "should have the correct name" do
      member[:name].must_include 'Pietro'
    end

    it "should have the correct family_name" do
      member[:family_name].must_equal 'Grasso'
    end

    it "should have correct party info" do
      party_mem = pmems.find { |m| m[:role] == 'representative' }
      party = orgs.find { |o| o[:id] == party_mem[:organization_id] }
      party[:name].must_equal 'Partito Democratico'
      party[:classification].must_equal 'party'
    end

    it "should represent correct region" do
      leg_mem = pmems.find { |m| m[:role] == 'member' }
      leg_mem[:area][:name].must_equal 'Lazio'
    end

    it "should be in correct chamber" do
      leg_mem = pmems.find { |m| m[:role] == 'member' }
      chamber = orgs.find { |o| o[:id] == leg_mem[:organization_id] }
      chamber[:name].must_equal 'Senate'
    end

  end

  describe "validation" do

    it "should have no warnings" do
      subject.data[:warnings].must_be_nil
    end

    it "should validate" do
      json = JSON.parse(subject.data.to_json)
      %w(person organization membership).each do |type|
        # JSON::Validator.fully_validate("http://www.popoloproject.com/schemas/#{type}.json", json[type + 's'], :list => true).must_be :empty?
      end
    end
  end

end

