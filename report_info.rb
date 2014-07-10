# -*- encoding : utf-8 -*-
require 'nokogiri'
require 'eat'
require 'pandoc-ruby'
require "unicode_utils/each_grapheme"
require 'json'

@birds = []

File.open("birds.json") do |file|
	@birds = JSON.parse(file.read)
end

categories = ['conservation_status', 'kingdom', 'phylum', 'klass', 'order', 'family', 'genus', 'species', 'countries', 'colours']
results = {}
categories.each do |category|
	results[category] = []
end

@birds.each do |bird|
	categories.each do |category|
		next if bird[category].empty?

		results[category] << bird[category] unless results[category].include? bird[category]
	end
end

puts "records: #{@birds.length}"
categories.each do |category|
	puts "#{category}: #{results[category].length}"
end

puts results['conservation_status']