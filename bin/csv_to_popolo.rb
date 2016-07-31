#!/usr/bin/ruby

require 'csv_to_popolo'
require 'json'

(file = ARGV.first) || fail("Usage: #{$PROGRAM_NAME} <csvfile>")

puts JSON.pretty_generate Popolo::CSV.new(file).data
