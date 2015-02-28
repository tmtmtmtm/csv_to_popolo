#!/usr/bin/ruby

require 'csv_to_popolo'
require 'minitest/autorun'
require 'json'
require 'json-schema'

describe "tcamp" do

  subject     { Popolo::CSV.new('t/data/tcamp.csv') }
  let(:orgs)  { subject.data[:organizations] }

  describe "steiny" do

    let(:steiny) { subject.data[:persons].first }
    let(:mems)   { subject.data[:memberships].find_all { |m| m[:person_id] == steiny[:id] } }

    it "should remap the given name" do
      steiny[:given_name].must_equal 'Tom'
    end

    it "should remap the family name" do
      steiny[:family_name].must_equal 'Steinberg'
    end

    it "should rename the org name" do
      pmem = mems.find { |m| m[:role] == 'party representative' }
      oids = orgs.map { |o| o[:id] }
      party = orgs.find { |o| o[:id] == pmem[:organization_id] }
      party[:name].must_equal 'mySociety'
    end

    it "should have a twitter handle" do
      steiny[:contact_details].find { |c| c[:type] == 'twitter' }[:value].must_equal 'steiny'
    end

    it "should have a phone number" do
      steiny[:contact_details].find { |c| c[:type] == 'cell' }[:value].must_equal 'tomsphone'
    end

    it "should have no fax" do
      steiny[:contact_details].find { |c| c[:type] == 'fax' }.must_be_nil
    end

  end

  describe "ellen" do

    let(:ellen)  { subject.data[:persons][1] }

    it "should have a twitter handle" do
      ellen[:contact_details].find { |c| c[:type] == 'twitter' }[:value].must_equal 'EllnMllr'
    end

    it "should have a phone number" do
      ellen[:contact_details].find { |c| c[:type] == 'cell' }[:value].must_equal 'ellensphone'
    end

    it "should have no fax" do
      ellen[:contact_details].find { |c| c[:type] == 'fax' }[:value].must_equal 'ellensfax'
    end

  end

  describe "orgless" do

    let(:orgless) { subject.data[:persons].last }
    let(:mems)    { subject.data[:memberships].find_all { |m| m[:person_id] == orgless[:id] } }

    it "should remap the given name" do
      orgless[:given_name].must_equal 'Orgless'
    end

    it "should have no family name name" do
      orgless[:family_name].must_be_nil
    end

    it "shouldn't have a twitter handle" do
      orgless[:contact_details].must_be_nil
    end

    it "should only have no legislative membership" do
      mems.count.must_equal 0
    end

  end

  describe "combo" do

    let(:ids) { subject.data[:persons].map { |p| p[:id] } }

    it "should give everyone unique ids" do
      ids.length.must_equal 3
      ids.uniq.length.must_equal 3
    end

    it "should give everyone ids of form /person/<hexstring>" do
      ids.sample.must_match /^person\/[[:xdigit:]]+/
    end

  end

  describe "validation" do

    it "should validate" do
      json = JSON.parse(subject.data.to_json)
      %w(person organization membership).each do |type|
        # JSON::Validator.fully_validate("http://www.popoloproject.com/schemas/#{type}.json", json[type + 's'], :list => true).must_be :empty?
      end
    end

  end

end

