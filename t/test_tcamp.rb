#!/usr/bin/ruby

require 'csv_to_popolo'
require 'minitest/autorun'

describe "tcamp" do

  subject { 
    Popolo::CSV.from_file('t/data/tcamp.csv')
  }

  describe "steiny" do

    let(:steiny)  { subject.data[:persons].first }

    it "should remap the given name" do
      steiny[:given_name].must_equal 'Tom'
    end

    it "should remap the family name" do
      steiny[:family_name].must_equal 'Steinberg'
    end

    it "should rename the org name" do
      steiny[:memberships].find { |m| m[:role] == 'party representative' }[:organization][:name].must_equal 'mySociety'
    end

    it "should include the twitter handle" do
      steiny[:contact_details].first[:type].must_equal 'twitter'
      steiny[:contact_details].first[:value].must_equal 'steiny'
    end

  end

  describe "orgless" do

    let(:orgless) { subject.data[:persons].last }

    it "should remap the given name" do
      orgless[:given_name].must_equal 'Orgless'
    end

    it "should have no family name name" do
      orgless[:family_name].must_be_nil
    end

    it "shouldn't have a twitter handle" do
      orgless[:contact_details].must_be_nil
    end

    it "should only have bare legislative membership" do
      orgless[:memberships].count.must_equal 1
      orgless[:memberships].first[:role].must_equal 'representative'
    end

  end

  describe "combo" do

    let(:ids) { subject.data[:persons].map { |p| p[:id] } }

    it "should give everyone unique ids" do
      ids.length.must_equal 3
      ids.uniq.length.must_equal 3
    end

    it "should give everyone ids of form /person/<ID>" do
      ids.sample.must_match /^person\/\d+$/
    end

  end

end

