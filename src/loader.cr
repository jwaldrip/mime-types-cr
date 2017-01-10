require "json"
puts JSON.parse(File.read(ARGV[0])).to_json
