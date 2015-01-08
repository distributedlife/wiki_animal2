# -*- encoding : utf-8 -*-
require 'nokogiri'
require 'eat'
require 'pandoc-ruby'
require "unicode_utils/each_grapheme"
require 'json'
require "./animals"

animals = get_animals
@images = JSON.parse(File.read('wiki-images.json'))['images']
@image_count = 0

@images.each_with_index do |image, index|
	puts "#{index}/#{@images.length}"

	next if File.exists? image['new'] and !File.zero? image['new']
	
	data = nil
	skipped = 0
	while data.nil? and skipped < 5
		begin
			data = eat("http:#{image['old']}")
		rescue => e
			puts e
			data = nil
			sleep(1)
			skipped = skipped + 1
		end
	end

	File.open(image['new'], "w") do |file|
		file.write(data)
	end
end