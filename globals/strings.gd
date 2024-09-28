extends Node


const STRING_OK = "OK"
const STRING_YES = "Yes"
const STRING_NO = "No"
const STRING_PASS = "Pass"
const STRING_CANCEL = "Cancel"
const STRING_SHOW_CHOICE = "Show Choice"
const STRING_CLOSE = "Close"
const STRING_DONE = "Done"
const STRING_SELECT_CHEER = "Select Cheer"
const STRING_END_ABILITY = "End Ability"

const DECISION_INSTRUCTIONS_MULLIGAN = "Mulligan all cards?"
const DECISION_INSTRUCTIONS_INITIAL_CHOOSE_CENTER = "Debut your Center!"
const DECISION_INSTRUCTIONS_INITIAL_CHOOSE_BACKSTAGE = "Select 0-5 backup members (debut/spot)"

const DECISION_INSTRUCTIONS_MAIN_STEP = "Main Step - Choose an action"
const DECISION_INSTRUCTIONS_PERFORMANCE_STEP = "Perform an art or end your turn"
const DECISION_INSTRUCTIONS_PLACE_HOLOMEM = "Choose a Holomem to enter the stage"
const DECISION_INSTRUCTIONS_CHOOSE_BLOOM = "Choose a Bloom card to play"
const DECISION_INSTRUCTIONS_CHOOSE_BLOOM_TARGET = "Choose a Holomem to Bloom"
const DECISION_INSTRUCTIONS_CHOOSE_BATONPASS = "Choose a Holomem for the Baton Pass"
const DECISION_INSTRUCTIONS_CHOOSE_SUPPORT_CARD = "Choose a Support card to play"
const DECISION_INSTRUCTIONS_COLLAB = "Choose a Holomem to Collab"
const DECISION_INSTRUCTIONS_BATON_PASS = "Choose a Holomem to Baton Pass"
const DECISION_INSTRUCTIONS_SEND_COLLAB_BACK = "Send Collab back?"
const DECISION_INSTRUCTIONS_CHOOSE_NEW_CENTER = "Choose a new Center"
const DECISION_INSTRUCTIONS_SWAP_CENTER = "Choose a Holomem to swap into the Center"
const DECISION_INSTRUCTIONS_PERFORMANCE_ART_TARGET = "Choose a target for this Art"
const DECISION_INSTRUCTIONS_CHOOSE_CHEER_SOURCE_HOLOMEM = "Choose a Holomem to remove Cheer from"
const DECISION_INSTRUCTIONS_CHOOSE_CHEER_TARGET_HOLOMEM = "Choose a Holomem to receive Cheer"
const DECISION_INSTRUCTIONS_MAKE_CHOICE = "Choose one effect"

const YOUR_ARCHIVE = "Your Archive"
const OPPONENT_ARCHIVE = "Opponent Archive"
const ATTACHED_CARDS = "Attached Cards"

const SkillNameMap = {
	# Oshi
	"replacement": "Replacement",
	"soyouretheenemy": "So, you're the enemy?",
	"mapinthelefthand": "Map in the left hand",
	"micintherighthand": "Mic in the right hand",
	"squeezesqueeze": "Squeeze squeeze",
	"illcrushyou": "I'll crush you",
	"guardianofcivilization": "Guardian of Civilization",
	"amazingdrawing": "Amazing Drawing",
	"hawkeye": "Hawkeye",
	"executivesorder": "Executive's Order",
	"phoenixtail": "Phoenix Tail",
	"risefromtheashes": "Rise from the Ashes",
	"comet": "Comet",
	"shootingstar": "Shooting Star",
	"prayingforrain": "Praying for rain",
	"rainshamanism": "Rain Shamanism",
	"whitebaton": "White Baton",
	"greenbaton": "Green Baton",
	"bluebaton": "Blue Baton",
	"redbaton": "Red Baton",
	"quickguard": "Quick Guard",
	"letsdoourbesteveryone": "Let's do our best, everyone!",
	"comeonagain": "Come on! Again!",
	"backshot": "Back Shot",

	# Arts
	"nunnun": "(๑╹ᆺ╹) nun nun",
	"onstage": "On stage!",
	"nunnunshiyo": "nun nun shiyo",
	"yourheartiscloudythenclear": "Your heart is cloudy... then clear!",
	"dreamlive": "Dream Live",
	"sorazsympathy": "SorAZ Sympathy",
	"embodimentofhope": "Embodiment of Hope",
	"keepworkinghard": "Keep working hard!",
	"wherenextwherenext": "Where next, where next!",
	"anaimlessjourneywithyou": "An aimless journey with you",
	"sorazgravity": "SorAZ Gravity",
	"destinysong": "Destiny Song",
	"ihadfundrawing": "I had fun drawing!",
	"brighterfuture": "Brighter Future",
	"hey": "Hey",
	"purepurepure": "Pure Pure Pure~",
	"relaxtime": "Relax Time",

	"konkanata": "Konkanata",
	"imoffnow": "I'm off now",
	"pleasegivelotsofsupport": "Please give lots of support!",
	"angelstage": "Angel Stage",
	"jetblackwings": "Jet Black Wings",
	"thankyouforyourcontinuedsupport": "Thank you for your continued support!",
	"everyonetogether": "Everyone together",
	"everyonekonsomme": "Everyone! Kon-somme!",
	"letsmakeitthebestdayever": "Let's make it the best day ever",
	"itwontstop": "It won't stop",
	"survivalpower": "Survival Power",
	"songoftheearth": "Song of the Earth",
	"nousagis": "Nousagis~",
	"luckyrabbit": "Lucky Rabbit",
	"missionstart": "Mission Start!",
	"thewholestageismine": "The whole stage is mine",
	"accesscodeid": "Access Code: ID",
	"illsingmybestsowatchme": "I'll sing my best so watch me!",
	"powerofpromise": "Power of Promise",
	"alona": "Alona!",
	"afterparty": "Afterparty",
	"akirosefantasy": "Akirose Fantasy",
	"ganbarosefortoday": "Ganbarose for today!",
	"secretkey": "Secret Key",
	"konpeko": "Konpeko!",
	"dontmissitpeko": "Don't miss it peko!",
	"kitraaaa": "Ki-t-raaaa",
	"rabbitgirlonawhitesandybeach": "Rabbit girl on a white sandy beach",
	"humanrabbitalityproject": "Human Rabbitality Project",
	"diamondintherough": "Diamond in the rough",
	"suichanwaaaakyoumokawaii": "Sui-chan Waaaa~ Kyou Mo Kawaii",
	"didiluiveyouwaiting": "Did I Luive you waiting?",
	"lureofthejetblackwings": "Lure of the Jet Black Wings",
	"konluilui": "Kon-luilui",
	"otsuluilui": "Otsu-luilui",
	"welcometotheparty": "Welcome to the party",
	"luisparty": "Lui's Party",
	"followmeclosely": "Follow me closely!",
	"hawkrave": "Hawk Rave",
	"soulguide": "Soul Guide",
	"newcostume": "New Costume",
	"streetsnap": "Street Snap",
	"amomentofsunlightfilteringthroughthetrees": "A moment of sunlight filtering through the trees",
	"thefightingmaid": "The Fighting Maid",
	"shiningcomet": "Shining Comet",
	"coldresponsekanataso": "Cold response Kanataso",
	"ohhi": "Oh, Hi",
	"goingouttogether": "Going out together",
	"coffeebreak": "Coffee Break",
	"piecesofmemories": "Pieces of Memories",
	"dontdrinkonsenwater": "Don't drink onsen water",
	"arelaxingdayattheonsen": "A relaxing day at the onsen",
	"hirys": "HiRyS!",
	"imaseisonephilim": "I'm a seiso nephilim!",
	"araara": "Ara ara",
	"mugyumugyuchat": "Mugyu Mugyu Chat",
	"zerogravityjump": "Zero Gravity Jump!",
	"otsupeko": "Otsupeko",
	"konazki": "Kon-AZKi",
	"withyouinaseasidetown": "With you in a seaside town",
	"ivecometosuchawonderfulworld": "I've come to such a wonderful world",
	"anewmap": "A new map",
	"ladiesandgentlemenkazamairohadegozaru": "Ladies and gentlemen,\nKazama Iroha de gozaru",
	"freshlypickledeggplant": "Freshly pickled eggplant",
	"wouldyoulikeone": "Would you like one?",
	"wazzup": "WAZZUP!!",
	"witnessme": "WITNESS ME!!",
	"thefunbegins": "The fun begins!",
	"disorder": "Disorder",
	"moonmoonmoonadaiyo": "Moon Moon~ Moona Dayo!",
	"otsumoona": "Otsumoona",
	"lookforwardtoit": "Look forward to it!",
	"midnightmoon": "Midnight Moon",
	"moonnightdiva": "Moon Night Diva",
	"kronichiwa": "Kronichiwa",
	"kroyasumi": "Kroyasumi",
	"oyasumikrotime": "Oyasumi Kro-Time",
	"letsmakethisanunforgettablefes": "Let's make this an unforgettable fes",
	"fastforward": "Fast Forward",
	"illgiveyouallmyenergy": "I'll give you all my energy",
	"bundleupyourcheers": "Bundle up your cheers",
	"brillianceofthewind": "Brilliance of the Wind",
	"selamatpagi": "Selamat Pagi!",
	"yourbelovedalien": "Your beloved alien",
	"imlookingforwardtoit": "I'm looking forward to it!",
	"relationsky": "Relation Sky",
	"kikkeriki": "Kikkeriki!",
	"mofumofutime": "Mofu mofu Time",
	"aufweidersehen": "auf weidersehen!",
	"iwanttoliventhingsup": "I want to liven things up!",
	"phoenixswordprincess": "Phoenix Sword Princess",
	"kneel": "Kneel.",
	"flamecoloredguidance": "Flame colored guidance",
	"majesticphoenix": "Majestic Phoenix",
	"polkaoruyo": "Polka Oruyo!",
	"ohapol": "Ohapol",
	"osopol": "Osopol",
	"sharedconciousness": "Shared Conciousness",
	"polkacircus": "Polka Circus",
	"bokobokobokobo": "Bokobokobokobo",
	"wavesswim": "Waves! Swim!",
	"becomingacat": "Becoming a cat",
	"perayaan": "Perayaan",
	"raindrops": "Raindrops",
	"onaeru": "OnAeru",
	"rainmantra": "Rain Mantra",
	"wavemantra": "Wave Mantra",
	"pekorabeyondthedoor": "Pekora ~Beyond the door~",
	"flarebeyondthedoor": "Flare ~Beyond the door~",
	"noelbeyondthedoor": "Noel ~Beyond the door~",
	"marinebeyondthedoor": "Marine ~Beyond the door~",
	"elementaryisntit": "Elementary, isn't it?",




}

const HolomemNames = {
	"airani_iofifteen": "Airani Iofifteen",
	"aki_rosenthal": "Aki Rosenthal",
	"amane_kanata": "Amane Kanata",
	"azki": "AZKi",
	"hakos_baelz": "Hakos Baelz",
	"hakui_koyori": "Hakui Koyori",
	"hoshimachi_suisei": "Hoshimachi Suisei",
	"houshou_marine": "Houshou Marine",
	"irys": "IRyS",
	"kazama_iroha": "Kazama Iroha",
	"kobo_kanaeru": "Kobo Kanaeru",
	"moona_hoshinova": "Moona Hoshinova",
	"mori_calliope": "Mori Calliope",
	"nanashi_mumei": "Nanashi Mumei",
	"omaru_polka": "Omaru Polka",
	"ouro_kronii": "Ouro Kronii",
	"shiranui_flare": "Shiranui Flare",
	"shirogane_noel": "Shirogane Noel",
	"soraz": "SorAZ",
	"takanashi_kiara": "Takanashi Kiara",
	"takane_lui": "Takane Lui",
	"tokino_sora": "Tokino Sora",
	"usada_pekora": "Usada Pekora",
	"vestia_zeta": "Vestia Zeta",
	"watson_amelia": "Watson Amelia",

	# Support Cards
	"amazingpc": "Amazing PC",
	"ankimo": "Ankimo",
	"clubemintonothingness": "Club 'em into nothingness",
	"encore": "Encore",
	"excitingpranktime": "Exciting Prank Time",
	"first_gravity": "First Gravity",
	"friend": "Friend",
	"gamingpc": "Gaming PC",
	"ganmo": "Ganmo",
	"harusaki_nodoka": "Harusaki Nodoka",
	"holofan_circle": "Holofan Circle",
	"hololiveid3rdgeneration": "Hololive ID 3rd Gen",
	"hoshimachi_suiseis_mic": "Suisei's Mic",
	"idolmic": "Idol Mic",
	"illleaveittoyou": "I'll leave it to you",
	"jobz": "Jobz",
	"kfp": "KFP",
	"kotori": "Kotori",
	"manechan": "Mane-chan",
	"nousagialliance": "Nousagi Alliance",
	"penlight": "Penlight",
	"pioneer": "Pioneer",
	"promise": "Promise",
	"rosetai": "Rosetai",
	"soyouretheenemy": "So, you're the enemy?",
	"standardpc": "Standard PC",
	"stone_axe": "Stone Axe",
	"subpc": "Sub PC",
	"thestoryofthemoonandtherabbit": "Story of Moon&Rabbit",
	"upao": "Upao",
	"zain": "Zain",
}

# Lazy placeholder for loc
func get_string(str_id) -> String:
	return str_id

func get_names(name_ids):
	var names = []
	for name_id in name_ids:
		names.append(HolomemNames[name_id])
	return names

func get_skill_string(skill_id):
	if skill_id in SkillNameMap:
		return SkillNameMap[skill_id]
	return skill_id

func get_position_string(position):
	match position:
		"center": return "Center"
		"backstage": return "Back"
		"collab": return "Collab"
		_: return "Unknown"

func get_stat_string(stat):
	match stat:
		"damage_added":
			return "Additional Damage"
		"damage_prevented":
			return "Damage Prevented"
		"power":
			return "Power"
	return "UNKNOWN"

func get_incoming_damage_str(amount, special, prevent_life_loss):
	var special_str = ""
	var prevent_str = ""
	if special:
		special_str = "Special "
	if prevent_life_loss:
		prevent_str = " (Can't lose LIFE)"
	return "Incoming %sDamage: %s%s" % [special_str, amount, prevent_str]

func get_performance_skill(performer_position, art_id, power):
	var skill = get_skill_string(art_id)
	var position_str = get_position_string(performer_position)
	return "%s: %s (%s)" % [position_str, skill, power]

func build_choose_die_result_string():
	return "Choose the next die result."

func build_use_oshi_skill_string(skill_id, cost):
	var skill_name = get_skill_string(skill_id)
	var cost_str = ""
	if cost:
		cost_str = " (%s Holopower)" % cost
	return "Oshi: [b]%s[/b]%s" % [skill_name, cost_str]

func build_archive_cheer_string(count):
	return "Choose %s Cheer to Archive." % count

func build_place_cheer_string(source:String, color:String):
	var color_str = color.to_upper()
	var source_str = source
	match source:
		"cheer_deck":
			source_str = "your Cheer Deck"
		"life":
			source_str = "your Life"
	return "Place 1 %s Cheer from %s." % [color_str, source_str]

func build_send_cheer_string(amount_min, amount_max, source):
	var source_str = source
	var action_word = "Send"
	match source:
		"archive":
			source_str = "from your Archive"
		"cheer_deck":
			source_str = "from your Cheer Deck"
		"downed_holomem":
			source_str = "from downed Holomem"
		"holomem":
			source_str = "from Holomem"
		"self":
			source_str = "from this Holomem"
		"opponent_holomem":
			source_str = "from opponent's Holomem"
			action_word = "Remove"
	var amount_str = "%s" % amount_min
	if str(amount_min) != str(amount_max):
		if str(amount_max) == "all":
			amount_str = "any amount of"
		else:
			amount_str = "%s-%s" % [amount_min, amount_max]
	return "%s %s Cheer %s." % [action_word, amount_str, source_str]

func build_order_cards_string(to, bottom):
	var dir_str = "top"
	if bottom:
		dir_str = "the bottom"
	var to_str = ""
	match to:
		"deck":
			to_str = "your deck"
		_:
			to_str = "UNKNOWN ZONE"
	return "Order these cards to place on %s of %s" % [dir_str, to_str]

func build_choose_holomem_for_effect_string(effect, amount_min, amount_max):
	if amount_min == amount_max:
		return "Choose %s Holomem for:\n%s" % [amount_min, get_effect_text(effect)]
	else:
		return "Choose %s-%s Holomem for:\n%s" % [amount_min, amount_max, get_effect_text(effect)]

func build_choose_cards_string(from_zone, to_zone, amount_min, amount_max,
	remaining_cards_action, requirement_details, special_reason):

	if special_reason:
		match special_reason:
			"bloom_debut_played_this_turn":
				return "You may choose a Bloom card from hand to play on a Debut you played this turn."
	var from_zone_str = from_zone
	var to_zone_str = to_zone
	match from_zone:
		"hand":
			from_zone_str = " from your Hand"
		"deck":
			from_zone_str = " from your Deck"
		"archive":
			from_zone_str = " from your Archive"
		"backstage":
			from_zone_str = " from your Backstage"
		"center":
			from_zone_str = " from your Center"
		"cheer_deck":
			from_zone_str = " from your Cheer Deck"
		"collab":
			from_zone_str = " from your Collab"
		"holopower":
			from_zone_str = " from your Holopower"
		"holomem":
			from_zone_str = " from this Holomem"
		"":
			from_zone_str = ""
	match to_zone:
		"archive":
			to_zone_str = "your Archive"
		"backstage":
			to_zone_str = "your Backstage"
		"center":
			to_zone_str = "your Center"
		"cheer_deck":
			to_zone_str = "your Cheer Deck"
		"collab":
			to_zone_str = "your Collab"
		"deck":
			to_zone_str = "your Deck"
		"hand":
			to_zone_str = "your Hand"
		"holomem":
			to_zone_str = "a Holomem"
		"holopower":
			to_zone_str = "your Holopower"
	var amount_str = "%s" % amount_min
	if amount_min != amount_max:
		amount_str = "%s-%s" % [amount_min, amount_max]
	var remaining_cards_str = ""
	if remaining_cards_action:
		match remaining_cards_action:
			"archive":
				remaining_cards_str = "\nArchive the remaining cards"
			"shuffle":
				remaining_cards_str = "\nShuffle the remaining cards"
			"order_on_bottom":
				remaining_cards_str = "\nOrder the rest on bottom"
			"nothing":
				remaining_cards_str = ""
			_:
				remaining_cards_str = "\nUNKNOWN REMAINING CARDS ACTION"
	var card_str = "cards"
	if amount_min == 1 and amount_max == 1:
		card_str = "card"
	var main_text = "Choose %s %s%s to move to %s%s." % [amount_str, card_str, from_zone_str, to_zone_str, remaining_cards_str]
	if "requirement" in requirement_details and requirement_details["requirement"]:
		match requirement_details["requirement"]:
			"buzz":
				main_text += "\nOnly Buzz cards"
			"color_in":
				main_text += "\nOnly %s" % "/".join(requirement_details["requirement_colors"])
			"color_matches_holomems":
				var tag_str = ""
				if "requirement_only_holomems_with_any_tag" in requirement_details and requirement_details["requirement_only_holomems_with_any_tag"]:
					tag_str = "%s " % ["/".join(requirement_details["requirement_only_holomems_with_any_tag"])]
				main_text += "\nOnly colors matching your %sHolomems on stage" % tag_str
			"specific_card":
				var card = CardDatabase.get_card(requirement_details["requirement_id"])
				var card_name = "MISSING_CARD_NAME"
				if "card_names" in card:
					card_name = get_names(card["card_names"])[0]
				main_text += "\nOnly %s" % card_name
			"holomem":
				main_text += "\nOnly Holomem"
				if requirement_details.get("requirement_buzz_blocked", false):
					main_text += " (no Buzz)"
				if requirement_details.get("requirement_bloom_levels", false):
					main_text += " (Bloom %s)" % "/".join(requirement_details["requirement_bloom_levels"])
			"holomem_bloom":
				main_text += "\nOnly Bloom"
				if requirement_details.get("requirement_buzz_blocked", false):
					main_text += " (no Buzz)"
				if requirement_details["requirement_bloom_levels"]:
					main_text += " (Bloom %s)" % "/".join(requirement_details["requirement_bloom_levels"])
			"holomem_debut":
				main_text += "\nOnly Debut"
			"holomem_debut_or_bloom":
				main_text += "\nOnly Debut/Bloom"
				if requirement_details.get("requirement_buzz_blocked", false):
					main_text += " (no Buzz)"
				if requirement_details["requirement_bloom_levels"]:
					main_text += " (Bloom %s)" % "/".join(requirement_details["requirement_bloom_levels"])
			"holomem_named":
				var name_ids = requirement_details["requirement_names"]
				var names = get_names(name_ids)
				main_text += "\nOnly Holomem (%s)" % "/".join(names)
			"limited":
				main_text += "\nOnly LIMITED"
			"item":
				main_text += "\nOnly Item"
			"mascot":
				main_text += "\nOnly Mascot"
			"fan":
				main_text += "\nOnly Fan"
			"tool":
				main_text += "\nOnly Tool"
			"event":
				main_text += "\nOnly Event"
			"cheer":
				main_text += "\nOnly Cheer"
		if "requirement_tags" in requirement_details and len(requirement_details["requirement_tags"]) > 0:
			main_text += "\nOnly Tag: %s" % "/".join(requirement_details["requirement_tags"])
		if requirement_details.get("requirement_match_oshi_color", false):
			main_text += "\nMatches Oshi Color"

	if "after_choose_effect" in requirement_details:
		main_text += "\n" + get_effect_text(requirement_details["after_choose_effect"])
	return main_text


func get_action_name(action_type:String):
	match action_type:
		Enums.GameAction_MainStepPlaceHolomem:
			return "Place Holomem"
		Enums.GameAction_MainStepBloom:
			return "Bloom"
		Enums.GameAction_MainStepCollab:
			return "Collab"
		Enums.GameAction_MainStepOshiSkill:
			return "Oshi Skill"
		Enums.GameAction_MainStepPlaySupport:
			return "Play Support"
		Enums.GameAction_MainStepBatonPass:
			return "Baton Pass"
		Enums.GameAction_MainStepBeginPerformance:
			return "Begin Performance"
		Enums.GameAction_MainStepEndTurn, Enums.GameAction_PerformanceStepEndTurn:
			return "End Turn"
		_:
			return "Unknown Action"

func get_timing_text(timing, timing_source_requirement):
	var text = ""
	match timing:
		"arts_targeting":
			text += ""
		"after_die_roll":
			if "timing_source_requirement" in timing_source_requirement:
				match timing_source_requirement["timing_source_requirement"]:
					"holomem_ability":
						text += "After Die Roll (Holomem Ability): "
			else:
				text += "After Die Roll: "
		"after_take_damage":
			text += "After taking damage: "
		"before_art":
			text += "Art: "
		"before_die_roll":
			if "timing_source_requirement":
				match timing_source_requirement:
					"holomem_ability":
						text += "Before Die Roll (Holomem Ability): "
			else:
				text += "Before Die Roll: "
		"check_cheer":
			text += ""
		"check_hp":
			text += ""
		"on_bloom_level_up":
			text += "When Bloom Level increases: "
		"on_take_damage":
			text += "When Holomem takes damage: "
		"on_down":
			text += "When Holomem is downed: "
		"on_restore_hp":
			text += "When Holomem HP restored: "
	return text

func get_condition_text(conditions):
	var text = ""
	for i in range(len(conditions)):
		var condition = conditions[i]
		match condition["condition"]:
			"attached_to":
				var required_bloom_levels = condition.get("required_bloom_levels", [])
				var bloom_str = ""
				if len(required_bloom_levels) > 0:
					bloom_str = " (Bloom %s)" % "/".join(required_bloom_levels)
				text += "If attached to %s%s: " % [HolomemNames[condition["required_member_name"]], bloom_str]
			"attached_owner_is_location":
				var location_str = ""
				match condition["condition_location"]:
					"center_or_collab":
						location_str = "Center or Collab"
				text += "Attached card's owner is %s." % location_str
			"bloom_target_is_debut":
				text += "From Debut: "
			"cards_in_hand":
				var amount_max = condition.get("amount_max", -1)
				var amount_min = condition.get("amount_min", -1)
				var amount_str = ""
				if amount_min == 0 and amount_max == 0:
					amount_str += "no"
				else:
					if amount_min == -1:
						amount_str += "at most %s" % amount_max
					elif amount_max == -1:
						amount_str += "at least %s" % amount_min
					else:
						amount_str += "%s-%s" % [amount_min, amount_max]
				text += "Cards in hand (%s): " % [amount_str]
			"center_has_any_tag":
				text += "Center has tag %s: " % ["/".join(condition["condition_tags"])]
			"center_is_color":
				text += "Is %s: " % ["/".join(condition["condition_colors"])]
			"chosen_card_has_tag":
				text += "If chosen card has tag %s: " % ["/".join(condition["condition_tags"])]
			"collab_with":
				text += "Collab with %s: " % [HolomemNames[condition["required_member_name"]]]
			"damage_ability_is_color":
				var or_oshi = ""
				if "include_oshi_ability" in condition and condition["include_oshi_ability"]:
					or_oshi = " or Oshi"
				text += "Damage from %s%s: " % [condition["condition_color"], or_oshi]
			"damaged_holomem_is_backstage":
				text += "Damaged Holomem is Back: "
			"damaged_holomem_is_center_or_collab":
				text += "Damaged Holomem is Center/Collab: "
			"downed_card_belongs_to_opponent":
				text += "Downed opponent's Holomem: "
			"downed_card_is_color":
				var color = condition["condition_color"]
				text += "Downed Holomem is %s: " % [color]
			"effect_card_id_not_used_this_turn":
				text += "Once per turn: "
			"has_attachment_of_type":
				text += "Has %s attachment: " % [condition["condition_type"]]
			"has_stacked_holomem":
				text += ""
			"holomem_on_stage":
				if "required_member_name" in condition:
					text += "%s on stage: " % [HolomemNames[condition["required_member_name"]]]
				elif "exclude_member_name" in condition:
					var not_str = " (Not %s)" % [HolomemNames[condition["exclude_member_name"]]]
					if "tag_in" in condition:
						text += "%s Holomem on stage%s: " % ["/".join(condition["tag_in"]), not_str]
			"not_used_once_per_game_effect":
				text += "Once per game: "
			"not_used_once_per_turn_effect":
				text += "Once per turn: "
			"opponent_turn":
				text += "Opponent's turn: "
			"oshi_is":
				text += "Oshi is %s: " % [HolomemNames[condition["required_member_name"]]]
			"performance_target_has_damage_over_hp":
				text += "Damage exceeds hp by %s: " % [condition["amount"]]
			"performer_is_center":
				text += "Center: "
			"performer_is_collab":
				text += "Collab: "
			"performer_is_color":
				text += "Performer is %s: " % ["/".join(condition["condition_colors"])]
			"performer_is_specific_id":
				text += "Performer is chosen card: "
			"performer_has_any_tag":
				text += "Performer has tag %s: " % ["/".join(condition["condition_tags"])]
			"played_support_this_turn":
				text += "Played a Support card this turn: "
			"self_has_cheer_color":
				text += "" #"Has %s %s Cheer: " % [condition["amount_min"], "/".join(condition["condition_colors"])]
			"stage_has_space":
				text += "Room on stage: "
			"target_color":
				text += "Weak(%s): " % [condition["color_requirement"]]
			"target_has_any_tag":
				text += "Target has tag %s: " % ["/".join(condition["condition_tags"])]
			"this_card_is_collab":
				text += "Collab position: "
			"top_deck_card_has_any_tag":
				text += "Top deck card has tag %s: " % ["/".join(condition["condition_tags"])]
	return text

func get_effect_text(effect):
	var text = ""
	if "oshi_effect" in effect:
		var limit = "1/Turn"
		if effect["limit"] == "once_per_game":
			limit = "1/Game"
		text += "-%s [b]%s[/b] (%s): " % [effect["cost"], get_skill_string(effect["skill_id"]), limit]

	if "full_english_text" in effect:
		# Override the text with the full text.
		return text + effect["full_english_text"]
	if "hide_effect_text" in effect and effect["hide_effect_text"]:
		return text
	if "timing" in effect:
		text += get_timing_text(effect["timing"], effect.get("timing_source_requirement", ""))
	if "conditions" in effect:
		text += get_condition_text(effect["conditions"])


	var effect_type = effect["effect_type"]
	match effect_type:
		"add_damage_taken":
			var amount = effect["amount"]
			text += "Increase damage by %s." % amount
		"add_turn_effect":
			var turn_effect = effect["turn_effect"]
			text += "This Turn: %s" % [get_effect_text(turn_effect)]
		"add_turn_effect_for_holomem":
			var turn_effect = effect["turn_effect"]
			text += "Choose a Holomem. This Turn: %s" % [get_effect_text(turn_effect)]
		"archive_cheer_from_holomem":
			var amount = effect["amount"]
			var from = effect["from"]
			var colors_str = ""
			if "required_colors" in effect:
				colors_str = " (%s)" % "/".join(effect["required_colors"])
			var from_str = ""
			match from:
				"self":
					from_str = "this Holomem"
			text += "Archive %s%s Cheer from %s." % [amount, colors_str, from_str]
		"archive_from_hand":
			var amount = effect["amount"]
			text += "Archive %s from hand." % amount
		"archive_this_attachment":
			text += "Archive this attachment."
		"archive_top_stacked_holomem":
			text += "Archive the Holomem under this one."
		"attach_card_to_holomem", "attach_card_to_holomem_internal":
			var limitation_str = ""
			if "to_limitation" in effect:
				match effect["to_limitation"]:
					"color_in":
						limitation_str = " (%s)" % "/".join(effect["to_limitation_colors"])
					"specific_member_name":
						limitation_str = " (%s)" % HolomemNames[effect["to_limitation_name"]]
					"tag_in":
						limitation_str = " (%s)" % "/".join(effect["to_limitation_tags"])
			text += "Attach card to Holomem%s.\n" % limitation_str
		"bonus_cheer":
			text += "Treat as %s %s Cheer for Arts." % [effect["amount"], effect["color"]]
		"bonus_hp":
			text += "+%s HP." % [effect["amount"]]
		"block_opponent_movement":
			text += "Block opponent's Center and Collab movement next turn."
		"bloom_debut_played_this_turn_to_1st":
			var location_str = ""
			match effect["location"]:
				"backstage":
					location_str = "Backstage"
			text += "Bloom a Debut %s Holomem played this turn." % location_str
		"choice":
			var choices = effect["choice"].duplicate()
			var choice_texts = []
			if len(choices) == 2 and choices[1]["effect_type"] == "pass":
				text += "You may: "
				choices = [choices[0]]
			else:
				text += "Choose one:\n"
			for choice in choices:
				choice_texts.append("- " + get_effect_text(choice))
			text += "\n".join(choice_texts)
		"choose_cards":
			var from_str = effect["from"]
			if "look_at" in effect:
				var look_at = effect["look_at"]
				if look_at == -1:
					look_at = "all"
				else:
					look_at = "the top %s" % look_at
				text += "Look at %s cards of your %s: " % [look_at, effect["from"]]
				from_str = ""
			var choose_str = build_choose_cards_string(
				from_str,
				effect["destination"],
				effect["amount_min"],
				effect["amount_max"],
				effect["remaining_cards_action"],
				effect,
				effect.get("special_reason", "")
			)
			text += choose_str
		"choose_die_result":
			text += build_choose_die_result_string()
		"deal_damage":
			var special_str = ""
			if "special" in effect and effect["special"]:
				special_str = " Special"
			var target_str = "to "
			if "opponent" in effect and effect["opponent"]:
				target_str += "opponent's "
			if "multiple_targets" in effect:
				target_str += "%s " % effect["multiple_targets"]
			match effect["target"]:
				"backstage":
					target_str += "Back Holomem"
				"center":
					target_str += "Center"
				"collab":
					target_str += "Collab"
				"center_or_collab":
					target_str += "Center or Collab"
				"self":
					target_str = "to this Holomem"
				"holomem":
					target_str = "any Holomem"
			var prevent_life_str = ""
			if "prevent_life_loss" in effect and effect["prevent_life_loss"]:
				prevent_life_str = " (Can't lose life)"
			var amount_str = str(effect["amount"])
			if amount_str == "total_damage_on_backstage":
				amount_str = "sum of damage on Backstage Holomems"
			text += "Deal %s%s damage %s%s." % [amount_str, special_str, target_str, prevent_life_str]
		"down_holomem":
			var target_str = ""
			if "target" in effect:
				match effect["target"]:
					"backstage":
						target_str = "a Backstage"
			var required_damage_str = ""
			if "required_damage" in effect:
				required_damage_str = " who has taken %s damage" % effect["required_damage"]
			var prevent_life_str = ""
			if "prevent_life_loss" in effect and effect["prevent_life_loss"]:
				prevent_life_str = " (Can't lose life)"
			text += "Down %s Holomem%s%s." % [target_str, required_damage_str, prevent_life_str]
		"draw":
			text += "Draw %s." % [effect["amount"]]
		"force_die_result":
			text += "Set next die result to %s." % [effect["die_result"]]
		"generate_holopower":
			text += "Generate %s Holopower." % [effect["amount"]]
		"modify_next_life_loss":
			var amount_str = effect["amount"]
			if effect["amount"] > 0:
				amount_str = "+" + amount_str
			text += "Lose %s LIFE." % [amount_str]
		"move_cheer_between_holomems":
			var amount = effect["amount"]
			var to_limitation = effect.get("to_limitation", "")
			var to_limitation_tags = effect.get("to_limitation_tags", [])
			var limitation_str = ""
			match to_limitation:
				"tag_in":
					limitation_str = " (Only to %s)" % "/".join(to_limitation_tags)
			text += "Move %s Cheer between your Holomems%s." % [amount, limitation_str]
		"pass":
			text += "Pass."
		"performance_life_lost_increase":
			text += "Increase life lost by %s." % [effect["amount"]]
		"place_holomem":
			text += "Place Holomem in %s" % [get_position_string(effect["location"])]
		"power_boost":
			var multiplier_str = ""
			if "multiplier" in effect:
				match effect["multiplier"]:
					"last_die_value":
						multiplier_str = " x Dice Result "
			text += "+%s Power%s." % [effect["amount"], multiplier_str]
		"power_boost_per_all_fans":
			text += "+%s Power per each Fan attached to your Holomems." % [effect["amount"]]
		"power_boost_per_archived_holomem":
			text += "+%s Power per archived Holomem." % [effect["amount"]]
		"power_boost_per_attached_cheer":
			var up_to_str = ""
			if "limit" in effect:
				up_to_str = " (up to %sx)" % effect["limit"]
			text += "+%s Power per attached Cheer%s." % [effect["amount"], up_to_str]
		"power_boost_per_backstage":
			text += "+%s Power per Back member." % [effect["amount"]]
		"power_boost_per_holomem":
			var tag_str = ""
			if "has_tag" in effect:
				tag_str = "%s " % effect["has_tag"]
			text += "+%s Power per %sHolomem." % [effect["amount"], tag_str]
		"power_boost_per_stacked":
			text += "+%s Power per stacked Holomem." % [effect["amount"]]
		"recover_downed_holomem_cards":
			text += "Recover downed Holomem's Holomem cards."
		"reduce_damage":
			if str(effect["amount"]) == "all":
				text += "Reduce all damage."
			else:
				text += "Reduce damage by %s." % [effect["amount"]]
		"reduce_required_archive_count":
			var amount = effect["amount"]
			text += "Archive %s less from Hand" % [amount]
		"repeat_art":
			text += "Repeat this Art."
		"restrict_targets_to_collab":
			text += "Restrict Arts targets to this card (except Special damage)."
		"restore_hp":
			var amount = effect["amount"]
			var target_str = ""
			match effect["target"]:
				"self":
					target_str = "to this Holomem"
				"center":
					target_str = "to Center"
				"holomem":
					if effect.get("hit_all_targets", false):
						target_str = "to all of your Holomems"
					else:
						target_str = "to a Holomem"
			var limitation_str = ""
			if "limitation" in effect:
				match effect["limitation"]:
					"color_in":
						limitation_str = "(%s)" % "/".join(effect["limitation_colors"])
			text += "Restore %s HP %s%s" % [amount, target_str, limitation_str]
		"restore_hp_INTERNAL":
			text += "Restore HP."
		"return_holomem_to_debut":
			text += "Return one of your opponent's Back Holomems to a Debut Holomem\n(remove Damage, leave Cheer, the rest returns to hand)"
		"reveal_top_deck":
			text += "Reveal the top card of your deck."
		"reroll_die":
			text += "Reroll."
		"roll_die":
			text += "Roll a die: "
			var die_effects = effect["die_effects"]
			for die_effect in die_effects:
				var sub_effects = die_effect["effects"]
				var sub_text = ""
				for i in range(len(sub_effects)):
					var sub_effect = sub_effects[i]
					if i > 0:
						sub_text += " "
					sub_text += get_effect_text(sub_effect)
				text += "%s = %s\n" % [die_effect["english_values"], sub_text]
		"send_cheer":
			text += build_send_cheer_string(effect["amount_min"], effect["amount_max"], effect["from"])
			if effect["to"] == "this_holomem":
				text += " Only to this Holomem."
			elif effect["to"] == "archive":
				text += " to Archive."
			if "from_limitation" in effect:
				match effect["from_limitation"]:
					"center":
						text += " From Center."
					"color_in":
						text += " Only %s Cheer." % ["/".join(effect["from_limitation_colors"])]
					"tag_in":
						text += " Only from %s." % ["/".join(effect["from_limitation_tags"])]
			if "to_limitation" in effect:
				match effect["to_limitation"]:
					"attached_owner":
						text += " To attached Holomem."
					"backstage":
						text += " Only to Back members."
					"center":
						text += " Only to Center."
					"center_or_collab":
						text += " Only to Center or Collab."
					"color_in":
						text += " Only to %s Holomem." % "/".join(effect["to_limitation_colors"])
					"specific_member_name":
						text += " Only to %s." % HolomemNames[effect["to_limitation_name"]]
					"tag_in":
						text += " Only to %s Holomem." % "/".join(effect["to_limitation_tags"])
			if "to_limitation_exclude_name" in effect:
				text += " (Not %s)" % [HolomemNames[effect["to_limitation_exclude_name"]]]
			if "limit_one_per_member" in effect:
				text += " (only 1 each)"
		"send_collab_back":
			if "optional" in effect and effect["optional"]:
				text += "May send Collab back."
			else:
				text += "Send Collab back."
		"set_center_hp":
			if "opponent" in effect and effect["opponent"]:
				text += "Reduce opponent's Center's remaining HP to %s." % [effect["amount"]]
			else:
				text += "Reduce your Center's remaining HP to %s." % [effect["amount"]]
		"switch_center_with_back":
			var resting_str = ""
			if "skip_resting" in effect and effect["skip_resting"]:
				resting_str = " that is not Resting"
			var opponent_str = ""
			if "opponent" in effect and effect["opponent"]:
				opponent_str = "opponent's "
			text += "Switch your %sCenter with a Back member%s." % [opponent_str, resting_str]
		"shuffle_hand_to_deck":
			text += "Shuffle your hand into your deck."

	if "negative_condition_effects" in effect:
		var negative_effects = effect["negative_condition_effects"]
		text += "\nElse: "
		for negative_effect in negative_effects:
			text += get_effect_text(negative_effect)
	if "and" in effect and "hide_and_text" not in effect:
		for and_effect in effect["and"]:
			text += "\n" + get_effect_text(and_effect)
	return text

func build_english_card_text(definition):
	var data = []
	match definition["card_type"]:
		"holomem_debut", "holomem_bloom", "holomem_spot":
			if "bloom_effects" in definition and len(definition["bloom_effects"]) > 0:
				var bloom_effects = definition["bloom_effects"]
				var text = "[b]Bloom[/b]: "
				for i in range(len(bloom_effects)):
					var effect = bloom_effects[i]
					if i > 0:
						text += " "
					text += get_effect_text(effect)

				var next_entry = {
					"colors": [],
					"text": text
				}
				data.append(next_entry)
			if "collab_effects" in definition and len(definition["collab_effects"]) > 0:
				var collab_effects = definition["collab_effects"]
				var text = "[b]Collab[/b]: "
				for i in range(len(collab_effects)):
					var effect = collab_effects[i]
					if i > 0:
						text += " "
					text += get_effect_text(effect)

				var next_entry = {
					"colors": [],
					"text": text
				}
				data.append(next_entry)
			if "gift_effects" in definition and len(definition["gift_effects"]) > 0:
				var gift_effects = definition["gift_effects"]
				var text = "[b]Gift[/b]: "
				for i in range(len(gift_effects)):
					var effect = gift_effects[i]
					if i > 0:
						text += " "
					text += get_effect_text(effect)

				var next_entry = {
					"colors": [],
					"text": text
				}
				data.append(next_entry)
			if "bloom_level_skip" in definition:
				var bloom_text = "Can bloom directly to level %s" % definition["bloom_level_skip"]
				if "bloom_level_skip_requirement" in definition:
					match definition["bloom_level_skip_requirement"]:
						"3lifeorless":
							bloom_text += " if you have 3 LIFE or less."
				var next_entry = {
					"colors": [],
					"text": bloom_text
				}
				data.append(next_entry)
			var arts = definition["arts"]
			for art in arts:
				var colors = []
				for cost in art["costs"]:
					for i in range(cost["amount"]):
						colors.append(cost["color"])
				var text = "%s: %s" % [get_skill_string(art["art_id"]), art["power"]]
				if "full_english_text" in art:
					text = art["full_english_text"]
				else:
					if "target_condition" in art:
						match art["target_condition"]:
							"center_only":
								text += "\nOnly targets Center."
					if "art_requirement" in art:
						if "art_requirement_attached_id" in art:
							var card = CardDatabase.get_card(art["art_requirement_attached_id"])
							var card_name = "MISSING_CARD_NAME"
							if "card_names" in card:
								card_name = get_names(card["card_names"])[0]
							text += "\nRequires %s attached to use." % card_name
					if "art_effects" in art:
						text += "\n"
						var arts_texts = []
						for art_effect in art["art_effects"]:
							arts_texts.append(get_effect_text(art_effect))
						text += "\n".join(arts_texts)
				var next_entry = {
					"colors": colors,
					"text": text
				}
				data.append(next_entry)
				if "on_kill_effects" in art and len(art["on_kill_effects"]) > 0:
					var kill_text = ""
					var on_kill_effects = art["on_kill_effects"]
					kill_text += "[b]On Kill[/b]: "
					for i in range(len(on_kill_effects)):
						var effect = on_kill_effects[i]
						if i > 0:
							kill_text += " "
						kill_text += get_effect_text(effect)
					var kill_entry = {
						"colors": [],
						"text": kill_text
					}
					data.append(kill_entry)
			data.append({"colors": [], "text": "Baton Pass Cost: %s" % definition["baton_cost"]})
			if "down_life_cost" in definition and definition["down_life_cost"] != 1:
				data.append({"colors": [], "text": "Life lost when downed: %s" % definition["down_life_cost"]})
		"support":
			var effects = []
			if "effects" in definition:
				effects = definition["effects"]
			var attached_effects = []
			if "attached_effects" in definition:
				attached_effects = definition["attached_effects"]
			var next_entry = {
				"colors": [],
				"text": ""
			}
			if "limited" in definition and definition["limited"]:
				data.append({"colors": [], "text": "LIMITED"})
			if definition["sub_type"] == "item":
				data.append({"colors": [], "text": "Item"})
			if definition["sub_type"] == "mascot":
				data.append({"colors": [], "text": "Mascot"})
			if definition["sub_type"] == "fan":
				data.append({"colors": [], "text": "Fan"})
			if definition["sub_type"] == "tool":
				data.append({"colors": [], "text": "Tool"})
			elif definition["sub_type"] == "event":
				data.append({"colors": [], "text": "Event"})
			if "play_conditions" in definition:
				var play_conditions = definition["play_conditions"]
				for condition in play_conditions:
					match condition["condition"]:
						"cards_in_hand":
							var amount_max = condition.get("amount_max", -1)
							var amount_min = condition.get("amount_min", -1)
							var amount_str = ""
							if amount_min == 0 and amount_max == 0:
								amount_str += "no"
							else:
								if amount_min > 0:
									amount_min -= 1
									amount_str += "at least %s" % amount_min
									if amount_max >= 0:
										amount_str += " and "
								if amount_max >= 0:
									# For play support card purposes, the max is inclusive but the text is not.
									amount_max -= 1
									amount_str += "at most %s" % amount_max
							next_entry["text"] += "Must have %s cards in hand to play (excluding this).\n" % [amount_str]
						"holopower_at_least":
							var amount = condition.get("amount")
							next_entry["text"] += "Costs %s Holopower.\n" % [amount]
					if next_entry["text"]:
						data.append(next_entry)
					next_entry = {
						"colors": [],
						"text": ""
					}
			if "play_requirements" in definition:
				var play_requirements = definition["play_requirements"]
				for requirement_name in play_requirements:
					match requirement_name:
						"cheer_to_archive_from_play":
							next_entry["text"] += "Must archive %s Cheer.\n" % [play_requirements[requirement_name]["length"]]
					data.append(next_entry)
					next_entry = {
						"colors": [],
						"text": ""
					}

			for i in range(len(effects)):
				var effect = effects[i]
				if i > 0:
					next_entry["text"] += " "
				next_entry["text"] += get_effect_text(effect)

			for i in range(len(attached_effects)):
				var effect = attached_effects[i]
				if i > 0:
					next_entry["text"] += " "
				next_entry["text"] += get_effect_text(effect)

			data.append(next_entry)
		"oshi":
			for action in definition.get("actions", []):
				var limit = "1/Turn"
				if action["limit"] == "once_per_game":
					limit = "1/Game"
				var text = "-%s [b]%s[/b] (%s): " % [action["cost"], get_skill_string(action["skill_id"]), limit]
				var effects_text = ""
				for i in range(len(action["effects"])):
					var effect = action["effects"][i]
					if i > 0 and effects_text:
						effects_text += " "
					effects_text += get_effect_text(effect)
				text += effects_text

				var next_entry = {
					"colors": [],
					"text": text
				}
				data.append(next_entry)
			for effect in definition.get("effects", []):
				var effects_text = ""
				effects_text += get_effect_text(effect)

				var next_entry = {
					"colors": [],
					"text": effects_text
				}
				data.append(next_entry)
		"cheer":
			# No card text
			pass
		_:
			assert(false, "Unknown card type")
	if "tags" in definition:
		var next_entry = {
			"colors": [],
			"text": "%s" % " ".join(definition["tags"])
		}
		data.append(next_entry)
	return data
