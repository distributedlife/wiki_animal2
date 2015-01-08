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

@animals['animals'].each_with_index do |animal, index|
	puts "#{animal['common_name']} #{index}/#{@animals['animals'].length}"

	next if animal['old_filename'].empty?
	next if File.exists? animal['new_filename']

	data = nil

	while data.nil?
		begin
			data = eat("http:#{animal['old_filename']}")
		rescue
		end
	end

	File.open(animal['new_filename'], "w") do |file|
		file.write(data)
	end
end