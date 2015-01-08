# -*- encoding : utf-8 -*-
require 'nokogiri'
require 'eat'
require 'pandoc-ruby'
require "unicode_utils/each_grapheme"
require 'json'

animals = JSON.parse(File.read('/Users/distributedlife/projects/animalwiki/assets/mammals.json'))                
animals['animals'].each do |animal| 
	current = "/Users/distributedlife/projects/animalwiki/assets/html/#{animal['new_filename']}"
	replacement = "/Users/distributedlife/projects/wiki_animal2/images/#{animal['official_name'].gsub(' ', '_').downcase}"

	unless File.exists? current
		puts animal['common_name']
		next
	end

	File.rename current, replacement
end