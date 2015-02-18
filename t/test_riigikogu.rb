#!/usr/bin/ruby

require 'csv_to_popolo'
require 'minitest/autorun'

describe "riigikogu" do

  subject { 
    Popolo::CSV.from_file('t/data/riigikogu-members.csv')
  }

  let(:arto)  { subject.data[:persons].find { |i| i[:name] == 'Arto Aas' } }
  let(:mems)  { subject.data[:memberships].find_all { |i| i[:person_id] == arto[:id] } }

  it "should have a record" do
    arto.class.must_equal Hash
  end

  it "should have the correct id" do
    arto[:id].must_equal 'fe748f4d-3f50-4af8-8069-92a460978d2b'
  end

  it "should have nested faction info" do
    mems.count.must_equal 2
    party = mems.find { |m| m[:role] == 'party representative' }
    party[:organization][:name].must_equal 'Eesti Reformierakonna fraktsioon'
    party[:organization][:classification].must_equal 'party'
  end
end

