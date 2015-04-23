#!/usr/bin/ruby

require 'csv_to_popolo'
require 'minitest/autorun'
require 'json'
require 'json-schema'

describe "riigikogu" do

  subject { 
    Popolo::CSV.new('t/data/riigikogu-multi.csv')
  }

  let(:orgs)  { subject.data[:organizations] }

  describe "riigikogu" do

    let(:riigikogu) { orgs.find { |o| o[:classification] == 'legislature' } }

    it "should have two terms" do
      riigikogu[:legislative_periods].count.must_equal 2
    end

    it "should have know them as legislative periods" do
      riigikogu[:legislative_periods].first[:classification].must_equal 'legislative period'
    end

    it "should have the right names" do
      riigikogu[:legislative_periods].map { |t| t[:name] }.sort.must_equal ['Riigikogu XII', 'Riigikogu XIII']
    end

  end

  describe "arto in XII and XIII" do

    let(:arto)  { subject.data[:persons].find { |i| i[:name] == 'Arto Aas' } }
    let(:mems)  { subject.data[:memberships].find_all { |m| m[:person_id] == arto[:id] && m[:role] == 'member' } }

    it "should have the correct id" do
      arto[:id].must_equal 'fe748f4d-3f50-4af8-8069-92a460978d2b'
    end

    it "should have two legislative memberships" do
      mems.count.must_equal 2
    end

    it "should have been in Riigikogu XII" do
      mem = mems.find { |m| m[:legislative_period_id] == 'term/riigikogu_xii' }
      party = orgs.find { |o| o[:id] == mem[:on_behalf_of_id] }
      party[:name].must_equal 'Eesti Reformierakonna fraktsioon'
      party[:classification].must_equal 'party'
    end

    it "should have been in Riigikogu XIII" do
      mem = mems.find { |m| m[:legislative_period_id] == 'term/riigikogu_xiii' }
      party = orgs.find { |o| o[:id] == mem[:on_behalf_of_id] }
      party[:name].must_equal 'Eesti Reformierakonna fraktsioon'
      party[:classification].must_equal 'party'
    end

  end

  describe "rein in XII" do

    let(:rein)  { subject.data[:persons].find { |i| i[:name] == 'Rein Aidma' } }
    let(:mems)  { subject.data[:memberships].find_all { |m| m[:person_id] == rein[:id] && m[:role] == 'member' } }

    it "should have one legislative membership" do
      mems.count.must_equal 1
    end

    it "should have been in Riigikogu XII" do
      mems.find_all { |m| m[:legislative_period_id] == 'term/riigikogu_xii' }.count.must_equal 1
    end

    it "should not have been in Riigikogu XIII" do
      mems.find_all { |m| m[:legislative_period_id] == 'term/riigikogu_xiii' }.count.must_equal 0
    end

    it "should have start_date" do
      mems.count.must_equal 1
      mems.first[:start_date].must_equal '2011-04-02'
      mems.first[:end_date].must_be_nil
    end

  end

  describe "savisaar in XIII" do

    let(:edgar) { subject.data[:persons].find { |i| i[:name] == 'Edgar Savisaar' } }
    let(:mems)  { subject.data[:memberships].find_all { |m| m[:person_id] == edgar[:id] && m[:role] == 'member' } }

    it "should have one legislative membership" do
      mems.count.must_equal 1
    end

    it "should not have been in Riigikogu XII" do
      mems.find_all { |m| m[:legislative_period_id] == 'term/riigikogu_xii' }.count.must_equal 0
    end

    it "should have been in Riigikogu XIII" do
      mems.find_all { |m| m[:legislative_period_id] == 'term/riigikogu_xiii' }.count.must_equal 1
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

