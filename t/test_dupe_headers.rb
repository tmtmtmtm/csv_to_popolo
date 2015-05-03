#!/usr/bin/ruby

require 'csv_to_popolo'
require 'minitest/autorun'

describe "duplicate columns" do

  subject     { Popolo::CSV.new('t/data/broken_duplicate_headers.csv') }

  it "should warn about the duplicate name column" do
    subject.data[:warnings][:dupes].must_include :name
  end

end

