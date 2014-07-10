# -*- encoding : utf-8 -*-
require 'nokogiri'
require 'eat'
require 'pandoc-ruby'
require "unicode_utils/each_grapheme"
require 'json'

@records = []
memo = {}
@countries = [
	'angola', 'tanzania', 'rwanda', 'burundi', 'uganda', 'kenya', 'somalia', 'somaliland', 'south sudan', 'sudan', 'cameroon', 'congo', 
	'equatorial guinea', 'ethiopia', 'lesotho', 'malawi', 'mozamibique', 'zambia', 'zimbabwe', 'namibia', 'botswana', 'swaziland', 'nigeria', 
	'south africa', 'republic of the congo', 'democratic republic of the congo', 'benin', 'togo', 'ivory coast', "côte d'ivoire", 'gabon', 
	'ghana', 'guinea', 'guinea-bissau', 'gambia', 'senegal', 'egypt', 'tunisia', 'libya', 'algeria', 'morocco', 'mali', 'burkina faso', 
	'liberia', 'sierra leone', 'niger', 'central african republic', 'chad', 'western sahara', 'mauritania', 'sao tome & principe', 
	'sao tome and principe', 'comoros', 'madagascar', 'seychelles', 'mauritius', 'eritrea', 'djibouti', 'cape verde'
]
@colours = [
	'alice blue', 'dark olive green', 'indigo', 'medium purple', 'purple', 
	'antique white', 'dark orange', 'ivory', 'medium sea green', 'red', 'aqua', 
	'dark orchid', 'khaki', 'medium slate blue', 'rosy brown', 'aquamarine', 
	'dark red', 'lavender', 'medium spring green', 'royal blue', 'azure', 
	'dark salmon', 'lavender blush', 'medium turquoise', 'saddlebrown', 'beige', 
	'dark sea green', 'lawngreen', 'medium violet red', 'salmon', 'bisque', 
	'dark slate blue', 'lemon chiffon', 'midnight blue', 'sandy brown', 'black', 
	'dark slate gray', 'light blue', 'mint cream', 'seagreen', 'blanched almond', 
	'dark turquoise', 'light coral', 'mistyrose', 'seashell', 'blue', 
	'dark violet', 'light cyan', 'moccasin', 'sienna', 'blue violet', 'deep pink', 
	'light goldenrod yellow', 'navajo white', 'silver', 'brown', 'deep skyblue', 
	'light gray', 'navy', 'skyblue', 'burlywood', 'dim gray', 'light green', 
	'oldlace', 'slate blue', 'cadet blue', 'dodger blue', 'light pink', 'olive', 
	'slate gray', 'chartreuse', 'fire brick', 'light salmon', 'olive drab', 
	'snow', 'chocolate', 'floral white', 'light sea green', 'orange', 
	'spring green', 'coral', 'forest green', 'light sky blue', 'orange red', 
	'steel blue', 'cornflower blue', 'fuchsia', 'light slate gray', 'orchid', 
	'tan', 'cornsilk', 'gainsboro', 'light steelblue', 'pale goldenrod', 'teal', 
	'crimson', 'ghost white', 'light yellow', 'pale green', 'thistle', 'cyan', 
	'gold', 'lime', 'pale turquoise', 'tomato', 'dark blue', 'goldenrod', 
	'lime green', 'pale violet red', 'turquoise', 'dark cyan', 'gray', 'linen', 
	'papaya whip', 'violet', 'dark goldenrod', 'green', 'magenta', 'peach puff', 
	'wheat', 'dark gray', 'green yellow', 'maroon', 'peru', 'white', 
	'dark green', 'honeydew', 'medium aquamarine', 'pink', 'white smoke', 
	'dark khaki', 'hot pink', 'medium blue', 'plum', 'yellow', 'dark magenta', 
	'indian red', 'medium orchid', 'powderblue', 'yellow green'
]
@activities = ['diurnal', 'nocturnal']

def make_wiki_uri name
	"http://en.wikipedia.org/wiki/#{name}"
end

def get_wiki_content name
	@wikipedia_call ||= {}

	while @wikipedia_call[name].nil?
		begin
			@wikipedia_call[name] ||= Nokogiri::XML(eat(make_wiki_uri(name), :timeout => 10))
			# @wikipedia_call[name] ||= Nokogiri::XML(File.read("#{name.gsub('%27', "'").downcase}.html"))
		rescue
		end
	end

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

def report xml
	common_name = xml.at_xpath("//h1[@id='firstHeading']/span").text()

	conservation_status = ""
	['Extinct','Extinct in the Wild','Critically Endangered','Endangered','Vulnerable','Near Threatened','Least Concern','Data Deficient','Not Evaluated'].each do |status|
		next if xml.at_xpath("//table[@class='infobox biota']").content.scan(status).empty?
			
		conservation_status = status 
	end

	kingdom = iterate_over xml, "//span[@class='kingdom']"
	phylum = iterate_over xml, "//span[@class='phylum']"
	klass = iterate_over xml, "//span[@class='class']"
	order = iterate_over xml, "//span[@class='order']"
	family = iterate_over xml, "//span[@class='family']"
	genus = iterate_over xml, "//span[@class='genus']"
	species = iterate_over xml, "//span[@class='species']"
	subspecies = iterate_over xml, "//span[@class='subspecies']"
	
	if xml.at_xpath("//span[@class='trinomial']/i").nil?
		official_name = xml.at_xpath("//span[@class='binomial']/i").text()
	else
		official_name = xml.at_xpath("//span[@class='trinomial']/i").text()
	end

	countries = []
	@countries.each do |country|
		next if xml.content.scan(country).empty?
		next if countries.include? country

		countries << country
	end
	
	colours = []
	@colours.each do |colour|
		next if xml.content.scan(colour).empty?
		next if colours.include? colour

		colours << colour
	end

	activities = []
	@activities.each do |activity|
		next if xml.content.scan(activity).empty?
		next if activities.include? activity

		activities << activity
	end

	record = {
		:common_name => common_name,
		:conservation_status => conservation_status,
		:kingdom => kingdom,
		:phylum => phylum,
		:klass => klass,
		:order => order,
		:family => family,
		:genus => genus,
		:species => species,
		:subspecies => subspecies,
		:official_name => official_name,
		:old_filename => get_image_ref(xml),
		:new_filename => "images/#{get_image_ref(xml).split('/').last}",
		:countries => countries,
		:colours => colours,
		:activities => activities,
		:endemic => !xml.content.scan('endemic').empty?
	}

	@records << record
end
 
birds = ['Abbott%27s_Starling']#,'Abdim%27s_Stork','Abyssinian_Crimsonwing','Abyssinian_Ground-Thrush','Abyssinian_Nightjar','Abyssinian_Scimitar-bill','Afep_Pigeon','African_Bare-eyed_Thrush','African_Barred_Owlet','African_Black-headed_Oriole','African_Black_Duck','African_Blue-Flycatcher','African_Broadbill','African_Bush-Warbler','African_Crake','African_Crested-Flycatcher','African_Cuckoo','African_Cuckoo-Hawk','African_Dusky_Flycatcher','African_Emerald_Cuckoo', 'African_Finfoot','African_Firefinch','African_Fish_Eagle','African_Golden_Oriole','African_Goshawk','African_Grass_Owl','African_Gray_Flycatcher','African_Gray_Hornbill','African_Green_Pigeon','African_Harrier-Hawk','African_Hawk-Eagle','African_Hill_Babbler','African_Hobby','African_Jacana','African_Marsh-Harrier','African_Openbill','African_Palm-Swift','African_Paradise-Flycatcher','African_Penduline-Tit','African_Pied_Hornbill','African_Pied_Wagtail','African_Pipit','African_Pitta','African_Pygmy-goose','African_Pygmy-Kingfisher','African_Quailfinch','African_Rail','African_Reed-Warbler','African_Scops-Owl','African_Shrike-flycatcher','African_Silverbill','African_Skimmer','African_Snipe','African_Spoonbill','African_Spotted_Creeper','African_Stonechat','African_Swift','African_Tailorbird','African_Thrush','African_Wood_Owl','African_Yellow_Warbler','African_Yellow_White-eye','Allen%27s_Gallinule','Alpine_Swift','Amani_Sunbird','Amethyst_Sunbird','Amur_Falcon','Anchieta%27s_Sunbird','Angola_Lark','Angolan_Swallow','Antarctic_Giant_Petrel','Arrow-marked_Babbler','Ashy_Cisticola','Ashy_Flycatcher','Ashy_Starling','Audubon%27s_Shearwater','Augur_Buzzard','Ayres%27s_Hawk-Eagle','Babbling_Starling','Baglafecht_Weaver','Baillon%27s_Crake','Bamboo_Scrub-Warbler','Banded_Martin','Banded_Snake-Eagle','Banded_Sunbird','Banded_Warbler','Bar-tailed_Godwit','Bar-tailed_Trogon','Bar-throated_Apalis','Barbary_Falcon','Bare-faced_Go-away-bird','Barn_Owl','Barn_Swallow','Barred_Long-tailed_Cuckoo','Barred_Warbler','Basra_Reed-Warbler','Bat-like_Spinetail','Bat_Hawk','Bateleur','Baumann%27s_Greenbul','Bearded_Scrub-Robin','Bearded_Woodpecker','Beaudouin%27s_Snake_Eagle','Beautiful_Sunbird','Beesley%27s_Lark','Bennett%27s_Woodpecker','Bertram%27s_Weaver','Black-and-white-casqued_Hornbill','Black-and-white_Mannikin','Black-and-white_Shrike-flycatcher','Black-backed_Barbet','Black-backed_Puffback','Black-bellied_Bustard','Black-bellied_Glossy-Starling','Black-bellied_Plover','Black-bellied_Seedcracker','Black-bellied_Sunbird','Black-billed_Barbet','Black-billed_Turaco','Black-billed_Weaver','Black-breasted_Snake-Eagle','Black-capped_Social_Weaver','Black-collared_Barbet','Black-crowned_Night-Heron','Black-crowned_Tchagra','Black-crowned_Waxbill','Black-eared_Seedeater','Black-faced_Rufous-Warbler','Black-faced_Sandgrouse','Black-faced_Waxbill','Black-fronted_Bushshrike','Black-headed_Apalis','Black-headed_Batis','Black-headed_Gonolek','Black-headed_Gull','Black-headed_Heron','Black-headed_Lapwing','Black-headed_Paradise-Flycatcher','Black-headed_Weaver','Black-lored_Babbler','Black-lored_Cisticola','Black-naped_Tern','Black-necked_Cisticola','Black-necked_Eremomela','Black-necked_Weaver','Black-rumped_Waxbill','Black-shouldered_Kite','Black-tailed_Godwit','Black-tailed_Oriole','Black-tailed_Waxbill','Black-throated_Apalis','Black-throated_Barbet','Black-throated_Canary','Black-throated_Wattle-eye','Black-winged_Bishop','Black-winged_Lapwing','Black-winged_Pratincole','Black-winged_Stilt','Black_Bishop','Black_Coucal','Black_Crake','Black_Cuckoo','Black_Cuckoo-shrike','Black_Goshawk','Black_Heron','Black_Kite','Black_Stork','Blackcap','Blacksmith_Plover','Blue-breasted_Bee-eater','Blue-breasted_Cordonbleu','Blue-breasted_Kingfisher','Blue-capped_Cordonbleu','Blue-cheeked_Bee-eater','Blue-headed_Coucal','Blue-naped_Mousebird','Blue-shouldered_Robin-Chat','Blue-spotted_Wood_Dove','Blue-throated_Brown_Sunbird','Blue_Quail','Blue_Sawwing','Blue_Swallow','Bocage%27s_Akalat','Boehm%27s_Bee-eater','Boehm%27s_Flycatcher','Booted_Eagle','Braun%27s_Bushshrike','Bridled_Tern','Brimstone_Canary','Broad-billed_Roller','Broad-billed_Sandpiper','Broad-ringed_White-eye','Broad-tailed_Paradise-Whydah','Bronze-winged_Courser','Bronze_Mannikin','Bronze_Sunbird','Brown-backed_Scrub-Robin','Brown-backed_Woodpecker','Brown-breasted_Barbet','Brown-capped_Weaver','Brown-chested_Alethe','Brown-chested_Lapwing','Brown-crowned_Tchagra','Brown-eared_Woodpecker','Brown-headed_Apalis','Brown-headed_Parrot','Brown-hooded_Kingfisher','Brown-necked_Parrot','Brown-throated_Martin','Brown-throated_Wattle-eye','Brown_Babbler','Brown_Booby','Brown_Firefinch','Brown_Illadopsis','Brown_Noddy','Brown_Shrike','Brown_Snake_Eagle','Brown_Warbler','Brown_Woodland-Warbler','Brubru','Buff-bellied_Warbler','Buff-crested_Bustard','Buff-spotted_Flufftail','Buff-spotted_Woodpecker','Buff-throated_Apalis','Buffy_Pipit','Bush_Pipit','Cabanis%27s_Bunting','Cabanis%27s_Greenbul','Cameroon_Scrub-Warbler','Cape_Batis','Cape_Bunting','Cape_Canary','Cape_Crombec','Cape_Crow','Cape_Eagle-Owl','Cape_Gannet','Cape_Robin-Chat','Cape_Shoveler','Cape_Teal','Cape_Wagtail','Capped_Wheatear','Cardinal_Quelea','Cardinal_Woodpecker','Carruthers%27s_Cisticola','Caspian_Plover','Caspian_Tern','Cattle_Egret','Chapin%27s_Apalis','Chestnut-backed_Sparrow-Lark','Chestnut-backed_Sparrow-Weaver','Chestnut-banded_Plover','Chestnut-bellied_Sandgrouse','Chestnut-fronted_Helmetshrike','Chestnut-headed_Flufftail','Chestnut-throated_Apalis','Chestnut-winged_Starling','Chestnut_Sparrow','Chestnut_Wattle-eye','Chestnut_Weaver','Chinspot_Batis','Chirping_Cisticola','Chubb%27s_Cisticola','Churring_Cisticola','Cinnamon-breasted_Bunting','Cinnamon-chested_Bee-eater','Cinnamon_Bracken-Warbler','Collared_Flycatcher','Collared_Palm-Thrush','Collared_Pratincole','Collared_Sunbird','Comb_Duck','Common_Bristlebill','Common_Bulbul','Common_Chiffchaff','Common_Cuckoo','Common_Greenshank','Common_House_Martin','Common_Moorhen','Common_Nightingale','Common_Pochard','Common_Quail','Common_Redshank','Common_Redstart','Common_Ringed_Plover','Common_Rock_Thrush','Common_Sandpiper','Common_Scimitar-bill','Common_Snipe','Common_Swift','Common_Tern','Common_Waxbill','Compact_Weaver','Congo_Bay-Owl','Copper_Sunbird','Coppery-tailed_Coucal','Coqui_Francolin','Corn_Crake','Crab_Plover','Crested_Barbet','Crested_Francolin','Crested_Guineafowl','Crimson-rumped_Waxbill','Croaking_Cisticola','Crowned_Hawk-Eagle','Crowned_Hornbill','Crowned_Lapwing','Curlew_Sandpiper','Cut-throat_Finch','D%27Arnaud%27s_Barbet','Dapple-throat','Dark-backed_Weaver','Dark_Chanting-Goshawk','Delegorgue%27s_Pigeon','Desert_Cisticola','Dickinson%27s_Kestrel','Dideric_Cuckoo','Donaldson-Smith%27s_Nightjar','Double-banded_Courser','Double-toothed_Barbet','Dusky_Crested-Flycatcher','Dusky_Lark','Dusky_Long-tailed_Cuckoo','Dusky_Turtle_Dove','Dwarf_Bittern','Eared_Grebe','East_Coast_Akalat','Eastern_Chanting-Goshawk','Eastern_Double-collared_Sunbird','Eastern_Golden_Weaver','Eastern_Imperial_Eagle','Eastern_Mountain-Greenbul','Eastern_Nicator','Eastern_Olivaceous_Warbler','Eastern_Olive-Sunbird','Eastern_Paradise-Whydah','Eastern_Plantain-eater','Eastern_Yellow-billed_Hornbill','Egyptian_Goose','Egyptian_Vulture','Eleonora%27s_Falcon','Emerald-spotted_Wood-Dove','Ethiopian_Swallow','Eurasian_Buzzard','Eurasian_Curlew','Eurasian_Golden_Oriole','Eurasian_Hobby','Eurasian_Kestrel','Eurasian_Nightjar','Eurasian_Oystercatcher','Eurasian_Reed-Warbler','Eurasian_River_Warbler','Eurasian_Sparrowhawk','Eurasian_Teal','Eurasian_Thick-knee','Eurasian_Wigeon','European_Bee-eater','European_Honey-buzzard','European_Roller','European_Turtle_Dove','Familiar_Chat','Fan-tailed_Grassbird','Fan-tailed_Widowbird','Fasciated_Snake-Eagle','Fawn-breasted_Waxbill','Fawn-colored_Lark','Fiery-necked_Nightjar','Fire-fronted_Bishop','Fischer%27s_Greenbul','Fischer%27s_Lovebird','Fischer%27s_Sparrow-Lark','Fischer%27s_Starling','Fischer%27s_Turaco','Flappet_Lark','Forbes%27s_Plover','Forbes-Watson%27s_Swift','Forest_Francolin','Forest_Robin','Forest_Woodhoopoe','Fork-tailed_Drongo','Four-colored_Bushshrike','Foxy_Lark','Freckled_Nightjar','Friedmann%27s_Lark','Fuelleborn%27s_Boubou','Fuelleborn%27s_Longclaw','Fulvous_Whistling-Duck','Gabar_Goshawk','Garden_Warbler','Garganey','Giant_Kingfisher','Glossy_Ibis','Golden-backed_Weaver','Golden-breasted_Bunting','Golden-breasted_Starling','Golden-crowned_Woodpecker','Golden-tailed_Woodpecker','Golden-winged_Sunbird','Golden_Palm_Weaver','Golden_Pipit','Goliath_Heron','Grasshopper_Buzzard','Gray-backed_Fiscal','Gray-breasted_Francolin','Gray-capped_Warbler','Gray-crested_Helmetshrike','Gray-headed_Bushshrike','Gray-headed_Gull','Gray-headed_Kingfisher','Gray-headed_Lovebird','Gray-headed_Nigrita','Gray-headed_Silverbill','Gray-headed_Social-Weaver','Gray-headed_Sparrow','Gray-headed_Sunbird','Gray-headed_Woodpecker','Gray-olive_Greenbul','Gray-rumped_Swallow','Gray-throated_Barbet','Gray-throated_Tit-Flycatcher','Gray-winged_Robin-Chat','Gray_Apalis','Gray_Crowned-Crane','Gray_Cuckoo-shrike','Gray_Go-away-bird','Gray_Greenbul','Gray_Heron','Gray_Kestrel','Gray_Longbill','Gray_Parrot','Gray_Tit-Flycatcher','Gray_Wagtail','Gray_Woodpecker','Gray_Wren-Warbler','Great_Bittern','Great_Blue_Turaco','Great_Cormorant','Great_Crested_Grebe','Great_Crested_Tern','Great_Egret','Great_Frigatebird','Great_Reed-Warbler','Great_Snipe','Great_Spotted_Cuckoo','Great_White_Pelican','Greater_Blue-eared_Glossy-Starling','Greater_Flamingo','Greater_Honeyguide','Greater_Kestrel','Greater_Painted-snipe','Greater_Sandplover','Greater_Spotted_Eagle','Greater_Striped_Swallow','Greater_Swamp-Warbler','Greater_Whitethroat','Green-backed_Camaroptera','Green-backed_Honeyguide','Green-backed_Twinspot','Green-backed_Woodpecker','Green-headed_Oriole','Green-headed_Sunbird','Green-throated_Sunbird','Green-winged_Pytilia','Green_Barbet','Green_Crombec','Green_Hylia','Green_Indigobird','Green_Sandpiper','Green_Sunbird','Green_Tinkerbird','Green_Woodhoopoe','Greencap_Eremomela','Groundscraper_Thrush','Gull-billed_Tern','Hadada_Ibis','Hairy-breasted_Barbet','Half-collared_Kingfisher','Hamerkop','Harlequin_Quail','Hartlaub%27s_Babbler','Hartlaub%27s_Bustard','Hartlaub%27s_Turaco','Helmeted_Guineafowl','Heuglin%27s_Gull','Hildebrandt%27s_Francolin','Hildebrandt%27s_Starling','Holub%27s_Golden_Weaver','Honeyguide_Greenbul','Hooded_Vulture','Hoopoe','Horus_Swift','Hottentot_Buttonquail','Hottentot_Teal','House_Crow','House_Sparrow','Hunter%27s_Cisticola','Hunter%27s_Sunbird','Icterine_Greenbul','Icterine_Warbler','Intermediate_Egret','Iringa_Akalat','Isabelline_Wheatear','Jack_Snipe','Jackson%27s_Pipit','Jackson%27s_Widowbird','Jameson%27s_Antpecker','Jameson%27s_Firefinch','Jameson%27s_Wattle-eye','Java_Sparrow','Joyful_Greenbul','Karamoja_Apalis','Kelp_Gull','Kenrick%27s_Starling','Kenya_Rufous_Sparrow','Kenya_Violet-backed_Sunbird','Kilombero_Weaver','Kittlitz%27s_Plover','Klaas%27s_Cuckoo','Kori_Bustard','Kretschmer%27s_Longbill','Kurrichane_Thrush','Lammergeier','Lanner_Falcon','Lappet-faced_Vulture','Laughing_Dove','Laura%27s_Wood-Warbler','Leaf-love','Least_Honeyguide','Lemon_Dove','Lesser_Black-backed_Gull','Lesser_Blue-eared_Glossy-Starling','Lesser_Bristlebill','Lesser_Crested_Tern','Lesser_Cuckoo','Lesser_Flamingo','Lesser_Frigatebird','Lesser_Gray_Shrike','Lesser_Honeyguide','Lesser_Jacana','Lesser_Kestrel','Lesser_Masked_Weaver','Lesser_Moorhen','Lesser_Sandplover','Lesser_Seedcracker','Lesser_Spotted_Eagle','Lesser_Striped_Swallow','Lesser_Swamp-Warbler','Levaillant%27s_Cisticola','Levaillant%27s_Cuckoo','Levant_Sparrowhawk','Lilac-breasted_Roller','Lilian%27s_Lovebird','Little_Bee-eater','Little_Bittern','Little_Egret','Little_Grebe','Little_Green_Sunbird','Little_Greenbul','Little_Ringed_Plover','Little_Rock_Thrush','Little_Sparrowhawk','Little_Stint','Little_Swift','Little_Tern','Little_Weaver','Livingstone%27s_Flycatcher','Livingstone%27s_Turaco','Lizard_Buzzard','Locustfinch','Long-billed_Pipit','Long-billed_Tailorbird','Long-crested_Eagle','Long-legged_Buzzard','Long-tailed_Cormorant','Long-tailed_Fiscal','Long-tailed_Jaeger','Long-toed_Lapwing','Long-toed_Stint','Loveridge%27s_Sunbird','Lowland_Akalat','Lowland_Tiny_Greenbul','Luehder%27s_Bushshrike','Lufira_Masked-Weaver','Maccoa_Duck','Mackinnon%27s_Shrike','Madagascar_Bee-eater','Madagascar_Cuckoo','Madagascar_Pond-Heron','Madagascar_Pratincole','Magpie_Mannikin','Magpie_Shrike','Magpie_Starling','Malachite_Kingfisher','Malachite_Sunbird','Mangrove_Kingfisher','Marabou_Stork','Mariqua_Sunbird','Marsh_Owl','Marsh_Sandpiper','Marsh_Tchagra','Marsh_Warbler','Marsh_Widowbird','Martial_Eagle','Mascarene_Martin','Masked_Apalis','Masked_Booby','Masked_Shrike','Meyer%27s_Parrot','Miombo_Camaroptera','Miombo_Pied_Barbet','Miombo_Rock_Thrush','Miombo_Scrub-Robin','Miombo_Sunbird','Miombo_Tit','Mocking_Cliff-Chat','Mombasa_Woodpecker','Montagu%27s_Harrier','Montane_Nightjar','Montane_Tiny_Greenbul','Montane_Widowbird','Moorland_Chat','Moreau%27s_Sunbird','Mosque_Swallow','Mottled_Spinetail','Mottled_Swift','Mountain_Buzzard','Mountain_Illadopsis','Mountain_Wagtail','Mountain_Yellow_Warbler','Mourning_Collared_Dove','Mourning_Wheatear','Mouse-colored_Penduline-Tit','Mouse-colored_Sunbird','Moustached_Grass-Warbler','Moustached_Tinkerbird','Mrs._Moreau%27s_Warbler','Namaqua_Dove','Narina_Trogon','Northern_Anteater-Chat','Northern_Black-Flycatcher','Northern_Brown-throated_Weaver','Northern_Brownbul','Northern_Carmine_Bee-eater','Northern_Crombec','Northern_Pied-Babbler','Northern_Pintail','Northern_Puffback','Northern_Shoveler','Northern_Wheatear','Northern_White-crowned_Shrike','Nubian_Nightjar','Nubian_Woodpecker','Nyanza_Swift','Olive-bellied_Sunbird','Olive-flanked_Robin-Chat','Olive-green_Camaroptera','Olive-headed_Weaver','Olive-tree_Warbler','Olive_Ibis','Olive_Thrush','Olive_Woodpecker','Orange-tufted_Sunbird','Orange-winged_Pytilia','Orange_Ground-Thrush','Orange_Weaver','Oriole_Finch','Osprey','Ostrich','Oustalet%27s_Sunbird','Ovampo_Sparrowhawk','Pacific_Golden-Plover','Pale-billed_Hornbill','Pale-breasted_Illadopsis','Pale-crowned_Cisticola','Pale-winged_Indigobird','Pale_Batis','Pale_Flycatcher','Pallid_Harrier','Pallid_Honeyguide','Palm-nut_Vulture','Pangani_Longclaw','Papyrus_Canary','Papyrus_Gonolek','Papyrus_Yellow_Warbler','Parasitic_Jaeger','Parasitic_Weaver','Parrot-billed_Sparrow','Pearl-breasted_Swallow','Pearl-spotted_Owlet','Pectoral-patch_Cisticola','Pel%27s_Fishing-Owl','Pemba_Green_Pigeon','Pemba_Scops-Owl','Pemba_Sunbird','Pemba_White-eye','Pennant-winged_Nightjar','Peregrine_Falcon','Peters%27s_Twinspot','Pied_Avocet','Pied_Crow','Pied_Cuckoo','Pied_Kingfisher','Pied_Wheatear','Pin-tailed_Whydah','Pink-backed_Pelican','Pink-breasted_Lark','Pink-footed_Puffback','Piping_Cisticola','Plain-backed_Pipit','Plain-backed_Sunbird','Plain_Greenbul','Plain_Nightjar','Pomarine_Jaeger','Pringle%27s_Puffback','Purple-banded_Sunbird','Purple-crested_Turaco','Purple-throated_Cuckoo-shrike','Purple_Grenadier','Purple_Heron','Purple_Indigobird','Purple_Swamphen','Pygmy_Batis','Pygmy_Falcon','Quail-plover','Racket-tailed_Roller','Rameron_Pigeon','Rattling_Cisticola','Red-and-yellow_Barbet','Red-backed_Scrub-Robin','Red-backed_Shrike','Red-bellied_Parrot','Red-billed_Buffalo_Weaver','Red-billed_Duck','Red-billed_Firefinch','Red-billed_Oxpecker','Red-billed_Quailfinch','Red-billed_Quelea','Red-capped_Crombec','Red-capped_Lark','Red-capped_Robin-Chat','Red-cheeked_Cordonbleu','Red-chested_Cuckoo','Red-chested_Flufftail','Red-chested_Sunbird','Red-collared_Widowbird','Red-eyed_Dove','Red-faced_Barbet','Red-faced_Cisticola','Red-faced_Crimsonwing','Red-faced_Crombec','Red-faced_Mousebird','Red-footed_Booby','Red-footed_Falcon','Red-fronted_Barbet','Red-fronted_Parrot','Red-fronted_Tinkerbird','Red-fronted_Warbler','Red-headed_Bluebill','Red-headed_Lovebird','Red-headed_Malimbe','Red-headed_Quelea','Red-headed_Weaver','Red-knobbed_Coot','Red-necked_Falcon','Red-necked_Francolin','Red-necked_Phalarope','Red-rumped_Swallow','Red-rumped_Waxbill','Red-tailed_Ant-Thrush','Red-throated_Pipit','Red-throated_Tit','Red-tufted_Sunbird','Red-winged_Francolin','Red-winged_Lark','Red-winged_Prinia','Red-winged_Starling','Red_Bishop','Red_Knot','Regal_Sunbird','Reichard%27s_Seedeater','Reichenow%27s_Seedeater','Reichenow%27s_Woodpecker','Retz%27s_Helmetshrike','Ring-necked_Dove','Ring-necked_Francolin','Rock-loving_Cisticola','Rock_Martin','Rock_Pratincole','Roseate_Tern','Ross%27s_Turaco','Rosy-patched_Bushshrike','Rosy-throated_Longclaw','Rubeho_Akalat','Ruddy_Turnstone','Rueppell%27s_Glossy-Starling','Rueppell%27s_Griffon','Rueppell%27s_Robin-Chat','Ruff_(bird)','Rufous-bellied_Heron','Rufous-bellied_Tit','Rufous-cheeked_Nightjar','Rufous-chested_Sparrowhawk','Rufous-chested_Swallow','Rufous-crowned_Roller','Rufous-naped_Lark','Rufous-necked_Wryneck','Rufous-tailed_Scrub-Robin','Rufous-tailed_Shrike','Rufous-tailed_Weaver','Rufous-winged_Sunbird','Rufous_Chatterer','Rufous_Flycatcher-Thrush','Ruwenzori_Batis','Sacred_Ibis','Saddle-billed_Stork','Saker_Falcon','Sand_Martin','Sanderling','Sandwich_Tern','Saunders%27s_Tern','Scaly-breasted_Illadopsis','Scaly-throated_Honeyguide','Scaly_Babbler','Scaly_Chatterer','Scaly_Francolin','Scarce_Swift','Scarlet-chested_Sunbird','Schalow%27s_Turaco','Scissor-tailed_Kite','Secretary-bird','Sedge_Warbler','Semicollared_Flycatcher','Senegal_Coucal','Senegal_Lapwing','Sharp-tailed_Glossy-Starling','Sharpe%27s_Akalat','Sharpe%27s_Starling','Shelley%27s_Francolin','Shelley%27s_Greenbul','Shelley%27s_Starling','Shelley%27s_Sunbird','Shikra','Shining-blue_Kingfisher','Shoebill','Short-eared_Owl','Short-tailed_Batis','Short-tailed_Lark','Short-tailed_Pipit','Shy_Albatross','Siffling_Cisticola','Silverbird_(bird)','Silvery-cheeked_Hornbill','Singing_Bushlark','Singing_Cisticola','Slate-colored_Boubou','Slender-billed_Greenbul','Slender-billed_Starling','Slender-billed_Weaver','Slender-tailed_Nightjar','Small_Buttonquail','Snowy-crowned_Robin-Chat','Sokoke_Pipit','Sokoke_Scops-Owl','Somali_Bee-eater','Somali_Bunting','Somali_Crombec','Somali_Tit','Sombre_Greenbul','Sombre_Nightjar','Sooty_Chat','Sooty_Falcon','Sooty_Flycatcher','Sooty_Gull','Sooty_Tern','Southern_Black-Flycatcher','Southern_Brown-throated_Weaver','Southern_Carmine_Bee-eater','Southern_Citril','Southern_Fiscal','Southern_Gray-headed_Sparrow','Southern_Grosbeak-Canary','Southern_Ground-Hornbill','Southern_Masked_Weaver','Southern_Pochard','Southern_White-faced_Owl','Souza%27s_Shrike','Speckle-fronted_Weaver','Speckled_Mousebird','Speckled_Pigeon','Spectacled_Weaver','Speke%27s_Weaver','Splendid_Glossy-Starling','Spot-breasted_Ibis','Spot-flanked_Barbet','Spot-throat','Spotted_Crake','Spotted_Eagle-Owl','Spotted_Flycatcher','Spotted_Greenbul','Spotted_Ground-Thrush','Spotted_Morning-Thrush','Spotted_Redshank','Spotted_Thick-knee','Spur-winged_Goose','Spur-winged_Plover','Squacco_Heron','Square-tailed_Drongo','Square-tailed_Nightjar','Standard-winged_Nightjar','Stanley_Bustard','Steel-blue_Whydah','Steppe_Eagle','Stierling%27s_Woodpecker','Stout_Cisticola','Straw-tailed_Whydah','Streaky-breasted_Flufftail','Streaky_Seedeater','Striated_Fieldwren','Striated_Heron','Stripe-cheeked_Bulbul','Striped_Crake','Striped_Flufftail','Striped_Kingfisher','Striped_Pipit','Stuhlmann%27s_Starling','Sulphur-breasted_Bushshrike','Superb_Starling','Superb_Sunbird','Swaheli_Sparrow','Swallow-tailed_Bee-eater','Swamp_Flycatcher','Swamp_Nightjar','Swynnerton%27s_Robin','Tabora_Cisticola','Tacazze_Sunbird','Taita_Falcon','Taita_Fiscal','Tambourine_Dove','Tanzania_Seedeater','Taveta_Weaver','Tawny-flanked_Prinia','Tawny_Eagle','Temminck%27s_Courser','Temminck%27s_Stint','Terek_Sandpiper','Terrestrial_Brownbul','Thick-billed_Cuckoo','Thick-billed_Seedeater','Thick-billed_Weaver','Three-banded_Courser','Three-banded_Plover','Three-streaked_Tchagra','Thrush_Nightingale','Tiny_Cisticola','Toro_Olive-Greenbul','Tree_Pipit','Trilling_Cisticola','Tropical_Boubou','Trumpeter_Hornbill','Tsavo_Sunbird','Tufted_Duck','Tullberg%27s_Woodpecker','Udzungwa_Partridge','Uganda_Wood-Warbler','Uluguru_Bushshrike','Uluguru_Violet-backed_Sunbird','Upcher%27s_Warbler','Usambara_Akalat','Usambara_Eagle-Owl','Usambara_Hyliota','Usambara_Weaver','Variable_Indigobird','Variable_Sunbird','Verreaux%27s_Eagle','Verreaux%27s_Eagle-Owl','Vieillot%27s_Weaver','Village_Indigobird','Village_Weaver','Violet-backed_Starling','Violet-breasted_Sunbird','Violet_Woodhoopoe','Vitelline_Masked_Weaver','Von_der_Decken%27s_Hornbill','Vulturine_Guineafowl','Wahlberg%27s_Eagle','Wahlberg%27s_Honeyguide','Wailing_Cisticola','Waller%27s_Starling','Water_Thick-knee','Wattled_Crane','Wattled_Lapwing','Wattled_Starling','Wedge-tailed_Shearwater','Western_Black-headed_Oriole','Western_Citril','Western_Marsh-Harrier','Western_Olive-Sunbird','Western_Violet-backed_Sunbird','Western_Yellow_Wagtail','Weyns%27s_Weaver','Whimbrel','Whinchat','Whiskered_Tern','White-backed_Duck','White-backed_Night-Heron','White-backed_Vulture','White-bellied_Bustard','White-bellied_Canary','White-bellied_Go-away-bird','White-bellied_Kingfisher','White-bellied_Storm_Petrel','White-bellied_Tit','White-breasted_Cuckoo-shrike','White-breasted_Nigrita','White-breasted_Sunbird','White-breasted_White-eye','White-browed_Coucal','White-browed_Crombec','White-browed_Robin-Chat','White-browed_Sparrow-Weaver','White-cheeked_Tern','White-chested_Alethe','White-chinned_Petrel','White-chinned_Prinia','White-collared_Oliveback','White-eared_Barbet','White-eyed_Slaty-Flycatcher','White-faced_Whistling-Duck','White-fronted_Bee-eater','White-fronted_Plover','White-headed_Barbet','White-headed_Black-Chat','White-headed_Buffalo_Weaver','White-headed_Lapwing','White-headed_Mousebird','White-headed_Sawwing','White-headed_Vulture','White-headed_Woodhoopoe','White-necked_Raven','White-rumped_Swift','White-shouldered_Black-Tit','White-spotted_Flufftail','White-starred_Robin','White-tailed_Ant-Thrush','White-tailed_Blue-Flycatcher','White-tailed_Crested-Flycatcher','White-tailed_Lark','White-tailed_Tropicbird','White-throated_Bee-eater','White-throated_Robin','White-throated_Swallow','White-winged_Apalis','White-winged_Black-Tit','White-winged_Scrub-Warbler','White-winged_Tern','White-winged_Widowbird','White_Helmetshrike','White_Stork','White_Wagtail','Whyte%27s_Barbet','Willow_Warbler','Winding_Cisticola','Wing-snapping_Cisticola','Wire-tailed_Swallow','Wood_Sandpiper','Wood_Warbler','Woodchat_Shrike','Woodland_Kingfisher','Woodland_Pipit','Woolly-necked_Stork','Xavier%27s_Greenbul','Yellow-bellied_Eremomela','Yellow-bellied_Greenbul','Yellow-bellied_Hyliota','Yellow-bellied_Wattle-eye','Yellow-bellied_Waxbill','Yellow-billed_Duck','Yellow-billed_Oxpecker','Yellow-billed_Stork','Yellow-breasted_Apalis','Yellow-browed_Seedeater','Yellow-collared_Lovebird','Yellow-crowned_Bishop','Yellow-crowned_Canary','Yellow-fronted_Canary','Yellow-fronted_Tinkerbird','Yellow-mantled_Widowbird','Yellow-necked_Francolin','Yellow-rumped_Tinkerbird','Yellow-spotted_Barbet','Yellow-spotted_Nicator','Yellow-spotted_Petronia','Yellow-streaked_Bulbul','Yellow-throated_Greenbul','Yellow-throated_Longclaw','Yellow-throated_Petronia','Yellow-throated_Sandgrouse','Yellow-throated_Wood-Warbler','Yellow-vented_Eremomela','Yellow-whiskered_Bulbul','Yellow_Bishop','Yellow_Flycatcher','Yellow_Longbill','Yellowbill','Zanzibar_Red_Bishop','Zebra_Waxbill','Zitting_Cisticola', 'Anhinga_novaehollandiae', 'Anhinga_rufa', 'Anhinga_melanogaster', 'Anhinga_anhinga', 'Northern_red-billed_hornbill', 'Western_red-billed_hornbill', 'Tanzanian_red-billed_hornbill', 'Damara_red-billed_hornbill', 'Southern_red-billed_hornbill']
birds.each { |bird| puts bird; report(get_wiki_content bird) }

File.open("birds.json", "w") do |file| 
	file.write @records.to_json
end