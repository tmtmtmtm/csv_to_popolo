#!/usr/bin/ruby

require 'json'
require 'json-schema'

file = ARGV[0] or fail "Usage: #{$PROGRAM_NAME} <json-file>"
json = JSON.parse(File.read(file))

%w(person organization membership).each do |type|
  JSON::Validator.validate!(
    "http://www.popoloproject.com/schemas/#{type}.json", 
    json[type + 's'], 
    cache_schemas: true, list: true
  )
end
