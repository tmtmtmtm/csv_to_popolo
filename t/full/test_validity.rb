#!/usr/bin/ruby

require 'minitest/autorun'

require 'csv_to_popolo'
require 'json-schema'
require 'json'

describe "validation" do

  it "should have no warnings" do
    Dir['t/data/*.csv'].reject { |f| f.include? 'broken' }.each do |f|
      next if f.end_with?('mac.csv') # FIXME this has invalid dates
      # puts "Checking Popolo validity for #{f}"
      json = JSON.parse(Popolo::CSV.new(f).data.to_json)
      
      %w(person organization membership).each do |type|
        JSON::Validator.fully_validate("http://www.popoloproject.com/schemas/#{type}.json", json[type + 's'], :list => true).must_be :empty?
      end
    end
  end

end

