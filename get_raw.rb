# -*- encoding : utf-8 -*-
require 'nokogiri'
require 'eat'
require 'pandoc-ruby'
require "unicode_utils/each_grapheme"
require "./animals"

animals = get_animals

def make_wiki_uri name
	"http://en.wikipedia.org/wiki/#{name}"
end

def get_wiki_content name
	@wikipedia_call ||= {}

	while @wikipedia_call[name].nil?
		begin
			@wikipedia_call[name] ||= Nokogiri::XML(eat(make_wiki_uri(name), :timeout => 10))
		rescue => e
			puts e
		end
	end

	@wikipedia_call[name]    
end

def clean xml
	xml
end

animals.each do |animal|
	puts animal
	next if File.exists? "raw/#{animal.downcase}.html" and !File.zero? "raw/#{animal.downcase}.html"
	File.open("raw/#{animal.downcase}.html", "w") do |file| 
		file.write clean(get_wiki_content animal)
	end
end