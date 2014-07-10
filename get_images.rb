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

@birds['birds'].each do |bird|
	puts bird['common_name']

	next if bird['old_filename'].empty?
	next if File.exists? bird['new_filename']

	data = eat("http:#{bird['old_filename']}")

	File.open(bird['new_filename'], "w") do |file|
		file.write(data)
	end
end