# -*- encoding : utf-8 -*-
require 'nokogiri'
require 'eat'
require 'pandoc-ruby'
require "unicode_utils/each_grapheme"
require 'json'

@animals = []

File.open(ARGV[0]) do |file|
	@animals = JSON.parse(file.read)
end

@animals['animals'].each_with_index do |animal, index|
	puts "#{animal['common_name']} #{index}/#{@animals['animals'].length}"
end

def using official_name
	animal = @animals['animals'].select{|animal| animal['official_name'].downcase == official_name}
	if animal.nil?
		puts "missing: #{official_name}"
		animal = {}
	end

	animal
end

# using('aptenodytes patagonicus')['elevation'] = {'from': -300, 'to': ''}
# using('balaenoptera musculus')['elevation'] = {'from': -100, 'to': 0}
# using('balaenoptera physalus')['elevation'] = {'from': -470, 'to': 0}
# using('eudyptes chrysolophus')['elevation'] = {'from': -100, 'to': 0}
# using('hydrobates pelagicus')['elevation'] = {'from': -5, 'to': ''}
# using('larus argentatus')['elevation'] = {'from': -2, 'to': ''}
# using('leptonychotes weddellii')['elevation'] = {'from': -100, 'to': ''}
# using('mirounga leonina')['elevation'] = {'from':-2133, 'to': 0}
# using('physeter macrocephalus')['elevation'] = {'from': -310, 'to': 0}
# using('platalea alba')['elevation'] = {'from': '', 'to': ''}
# using('stenella coeruleoalba')['elevation'] = {'from': -700, 'to': 0}
# using('accipiter melanoleucus')['elevation'] = {'from': 0, 'to': 3700}
# using('aethomys chrysophilus')['elevation'] = {'from': 0, 'to': 1000}
# using('aethomys ineptus')['elevation'] = {'from': 1000, 'to': ''}
# using('agapornis fischeri')['elevation'] = {'from': 1100, 'to': 2200}
# using('anthropoides paradiseus')['elevation'] = {'from': 1300, 'to': 2000}
# using('aquila verreauxii')['elevation'] = {'from': '', 'to': 4000}
# using('ardea goliath')['elevation'] = {'from': 0, 'to': 2100}
# using('atelerix albiventris')['elevation'] = {'from': '', 'to': 2000}
# using('atherurus africanus')['elevation'] = {'from': '', 'to': ''}
# using('bdeogale jacksoni')['elevation'] = {'from': '', 'to': 3300}
# using('bubo lacteus')['elevation'] = {'from': 0, 'to': 3000}
# using('canis aureus')['elevation'] = {'from': '', 'to': 1000}
# using('colobus guereza')['elevation'] = {'from': '', 'to': 3300}
# using('damaliscus korrigum')['elevation'] = {'from': '', 'to': 1500}
# using('dendrohyrax arboreus')['elevation'] = {'from': '', 'to': 4500}
# using('equus quagga')['elevation'] = {'from': 0, 'to': 4300}
# using('euplectes progne')['elevation'] = {'from': '', 'to': 2750}
# using('glauconycteris variegata')['elevation'] = {'from': '', 'to': 1000}
# using('gypaetus barbatus')['elevation'] = {'from': 300, 'to': 7300}
# using('heterohyrax brucei')['elevation'] = {'from': 0, 'to': 3800}
# using('hipposideros cyclops')['elevation'] = {'from': '', 'to': 1200}
# using('hippotragus leucophaeus')['elevation'] = {'from': '', 'to': 2400}
# using('lavia frons')['elevation'] = {'from': '', 'to': 2000}
# using('leptailurus serval')['elevation'] = {'from': '', 'to': 3000}
# using('neotis denhami')['elevation'] = {'from': '', 'to': 3000}
# using('pelecanus onocrotalus')['elevation'] = {'from': 0, 'to': 1372}
# using('plectropterus gambensis')['elevation'] = {'from': '', 'to': 3000}
# using('pogonocichla stellata')['elevation'] = {'from': 0, 'to': 3300}
# using('saccostomus campestris')['elevation'] = {'from': 50, 'to': 2000}
# using('sagittarius serpentarius')['elevation'] = {'from': '', 'to': ''}
# using('scotopelia peli')['elevation'] = {'from': 0, 'to': 1700}
# using('sylvisorex granti')['elevation'] = {'from': '', 'to': 3048}
# using('torgos tracheliotos')['elevation'] = {'from': 0, 'to': 4500}
# using('uraeginthus bengalus')['elevation'] = {'from': 0, 'to': 2430}
using('apaloderma vittatum')['colours'] << 'sheen'
using('columba livia')['colours'] << 'sheen'
using('columba livia')['colours'] << 'sheen'
using('fregata minor')['colours'] << 'sheen'
using('lamprotornis hildebrandti')['colours'] << 'sheen'
using('neamblysomus gunningi')['colours'] << 'sheen'
using('sarkidiornis melanotos')['colours'] << 'sheen'
using('scopus umbretta')['colours'] << 'sheen'
using('bostrychia hagedash')['colours'] << 'sheen'
using('centropus cupreicaudus')['colours'] << 'sheen'
using('chrysococcyx caprius')['colours'] << 'sheen'
using('ciconia nigra')['colours'] << 'sheen'
using('connochaetes taurinus')['colours'] << 'sheen'
using('drepanorhynchus reichenowi')['colours'] << 'sheen'
using('eudyptes chrysolophus')['colours'] << 'sheen'
using('fregata minor')['colours'] << 'sheen'
using('hippotragus leucophaeus')['colours'] << 'sheen'
using('neamblysomus gunningi')['colours'] << 'sheen'
using('phalacrocorax neglectus')['colours'] << 'sheen'
["onychoprion aleuticus", "prunella collaris", "pentalagus furnessi", "crocidura orii", "zoothera dauma major", "scolopax mira", "pluvialis dominica", "anas americana", "falco amurensis", "synthliboramphus antiquus", "stercorarius parasiticus", "sterna paradisaea", "phylloscopus borealis", "pericrocotus divaricatus", "limnodromus semipalmatus", "suncus murinus", "vespertilio sinensis", "leucosticte arctoa", "urosphena squameiceps", "puffinus lherminieri", "tyto longimembris", "sorex hosonoi", "cyanopica cyanus", "cyanistes cyanus", "aythya baeri", "anas formosa", "porzana pusilla", "calidris bairdii", "oceanodroma castro", "anser indicus", "limosa lapponica", "hirundo rustica", "panurus biarmicus", "erignathus barbatus", "delphinapterus leucas", "myotis macrodactylus", "melanocorypha bimaculata", "nyctalus aviator", "halcyon pileata", "nycticorax nycticorax", "emberiza spodocephala", "platalea minor", "phoebastria nigripes", "emberiza melanocephala", "chroicocephalus ridibundus", "threskiornis melanocephalus", "rissa tridactyla", "oriolus chinensis", "sterna sumatrana", "podiceps nigricollis", "larus crassirostris", "gavia arctica", "turdus atrogularis", "pterodroma nigripennis", "himantopus himantopus", "ixobrychus flavicollis", "dicrurus macrocercus", "milvus migrans", "phoenicurus ochruros", "ciconia nigra", "chlidonias niger", "dryocopus martius", "mesoplodon densirostris", "bubo blakistoni", "cyanoptila cyanomelana", "sula dactylatra", "merops philippinus", "procelsterna cerulea", "monticola solitarius", "balaenoptera musculus", "luscinia svecica", "anthus godlewskii", "sus scrofa", "bombycilla garrulus", "chroicocephalus philadelphia", "pteropus pselaphon", "carpodacus ferreorostris", "apalopteron familiare", "zoothera terrestris", "pterodroma hypoleuca", "columba versicolor", "balaena mysticetus", "fringilla montifringilla", "branta bernicla", "onychoprion anaethetus", "numenius tahitiensis", "limicola falcinellus", "hypsipetes amaurotis", "turdus chrysolaus", "ursus arctos", "sula leucogaster", "cinclus pallasii", "ninox scutulata", "lanius cristatus", "plecotus auritus", "uria lomvia", "balaenoptera brydei", "tryngites subruficollis", "bucephala albeola", "lanius bucephalus", "bulweria bulwerii", "branta canadensis", "aythya valisineria", "corvus corone", "larus cachinnans", "charadrius asiaticus", "hydroprogne caspia", "bubulcus ibis", "agropsar philippensis", "zosterops erythropleurus", "clamator coromandus", "emberiza rutila", "bambusicola thoracicus", "pycnonotus sinensis", "egretta eulophotes", "lanius sphenocercus", "ixobrychus sinensis", "mergus squamatus", "ardeola bacchus", "accipiter soloensis", "puffinus nativitatis", "ixobrychus cinnamomeus", "passer rutilans", "motacilla citreola", "periparus ater", "streptopelia decaocto", "otus lettia", "turdus merula", "buteo buteo", "fulica atra", "grus grus", "bucephala clangula", "uria aalge", "larus canus", "falco tinnunculus", "gallinula chloropus", "nyctalus noctula", "anous stolidus", "haematopus ostralegus", "aythya ferina", "corvus corax", "tringa totanus", "carpodacus erythrinus", "actitis hypoleucos", "melanitta nigra", "phoca vitulina", "tadorna tadorna", "gallinago gallinago", "platalea leucorodia", "sturnus vulgaris", "anas crecca", "sterna hirundo", "certhia familiaris", "syrmaticus soemmerringii", "aethia cristatella", "pernis ptilorhyncus", "megaceryle lugubris", "spilornis cheela", "tadorna cristata", "calidris ferruginea", "ziphius cavirostris", "phocoenoides dalli", "pelecanus crispus", "myotis daubentonii", "corvus dauuricus", "phoenicurus auroreus", "agropsar sturninus", "grus virgo", "oenanthe deserti", "eurystomus orientalis", "charadrius morinellus", "crocidura dsinezumi", "dugong dugon", "calidris alpina", "turdus eunomus", "phylloscopus fuscatus", "kogia sima", "larus vegae", "ardea alba modesta", "aquila heliaca", "mogera etigo", "chalcophaps indica", "chen canagica", "pipistrellus endoi", "botaurus stellaris", "pyrrhula pyrrhula", "numenius arquata", "bubo bubo", "falco subbuteo", "garrulus glandarius", "sorex minutissimus", "sitta europaea", "spinus spinus", "accipiter nisus", "picoides tridactylus", "micromys minutus", "aegypius monachus", "tadarida teniotis", "larus argentatus", "pica pica", "lutra lutra", "remiz pendulinus", "otus scops", "anas penelope", "turdus obscurus", "pitta nympha", "anas falcata", "pseudorca crassidens", "numenius madagascariensis", "myotis bombinus", "aythya nyroca", "muscicapa ferruginea", "turdus pilaris", "neophocaena phocaenoides", "chimarrogale platycephalus", "murina silvatica", "dendronanthus indicus", "oceanodroma furcata", "passerella iliaca", "leucophaeus pipixcan", "lagenodelphis hosei", "myotis frater", "myotis pruinosus", "anas strepera", "anas querquedula", "berardius arnuxii", "mesoplodon ginkgodens", "larus glaucescens", "larus hyperboreus", "murina tenebrosa", "regulus regulus", "zonotrichia atricapilla", "aquila chrysaetos", "mergus merganser", "locustella fasciolata", "eschrichtius robustus", "ichthyaetus ichthyaetus", "otis tarda", "phalacrocorax carbo", "podiceps cristatus", "fregata minor", "lanius excubitor", "calidris tenuirostris", "acrocephalus arundinaceus", "dendrocopos major", "parus major", "pelecanus onocrotalus", "rhinolophus ferrumequinum", "charadrius leschenaultii", "aythya marila", "aquila clanga", "murina leucogaster", "tringa melanoleuca", "phasianus versicolor", "tringa ochropus", "tringa nebularia", "turdus hortulorum", "butastur indicus", "emberiza fucata", "vanellus cinereus", "picus canus", "tringa brevipes", "saxicola ferreus", "ardea cinerea", "phalaropus fulicarius", "pluvialis squatarola", "myodes rufocanus", "sturnus cineraceus", "motacilla cinerea", "anser anser", "gelochelidon nilotica", "falco rusticolus", "histrionicus histrionicus", "pterodroma sandwichensis", "coccothraustes coccothraustes", "tetrastes bonasia", "circus cyaneus", "chimarrogale himalayica", "myotis formosus", "myodes rex", "myotis ikonnikovi", "canis lupus hodophilax", "grus monacha", "pitta sordida", "upupa epops", "fratercula corniculata", "crocidura horsfieldii", "corvus splendens", "apus nipalensis", "mesoplodon carlhubbsi", "megaptera novaeangliae", "rhinolophus imaizumii", "caprimulgus asiaticus", "dendrocygna javanica", "mesophoyx intermedia", "oenanthe isabellina", "pagophila eburnea", "turdus celaenops", "lymnocryptes minimus", "corvus monedula", "prunella rubida", "meles anakuma", "horornis diphone", "phalacrocorax capillatus", "nipponia nippon", "glirulus japonicus", "microtus montebelli", "picus awokera", "turdus cardis", "eophona personata", "lepus brachyurus", "macaca fuscata", "mogera wogura", "euroscaptor mizura", "gorsachius goisagi", "terpsiphone atrocaudata", "dendrocopos kizuki", "coturnix japonica", "emberiza yessoensis", "erithacus akahige", "otus semitorques", "zalophus japonicus", "capricornis crispus", "urotrichus talpoides", "alauda arvensis japonica", "gallinago hardwickii", "accipiter gularis", "sciurus lis", "motacilla grandis", "bombycilla japonica", "zosterops japonicus", "pteromys momonga", "petaurista leucogenys", "mustela itatsi", "corvus macrorhynchos", "charadrius alexandrinus", "pterodroma neglecta", "somateria spectabilis", "mogera kobeae", "apodemus peninsulae", "tadarida latouchei", "locustella lanceolata", "calcarius lapponicus", "apodemus speciosus", "phoebastria immutabilis", "oceanodroma leucorhoa", "aethia pusilla", "mustela nivalis", "larus fuscus", "fregata ariel", "hipposideros turpis", "falco naumanni", "aythya affinis", "calandrella rufescens", "dendrocopos minor", "anser erythropus", "crocidura suaveolens", "tringa flavipes", "garrulus lidthi", "emberiza pusilla", "tetrax tetrax", "numenius minutus", "egretta garzetta", "tachybaptus ruficollis", "hydrocoloeus minutus", "rhinolophus cornutus", "charadrius dubius", "calidris minuta", "sternula albifrons", "limnodromus scolopaceus", "sorex unguiculatus", "asio otus", "clangula hyemalis", "uragus sibiricus", "lanius schach", "stercorarius longicaudus", "aegithalos caudatus", "calidris subminuta", "gorsachius melanolophus", "anas platyrhynchos", "aix galericulata", "brachyramphus marmoratus", "pteropus mariannus", "tringa stagnatilis", "poecile palustris", "oceanodroma matsudairae", "peponocephala electra", "falco columbarius", "locustella ochotensis", "turdus viscivorus", "todiramphus miyakoensis", "charadrius mongolus", "lepus timidus", "nisaetus nipalensis", "tokudaia muenninki", "ficedula mugimaki", "cygnus olor", "ficedula narcissina", "myotis nattereri", "eubalaena japonica", "eptesicus nilssonii", "mirounga angustirostris", "callorhinus ursinus", "accipiter gentilis", "vanellus vanellus", "ochotona hyperborea", "anas acuta", "myodes rutilus", "lissodelphis borealis", "anas clypeata", "oenanthe oenanthe", "apus pacificus", "pteropus loochoensis", "gallirallus okinawae", "sapheopipo noguchii", "anthus hodgsoni", "balaenoptera omurai", "orcinus orca", "cuculus optatus", "chloris sinica", "glareola maldivarum", "otus sunia", "streptopelia orientalis", "emberiza hortulana", "pandion haliaetus", "gavia pacifica", "pluvialis fulva", "egretta sacra", "hirundo tahitica", "lagenorhynchus obliquidens", "puffinus carneipes", "turdus pallidus", "emberiza pallasi", "locustella certhiola", "carpodacus roseus", "syrrhaptes paradoxus", "phylloscopus proregulus", "aethia psittacula", "anthus gustavi", "calidris melanotos", "phalacrocorax pelagicus", "falco peregrinus", "hydrophasianus chirurgus", "recurvirostra avosetta", "circus melanoleucos", "oenanthe pleschanka", "cepphus columba", "emberiza leucocephalos", "pinicola enucleator", "gallinago stenura", "stercorarius pomarinus", "ardea purpurea", "feresa attenuata", "kogia breviceps", "nyctereutes procyonoides", "phylloscopus schwarzi", "merops ornatus", "mergus serrator", "netta rufina", "grus japonensis", "phalacrocorax urile", "tarsiger cyanurus", "sula sula", "rissa brevirostris", "podiceps grisegena", "phalaropus lobatus", "calidris ruficollis", "cecropis daurica", "phaethon rubricauda", "gavia stellata", "anthus cervinus", "streptopelia tranquebarica", "loxia curvirostra", "vulpes vulpes", "calidris canutus", "sciurus vulgaris", "aythya americana", "turdus iliacus", "emberiza schoeniclus", "ichthyaetus relictus", "cerorhinca monocerata", "histriophoca fasciata", "anthus richardi", "larus delawarensis", "aythya collaris", "charadrius hiaticula", "pusa hispida", "grampus griseus", "lagopus muta", "calidris ptilocnemis", "corvus frugilegus", "sterna dougallii", "rhodostethia rosea", "pastor roseus", "buteo lagopus", "steno bredanensis", "porzana fusca", "halcyon coromanda", "tadorna ferruginea", "philomachus pugnax", "luscinia sibilans", "nycticorax caledonicus", "emberiza rustica", "pericrocotus tegimae", "erithacus komadori", "otus elegans", "columba jouyi", "pteropus dasymallus", "mogera uchidai", "mus caroli", "diplothrix legata", "tokudaia osimensis", "xema sabini", "martes zibellina", "sorex sadonis", "riparia riparia", "calidris alba", "grus canadensis", "chroicocephalus saundersi", "passerculus sandwichensis", "hypsugo savii", "miniopterus schreibersii", "ixobrychus eurhythmus", "enhydra lutris", "calidris acuminata", "sorex shinto", "limnodromus griseus", "asio flammeus", "phoebastria albatrus", "puffinus tenuirostris", "calandrella brachydactyla", "prunella montanella", "luscinia cyane", "eutamias sibiricus", "grus leucogeranus", "muscicapa sibirica", "pteromys volans", "geokichla sibirica", "emberiza cioides", "luscinia calliope", "saxicola maurus", "cervus nippon", "larus schistisagus", "rallina eurizonoides", "podiceps auritus", "numenius tenuirostris", "chroicocephalus genei", "sorex gracillimus", "herpestes javanicus", "apodemus argenteus", "mogera imaizumii", "mergellus albellus", "myodes smithii", "plectrophenax nivalis", "chen caerulescens", "bubo scandiacus", "pterodroma solandri", "gallinago solitaria", "turdus philomelos", "puffinus griseus", "onychoprion fuscatus", "stercorarius maccormicki", "miniopterus fuscus", "cepphus carbo", "onychoprion lunatus", "physeter macrocephalus", "eurynorhynchus pygmeus", "anas poecilorhyncha", "pelecanus philippensis", "tringa guttifer", "nucifraga caryocatactes", "tringa erythropus", "phoca largha", "mesoplodon stejnegeri", "pterodroma longirostris", "oceanodroma tristrami", "polysticta stelleri", "haliaeetus pelagicus", "eumetopias jubatus", "calidris himantopus", "mustela erminea", "calonectris leucomelas", "butorides striata", "stenella coeruleoalba", "melanitta perspicillata", "anser cygnoides", "coturnicops exquisitus", "gallinago megala", "oceanodroma monorhis", "ficedula albicilla", "rattus tanezumi", "calidris temminckii", "aegolius funereus", "xenus cinereus", "larus thayeri", "iduna aedon", "lanius tigrinus", "mogera tokudae", "anthus trivialis", "passer montanus", "emberiza tristrami", "dymecodon pilirostris", "aythya fuligula", "fratercula cirrhata", "cygnus columbianus", "buteo hemilasius", "strix uralensis", "parus varius", "melanitta fusca", "sinosuthora webbiana", "myodes andersoni", "diomedea exulans", "tringa incana", "anthus spinoletta", "rallus aquaticus", "gallicrex cinerea", "puffinus pacificus", "larus heuglini", "calidris mauri", "motacilla flava", "numenius phaeopus", "aethia pygmaea", "chlidonias hybridus", "myotis mystacinus", "zoothera dauma", "dendrocopos leucotos", "dryocopus javensis", "gavia adamsii", "amaurornis phoenicurus", "artamus leucorynchus", "anous minutus", "todiramphus chloris", "zonotrichia leucophrys", "anser albifrons", "grus vipio", "pterodroma cervicalis", "lonchura striata", "haliaeetus albicilla", "phaethon lepturus", "hirundapus caudacutus", "monticola gularis", "chlidonias leucopterus", "loxia leucoptera", "ciconia ciconia", "gygis alba", "motacilla alba", "cygnus cygnus", "poecile montanus", "phalaropus tricolor", "oceanites oceanicus", "troglodytes hiemalis", "tringa glareola", "eophona migratoria", "emberiza aureola", "emberiza chrysophrys", "phylloscopus inornatus", "ficedula zanthopygia", "emberiza elegans", "emberiza sulphurata", "emberiza citrinella", "cisticola juncidis"].each do |animal|
	using(animal)['countries'] << "japan"
end

File.open("animals.json", "w") do |file| 
	file.write "{\"animals\": #{@animals.to_json}}"
end

File.open("animals.csv", "w") do |file| 
	file.write "common name,conservation status,kingdom,phylum,klass,order,family,genus,species,subspecies,official name,wiki filename,old filename,new filename,countries,colours,activities,endemic,wiki"
	file.write "\n"

	@animals.each do |animal|
		file.write "#{animal[:common_name]},#{animal[:conservation_status]},#{animal[:kingdom]},#{animal[:phylum]},#{animal[:klass]},#{animal[:order]},#{animal[:family]},#{animal[:genus]},#{animal[:species]},#{animal[:subspecies].join('|')},#{animal[:official_name]},#{animal[:wiki_filename]},#{animal[:old_filename]},#{animal[:new_filename]},#{animal[:countries].join('|')},#{animal[:colours].join('|')},#{animal[:activities].join('|')},#{animal[:endemic]},#{animal[:wiki]}"
		file.write "\n"
	end
end