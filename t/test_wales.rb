#!/usr/bin/ruby

require 'csv_to_popolo'
require 'minitest/autorun'
require 'json'
require 'json-schema'

describe "welsh assembly" do

  subject { 
    Popolo::CSV.new('t/data/welsh_assembly.csv')
  }

  describe "Asghar" do

    let(:asghar) { subject.data[:persons].find { |i| i[:id] == '130' } }

    it "should have the correct name" do
      asghar[:name].must_equal 'Mohammad Asghar'
    end

    it "should have other_names" do
      asghar[:other_names].class.must_equal Array
      asghar[:other_names].count.must_equal 1
      asghar[:other_names].first.class.must_equal Hash
      asghar[:other_names].first[:name].must_equal 'Oscar'
    end

    it "should have a phone number" do
      asghar[:contact_details].class.must_equal Array
      asghar[:contact_details].count.must_equal 1
      asghar[:contact_details].first.class.must_equal Hash
      asghar[:contact_details].first[:type].must_equal 'phone'
      asghar[:contact_details].first[:value].must_equal '01633 220022'
    end

  end

  describe "Parties" do

    let(:parties) { subject.data[:organizations].find_all { |o| o[:classification] == 'party' } }

    it "should have unique parties" do
      names = parties.map { |p| p[:name] }
      names.count.must_equal names.uniq.count
    end

  end

  describe "Legislature" do

    let(:assembly) { subject.data[:organizations].find_all { |o| o[:classification] == 'legislature' } }

    it "should have one legislature" do
      assembly.count.must_equal 1
    end

    it "should have a correctly named legislature" do
      assembly.first[:name].must_equal 'Legislature'
    end

  end

  describe "First Minister" do
    
    let(:executive) { subject.data[:organizations].find { |o| o[:id] == 'executive' } }
    let(:fmin) { subject.data[:persons].find         { |p| p[:id] == '102' } }
    let(:mems) { subject.data[:memberships].find_all { |m| m[:person_id] == fmin[:id] } }

    it "should have three memberships" do
      mems.count.must_equal 3
    end

    it "should have Assembly membership" do
      mems.find { |m| m[:role] == 'member' }[:area][:name].must_equal 'Bridgend'
    end

    it "should have Party membership" do
      mems.find { |m| m[:role] == 'representative' }[:organization_id].must_match /^party/
    end

    it "should have Executive membership" do
      execm = mems.find_all { |m| m[:organization_id] == executive[:id] }
      execm.count.must_equal 1
      execm.first[:role].must_equal 'The First Minister'
    end

  end

  describe "validation" do
    it "should validate" do
      json = JSON.parse(subject.data.to_json)
      %w(person organization membership).each do |type|
        JSON::Validator.fully_validate("http://www.popoloproject.com/schemas/#{type}.json", json[type + 's'], :list => true).must_be :empty?
      end
    end
  end

end

