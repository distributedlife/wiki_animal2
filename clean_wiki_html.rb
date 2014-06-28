# -*- encoding : utf-8 -*-
require 'nokogiri'
require 'eat'
require 'pandoc-ruby'
require "unicode_utils/each_grapheme"

@images = []

def make_wiki_uri name
	"http://en.wikipedia.org/wiki/#{name}"
end

def get_wiki_content name
	@wikipedia_call ||= {}
	@wikipedia_call[name] ||= Nokogiri::XML(File.read("Sable"))
	# @wikipedia_call[name] ||= Nokogiri::XML(eat(make_wiki_uri(name), :timeout => 10))

	@wikipedia_call[name]    
end

def remove_comments xml
	xml.children.each do |child|
		child.remove and next if child.comment?
		
		remove_comments child
	end
end

def remove_empty xml
	xml.children.each do |child|
		remove_empty(child) and next if child.methods.select {|m| m == "empty?"}.length == 0

		child.remove and next if child.empty?

		remove_empty child
	end
end

def fix_links xml
	xml.children.each do |child|
		child.remove and next if child.name == "a" and child.text[0] == "["
		child.remove and next if child.name == "a" and child.text.empty? and child.attr("class") != "image"
		
		if child.name == "a" and child.attr("class") != "image"
			child.add_previous_sibling "<span>#{child.text}</span>"
			child.remove
		end

		if child.name == "a" and child.attr("class") == "image"
			image = child.at_xpath("img")

			old_file_name = image.attr('src')
			new_file_name = "images/#{old_file_name.split('/').last}"
			image.set_attribute('src', new_file_name)
			@images << {:old => old_file_name, :new => new_file_name}
			
			child.add_previous_sibling image
			child.remove
		end
		
		fix_links child
	end
end

def clean xml
	div_id = ['mw-page-base', 'mw-head-base', 'mw-navigation', 'footer', 'mw-js-message', 'siteNotice', 'contentSub', 'jump-to-nav', 'catlinks', 'toc']
	div_class = ['printfooter', 'visualClear', 'dablink', 'reflist columns references-column-width']
	table_class = ['infobox biota', 'metadata mbox-small plainlinks', 'navbox']
	anchors = ['top']
	span_class = ['mw-editsection']

	xml.at_xpath("//head").remove

	div_id.each {|id| xml.at_xpath("//div[@id='#{id}']").remove }
	div_class.each {|klass| xml.at_xpath("//div[@class='#{klass}']").remove }
	table_class.each {|klass| xml.at_xpath("//table[@class='#{klass}']").remove }
	anchors.each {|id| xml.at_xpath("//a[@id='#{id}']").remove }
	span_class.each do |klass|
		while !xml.at_xpath("//span[@class='#{klass}']").nil?
			xml.at_xpath("//span[@class='#{klass}']").remove
		end
	end

	xml.at_xpath("//span[@id='See_also']/../../ul").remove
	xml.at_xpath("//span[@id='See_also']").parent.remove
	xml.at_xpath("//span[@id='References']").parent.remove
	xml.at_xpath("//span[@id='External_links']/../../ul").remove
	xml.at_xpath("//span[@id='External_links']").parent.remove

	xml.at_xpath("//noscript").remove

	while !xml.at_xpath("//sup").nil?
		xml.at_xpath("//sup").remove
	end

	xml.at_xpath("//body").children.each {|child| child.remove if child.name == "script"}

	remove_comments xml
	remove_empty xml

	fix_links xml
	
	xml
end

File.open("CleanSable.html", "w") do |file| 
	file.write clean(get_wiki_content "Sable")
end

# @images.each do |image|
# 	data = eat(image[:old_file_name])
# 
# 	File.open(image[:new_file_name], "w") do |file|
# 		file.write(data)
# 	end
# end