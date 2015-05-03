#!/usr/bin/ruby

require 'csv_to_popolo'
require 'minitest/autorun'
require 'json'

describe "mac" do

  subject     { Popolo::CSV.new('t/data/mac.csv') }

  describe "counts" do

    it "should have two people" do
      subject.data[:persons].count.must_equal 2
    end

    it "should have correct gender" do
      subject.data[:persons].last[:gender].must_equal 'Female'
    end

  end

  describe "validation" do

    it "should have no warnings" do
      subject.data[:warnings].must_be_nil
    end

  end

end

