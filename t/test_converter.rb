#!/usr/bin/ruby

require 'csv_to_popolo'
require 'minitest/autorun'

describe Popolo::CSV do

  subject { 
    Popolo::CSV.new('t/data/riigikogu-members.csv')
  }

  describe "data" do

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

end 

