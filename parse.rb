# -*- encoding : utf-8 -*-
require 'nokogiri'
require 'eat'
require 'pandoc-ruby'
require "unicode_utils/each_grapheme"
require 'json'
require "./animals"

memo = {}
@countries = [
	'angola', 'tanzania', 'rwanda', 'burundi', 'uganda', 'kenya', 'somalia', 'somaliland', 'south sudan', 'sudan', 'cameroon', 'congo', 
	'equatorial guinea', 'ethiopia', 'lesotho', 'malawi', 'mozamibique', 'zambia', 'zimbabwe', 'namibia', 'botswana', 'swaziland', 'nigeria', 
	'south africa', 'republic of the congo', 'democratic republic of the congo', 'benin', 'togo', 'ivory coast', "côte d'ivoire", 'gabon', 
	'ghana', 'guinea', 'guinea-bissau', 'gambia', 'senegal', 'egypt', 'tunisia', 'libya', 'algeria', 'morocco', 'mali', 'burkina faso', 
	'liberia', 'sierra leone', 'niger', 'central african republic', 'chad', 'western sahara', 'mauritania', 'sao tome & principe', 
	'sao tome and principe', 'comoros', 'madagascar', 'seychelles', 'mauritius', 'eritrea', 'djibouti', 'cape verde',
	'japan'
]
@activities = ['diurnal', 'nocturnal']
@terrain = ['shorebird']

def make_wiki_uri name
	"http://en.wikipedia.org/wiki/#{name}"
end

def get_wiki_content name
	@wikipedia_call ||= {}
	@wikipedia_call[name] ||= Nokogiri::XML(File.read("raw/#{name.downcase}.html"))
	@wikipedia_call[name]    
end

def iterate_over xml, base_xpath
	['/a', '/i/a', '/i/b', '/i', '/b'].each do |xpath|
		node = xml.at_xpath("#{base_xpath}#{xpath}")
		next if node.nil?

		return node.text()
	end

	""
end

def get_image_ref xml
	image = xml.at_xpath("//table[@class='infobox biota']//a[@class='image']/img")
	return "" if image.nil?
 
	image.attr('src')
end

def get_conservation_status xml
	return "" if xml.at_xpath("//table[@class='infobox biota']").nil?

	['Extinct','Extinct in the Wild','Critically Endangered','Endangered','Vulnerable','Near Threatened','Least Concern','Data Deficient','Not Evaluated'].each do |status|
		next if xml.at_xpath("//table[@class='infobox biota']").content.scan(status).empty?
			
		return status 
	end

	""
end

def report xml, wikipage
	common_name = xml.at_xpath("//h1[@id='firstHeading']/span").text()

	conservation_status = get_conservation_status xml

	kingdom = iterate_over xml, "//span[@class='kingdom']"
	phylum = iterate_over xml, "//span[@class='phylum']"
	klass = iterate_over xml, "//span[@class='class']"
	order = iterate_over xml, "//span[@class='order']"
	family = iterate_over xml, "//span[@class='family']"
	genus = iterate_over xml, "//span[@class='genus']"
	species = iterate_over xml, "//span[@class='species']"
	subspecies = iterate_over xml, "//span[@class='subspecies']"

	if species[0] == genus[0] && species[1] == "."
		species.gsub!("#{genus[0]}.", genus)
	end
	
	if iterate_over(xml, "//span[@class='trinomial']") == ""
		official_name = iterate_over(xml, "//span[@class='binomial']")
	else
		official_name = iterate_over(xml, "//span[@class='trinomial']")
	end

	countries = []
	@countries.each do |country|
		next if xml.content.scan(/\b#{country}\b/i).empty?
		next if countries.include? country

		countries << country
	end

	activities = []
	@activities.each do |activity|
		next if xml.content.scan(activity).empty?
		next if activities.include? activity

		activities << activity
	end

	if subspecies != ""
		return nil if @animals.select{ |a| a[:subspecies] == subspecies }

		species_record = @animals.select {|a| a[:species] == species && species != ""}
		if species_record.empty?
			return {
				:common_name => common_name,
				:conservation_status => conservation_status,
				:kingdom => kingdom,
				:phylum => phylum,
				:klass => klass,
				:order => order,
				:family => family,
				:genus => genus,
				:species => species,
				:subspecies => [{
					:common_name => common_name,
					:official_name => official_name,
					:subspecies => subspecies, 
					:old_filename => get_image_ref(xml),
					:new_filename => "images/#{official_name.gsub(' ', '_').downcase}",
					:countries => countries,
					:colours => [],
					:activities => activities,
					:endemic => !xml.content.scan('endemic').empty?,
					:wiki => wikipage
					}],
				:official_name => species,
				:old_filename => get_image_ref(xml),
				:new_filename => "images/#{official_name.gsub(' ', '_').downcase}",
				:countries => countries,
				:colours => [],
				:activities => activities,
				:endemic => !xml.content.scan('endemic').empty?,
				:wiki => wikipage
			}
		else
			species_record = species_record.first
			species_record[:official_name] = official_name if species_record[:official_name] == ""
			species_record[:old_filename] = get_image_ref(xml) if species_record[:old_filename] == ""
			species_record[:new_filename] = get_image_ref(xml) if species_record[:new_filename] == "images/"
			species_record[:countries] = (species_record[:countries] + countries).uniq
			species_record[:colours] = (species_record[:colours] + []).uniq
			species_record[:activities] = (species_record[:activities] + activities).uniq
			species_record[:endemic] = !xml.content.scan('endemic').empty? unless species_record[:endemic] == true
			species_record[:wiki] = wikipage if species_record[:wiki] == ""

			species_record[:subspecies] << {
				:common_name => common_name,
				:official_name => official_name,
				:subspecies => subspecies,
				:old_filename => get_image_ref(xml),
				:new_filename => "images/#{official_name.gsub(' ', '_').downcase}",
				:countries => countries,
				:colours => [],
				:activities => activities,
				:endemic => !xml.content.scan('endemic').empty?,
				:wiki => wikipage
			}

			return nil
		end
	end

	return {
		:common_name => common_name,
		:conservation_status => conservation_status,
		:kingdom => kingdom,
		:phylum => phylum,
		:klass => klass,
		:order => order,
		:family => family,
		:genus => genus,
		:species => species,
		:subspecies => [],
		:official_name => official_name,
		:wiki_filename => "#{official_name.gsub(' ', '_').downcase}.html",
		:old_filename => get_image_ref(xml),
		:new_filename => "images/#{official_name.gsub(' ', '_').downcase}",
		:countries => countries,
		:colours => [],
		:activities => activities,
		:endemic => !xml.content.scan('endemic').empty?,
		:wiki => wikipage
	}
end
 
@animals = []
animals = get_animals
skipped = ['anhinga_novaehollandiae', 'Anhinga_rufa', 'Anhinga_melanogaster', 'Anhinga_anhinga', 'Northern_red-billed_hornbill', 'western_red-billed_hornbill', 'Tanzanian_red-billed_hornbill', 'Damara_red-billed_hornbill', 'Southern_red-billed_hornbill']

(animals - skipped).uniq.each do |animal| 
	puts animal
	record = report(get_wiki_content(animal), animal) 

	next if record.nil?
	next if @animals.map {|a| a[:official_name]}.include? record[:official_name] and record[:official_name] != ""

	@animals << record
end

File.open("animals.json", "w") do |file| 
	file.write "{\"animals\": #{@animals.to_json}}"
end

puts @animals.length

puts "conservation_status: #{@animals.select{|a| a[:conservation_status] == "" }.length}"
puts "kingdom: #{@animals.select{|a| a[:kingdom] == "" }.length}"
puts "phylum: #{@animals.select{|a| a[:phylum] == "" }.length}"
puts "klass: #{@animals.select{|a| a[:klass] == "" }.length}"
puts "order: #{@animals.select{|a| a[:order] == "" }.length}"
puts "family: #{@animals.select{|a| a[:family] == "" }.length}"
puts "genus: #{@animals.select{|a| a[:genus] == "" }.length}"
puts "species: #{@animals.select{|a| a[:species] == "" }.length}"
puts "official_name: #{@animals.select{|a| a[:official_name] == "" }.length}"
puts "old_filename: #{@animals.select{|a| a[:old_filename] == "" }.length}"