#!/usr/bin/ruby

require 'csv_to_popolo'
require 'minitest/autorun'

describe Popolo::CSV do

  describe "riigikogu" do

    subject { 
      Popolo::CSV.new('t/data/riigikogu-members.csv')
    }

    let(:arto)  { subject.data.find { |i| i[:name] == 'Arto Aas' } }

    it "should have a record" do
      arto.class.must_equal Hash
    end

    it "should have the correct id" do
      arto[:id].must_equal 'fe748f4d-3f50-4af8-8069-92a460978d2b'
    end

    it "should have nested faction info" do
      arto[:memberships].first[:organization][:name].must_equal 'Eesti Reformierakonna fraktsioon'
    end
  end

  describe "eduskunta" do

    subject { 
      Popolo::CSV.new('t/data/eduskunta.csv')
    }

    let(:ahde)  { subject.data.find { |i| i[:id] == 104 } }

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

    it "shouldn't have any memberships" do
      ahde[:memberships].must_be_nil
    end

  end

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

end 

