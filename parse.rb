# -*- encoding : utf-8 -*-
require 'nokogiri'
require 'eat'
require 'pandoc-ruby'
require "unicode_utils/each_grapheme"

memo = {}

def make_wiki_uri name
	"http://en.wikipedia.org/wiki/#{name}"
end

def get_wiki_content name
	@wikipedia_call ||= {}
	@wikipedia_call[name] ||= Nokogiri::XML(eat(make_wiki_uri(name), :timeout => 10))

	@wikipedia_call[name]    
end

def report xml
	common_name = xml.at_xpath("//h1[@id='firstHeading']/span").text()

	conservation_status = ""
	['Extinct','Extinct in the Wild','Critically Endangered','Endangered','Vulnerable','Near Threatened','Least Concern','Data Deficient','Not Evaluated'].each do |status|
		next if xml.at_xpath("//table[@class='infobox biota']").content.scan(status).empty?
			
		conservation_status = status 
	end

	kingdom = xml.at_xpath("//span[@class='kingdom']/a").text()
	phylum = xml.at_xpath("//span[@class='phylum']/a").text()
	klass = xml.at_xpath("//span[@class='class']/a").text()
	order = xml.at_xpath("//span[@class='order']/a").text()
	family = xml.at_xpath("//span[@class='family']/a").text()
	genus = xml.at_xpath("//span[@class='genus']/i/a").text()
	species = xml.at_xpath("//span[@class='species']/i/a").text()
	subspecies = xml.at_xpath("//span[@class='subspecies']/i/b").text()

	if xml.at_xpath("//span[@class='trinomial']/i").text().nil?
		official_name = xml.at_xpath("//span[@class='binomial']/i").text()
	else
		official_name = xml.at_xpath("//span[@class='trinomial']/i").text()
	end

	spacer = "\t"
	puts "#{common_name}#{spacer}#{conservation_status}#{spacer}#{kingdom}#{spacer}#{phylum}#{spacer}#{klass}#{spacer}#{order}#{spacer}#{family}#{spacer}#{genus}#{spacer}#{species}#{spacer}#{subspecies}#{spacer}#{official_name}"
end

report(get_wiki_content "Rothschild's_giraffe")