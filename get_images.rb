# -*- encoding : utf-8 -*-
require 'nokogiri'
require 'eat'
require 'pandoc-ruby'
require "unicode_utils/each_grapheme"
require 'json'

@animals = []

File.open(ARGV[0]) do |file|
	@animals = JSON.parse(file.read)
end

@animals['animals'].each do |animal|
	puts animal['common_name']

	next if animal['old_filename'].empty?
	next if File.exists? animal['new_filename']

	data = eat("http:#{animal['old_filename']}")

	File.open(animal['new_filename'], "w") do |file|
		file.write(data)
	end
end