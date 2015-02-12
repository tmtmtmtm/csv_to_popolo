#!/usr/bin/ruby

require 'csv_to_popolo'
require 'minitest/autorun'

describe "tcamp" do

  subject { 
    Popolo::CSV.new('t/data/tcamp.csv')
  }

  describe "steiny" do

    let(:steiny)  { subject.data.first }

    it "should remap the given name" do
      steiny[:given_name].must_equal 'Tom'
    end

    it "should remap the family name" do
      steiny[:family_name].must_equal 'Steinberg'
    end

    it "should have rename the org name" do
      steiny[:memberships].first[:organization][:name].must_equal 'mySociety'
    end

    it "should include the twitter handle" do
      steiny[:contact_details].first[:type].must_equal 'twitter'
      steiny[:contact_details].first[:value].must_equal 'steiny'
    end

  end

  describe "orgless" do

    let(:orgless) { subject.data.last }

    it "should remap the given name" do
      orgless[:given_name].must_equal 'Orgless'
    end

    it "should have no family name name" do
      orgless[:family_name].must_be_nil
    end

    it "shouldn't have any memberships" do
      orgless[:memberships].must_be_nil
    end

    it "shouldn't have a twitter handle" do
      orgless[:contact_details].must_be_nil
    end

  end

end

