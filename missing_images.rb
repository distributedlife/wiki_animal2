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
	next if bird['old_filename'].empty?

	puts "#{bird['common_name']}: #{bird['new_filename']}" unless File.exists? bird['new_filename']
end