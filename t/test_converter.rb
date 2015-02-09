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

  end

end 

