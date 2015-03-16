#!/usr/bin/ruby

require 'csv_to_popolo'
require 'minitest/autorun'
require 'json'
require 'json-schema'

describe "riigikogu" do

  subject { 
    Popolo::CSV.new('t/data/riigikogu-members.csv')
  }

  let(:orgs)  { subject.data[:organizations] }

  describe "arto" do

    let(:arto)  { subject.data[:persons].find { |i| i[:name] == 'Arto Aas' } }
    let(:mems)  { subject.data[:memberships].find_all { |m| m[:person_id] == arto[:id] } }

    it "should have a record" do
      arto.class.must_equal Hash
    end

    it "should have the correct id" do
      arto[:id].must_equal 'fe748f4d-3f50-4af8-8069-92a460978d2b'
    end

    it "should have correct faction info" do
      mems.count.must_equal 2
      party_mem = mems.find { |m| m[:role] == 'representative' }
      party = orgs.find { |o| party_mem[:organization_id] == o[:id] }
      party[:name].must_equal 'Eesti Reformierakonna fraktsioon'
      party[:classification].must_equal 'party'
      party_mem[:start_date].must_be_nil
      party_mem[:end_date].must_be_nil
    end

    it "should represent correct region" do
      mem = mems.find { |m| m[:role] == 'member' }
      mem[:area][:name].must_include 'Tallinna Kesklinna'
    end

    it "should have no start and end dates" do
      mem = mems.find { |m| m[:role] == 'representative' }
      mem[:start_date].must_be_nil
      mem[:end_date].must_be_nil
    end

  end

  describe "rein" do

    let(:rein)  { subject.data[:persons].find { |i| i[:name] == 'Rein Aidma' } }
    let(:mems)  { subject.data[:memberships].find_all { |m| m[:person_id] == rein[:id] } }

    it "should have start_date" do
      mems.count.must_equal 2
      mem = mems.find { |m| m[:role] == 'member' }
      mem[:start_date].must_equal '2011-04-02'
      mem[:end_date].must_be_nil
    end

  end

  describe "andres" do

    let(:andres) { subject.data[:persons].find { |i| i[:name] == 'Andres Jalak' } }
    let(:mems)   { subject.data[:memberships].find_all { |m| m[:person_id] == andres[:id] } }

    it "should have start_date and end_date" do
      mem = mems.find { |m| m[:role] == 'member' }
      mem[:start_date].must_equal '2011-12-06'
      mem[:end_date].must_equal '2014-03-26'
    end

  end

  describe "tõnis" do

    let(:tõnis) { subject.data[:persons].find { |i| i[:name] == 'Tõnis Kõiv' } }

    it "should handle unicode names" do
      tõnis[:name].must_equal 'Tõnis Kõiv'
    end

  end


  describe "validation" do

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

end

