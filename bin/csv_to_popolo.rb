#!/usr/bin/ruby

require 'csv_to_popolo'
require 'json'

file = ARGV.first or raise "Usage: #$0 <csvfile>"

puts JSON.pretty_generate Popolo::CSV.new(file).data
