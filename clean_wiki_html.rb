# -*- encoding : utf-8 -*-
require 'nokogiri'
require 'eat'
require 'pandoc-ruby'
require "unicode_utils/each_grapheme"
require 'json'
require "./animals"

animals = get_animals
@images = []
@image_count = 0

def make_wiki_uri name
	"http://en.wikipedia.org/wiki/#{name}"
end

def get_wiki_content name
	@wikipedia_call ||= {}
	@wikipedia_call[name] ||= Nokogiri::XML(File.read("raw/#{name.downcase}.html"))
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

def fix_links xml, filename
	xml.children.each do |child|
		child.remove and next if child.name == "a" and child.text[0] == "["
		child.remove and next if child.name == "a" and child.text.empty? and child.attr("class") != "image"
		
		if child.name == "a" and child.attr("class") != "image"
			#TODO: a version that keeps internal links and turns them into local references.
			child.add_previous_sibling "<span>#{child.text}</span>"
			child.remove
		end

		if child.name == "a" and child.attr("class") == "image"
			image = child.at_xpath("img")

			old_file_name = image.attr('src')
			new_file_name = "images/#{filename}_#{@image_count}"
			@image_count += 1

			image.set_attribute('src', new_file_name)
			@images << {:old => old_file_name, :new => new_file_name}
			
			# child.add_previous_sibling image
			child.remove
		end
		
		fix_links child, filename
	end
end

def remove xml, xpath
	to_delete = xml.at_xpath(xpath)
	to_delete.remove unless to_delete.nil?
end

def remove_parent xml, xpath
	to_delete = xml.at_xpath(xpath)

	to_delete = to_delete.parent unless to_delete.nil?
	to_delete.remove unless to_delete.nil?
end

def clean xml, filename
	div_id = [
		'mw-page-base', 'mw-head-base', 'mw-navigation', 'footer', 
		'mw-js-message', 'siteNotice', 'contentSub', 'jump-to-nav', 'catlinks', 
		'toc', 'firstHeading'
	]
	div_class = [
		'printfooter', 'visualClear', 'dablink', 
		'reflist columns references-column-width', 'hatnote', 'reflist'
	]
	table_class = [
		'infobox biota', 'metadata mbox-small plainlinks', 'navbox', 
		'metadata plainlinks stub',
		'metadata plainlinks ambox ambox-content ambox-multiple_issues compact-ambox'
	]
	anchors = ['top']
	span_class = ['mw-editsection']

	xml.at_xpath("//head").remove

	div_id.each do |id| 
		# remove xml, "//div[@id='#{id}']"
		to_delete = xml.at_xpath("//div[@id='#{id}']")
		to_delete.remove unless to_delete.nil?
	end

	div_class.each do |klass| 
		to_delete = xml.at_xpath("//div[@class='#{klass}']")
		to_delete.remove unless to_delete.nil?
	end

	table_class.each do |klass|
		to_delete = xml.at_xpath("//table[@class='#{klass}']")
		to_delete.remove unless to_delete.nil?
	end

	anchors.each do |id| 
		to_delete = xml.at_xpath("//a[@id='#{id}']")
		to_delete.remove unless to_delete.nil?
	end

	span_class.each do |klass|
		while !xml.at_xpath("//span[@class='#{klass}']").nil?
			xml.at_xpath("//span[@class='#{klass}']").remove
		end
	end

	remove xml, "//span[@id='See_also']/../../ul"
	remove_parent xml, "//span[@id='See_also']"
	remove xml, "//span[@id='References']/../../ul"
	remove_parent xml, "//span[@id='References']"
	remove xml, "//span[@id='External_links']/../../ul"
	remove_parent xml, "//span[@id='External_links']"
	remove xml, "//span[@id='Gallery']/../../ul"
	remove_parent xml, "//span[@id='Gallery']"
	remove xml, "//span[@id='Footnotes']/../../ul"
	remove_parent xml, "//span[@id='Footnotes']"
	remove xml, "//span[@id='Notes']/../../ul"
	remove_parent xml, "//span[@id='Notes']"
	remove xml, "//span[@id='Further_reading']/../../ul"
	remove_parent xml, "//span[@id='Further_reading']"

	xml.at_xpath("//noscript").remove

	while !xml.at_xpath("//sup").nil?
		xml.at_xpath("//sup").remove
	end

	xml.at_xpath("//body").children.each do 
		|child| child.remove if child.name == "script"
	end

	remove_comments xml
	remove_empty xml

	fix_links xml, filename
	
	xml
end

def get_images_only xml, filename
	fix_links xml, filename
end

def iterate_over xml, base_xpath
	['/a', '/i/a', '/i/b', '/i', '/b'].each do |xpath|
		node = xml.at_xpath("#{base_xpath}#{xpath}")
		next if node.nil?

		return node.text()
	end

	""
end

def get_official_name xml
	if iterate_over(xml, "//span[@class='trinomial']") == ""
		iterate_over(xml, "//span[@class='binomial']")
	else
		iterate_over(xml, "//span[@class='trinomial']")
	end
end

animals.each_with_index do |animal, index|
	puts "#{animal} #{index}/#{animals.length}"
	@image_count = 0
	
	filename = "#{get_official_name(get_wiki_content(animal)).gsub(" ", "_").downcase}.html"
	
	if File.exists? filename and !File.zero? filename
		get_images_only(get_wiki_content(animal), filename)
		next
	end
	File.open(filename, "w") do |file| 
		file.write clean(get_wiki_content(animal), filename)
	end
end

File.open("wiki-images.json", "w") do |file| 
	file.write "{\"images\": #{@images.to_json}}"
end