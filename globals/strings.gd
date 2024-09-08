extends Node


const STRING_OK = "OK"
const STRING_YES = "Yes"
const STRING_NO = "No"
const STRING_PASS = "Pass"
const STRING_CANCEL = "Cancel"
const STRING_SHOW_CHOICE = "Show Choice"

const DECISION_INSTRUCTIONS_MULLIGAN = "Mulligan all cards?"
const DECISION_INSTRUCTIONS_INITIAL_CHOOSE_CENTER = "Debut your Center!"
const DECISION_INSTRUCTIONS_INITIAL_CHOOSE_BACKSTAGE = "Select 0-5 backup members (debut/spot)"

const DECISION_INSTRUCTIONS_MAIN_STEP = "Main Step - Choose an action"
const DECISION_INSTRUCTIONS_PERFORMANCE_STEP = "Perform an art or end your turn"
const DECISION_INSTRUCTIONS_PLACE_HOLOMEM = "Choose a Holomem to enter the stage"
const DECISION_INSTRUCTIONS_CHOOSE_BLOOM = "Choose a Bloom card to play"
const DECISION_INSTRUCTIONS_CHOOSE_BLOOM_TARGET = "Choose a Holomem to Bloom"
const DECISION_INSTRUCTIONS_CHOOSE_SUPPORT_CARD = "Choose a Support card to play"
const DECISION_INSTRUCTIONS_COLLAB = "Choose a Holomem to Collab"
const DECISION_INSTRUCTIONS_BATON_PASS = "Choose a Holomem to Baton Pass"
const DECISION_INSTRUCTIONS_SEND_COLLAB_BACK = "Send Collab back?"
const DECISION_INSTRUCTIONS_CHOOSE_NEW_CENTER = "Choose a new Center"
const DECISION_INSTRUCTIONS_SWAP_CENTER = "Choose a Holomem to swap into the Center"
const DECISION_INSTRUCTIONS_PERFORMANCE_ART_TARGET = "Choose a target for this Art"
const DECISION_INSTRUCTIONS_CHOOSE_CHEER_SOURCE_HOLOMEM = "Choose a Holomem to remove Cheer from"
const DECISION_INSTRUCTIONS_CHOOSE_CHEER_TARGET_HOLOMEM = "Choose a Holomem to receive Cheer"

const SkillNameMap = {
	# Oshi
	"replacement": "Replacement",
	"soyouretheenemy": "So, you're the enemy?",
	"mapinthelefthand": "Map in the left hand",
	"micintherighthand": "Mic in the right hand",

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
}

const HolomemNames = {
	"azki": "AZKi",
	"tokino_sora": "Tokino Sora",
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

func get_performance_skill(performer_position, art_id, power):
	var skill = get_skill_string(art_id)
	var position_str = get_position_string(performer_position)
	return "%s: %s (%s)" % [position_str, skill, power]

func build_choose_die_result_string(skill_name, cost):
	var skill_name_str = ""
	if skill_name:
		if cost:
			skill_name_str = "Use [b]%s[/b] (%s Holopower)?\n" % [skill_name, cost]
		else:
			skill_name_str = "Use [b]%s[/b]?\n" % skill_name
	return "%sChoose the next die result" % [skill_name_str]

func build_use_oshi_skill_string(skill_id, cost):
	var skill_name = get_skill_string(skill_id)
	var cost_str = ""
	if cost:
		cost_str = " (%s Holopower)" % cost
	return "Oshi: [b]%s[/b]%s" % [skill_name, cost_str]

func build_archive_cheer_string(count):
	return "Choose %s Cheer to Archive" % count

func build_place_cheer_string(source:String, color:String):
	var color_str = color.to_upper()
	var source_str = source
	match source:
		"cheer_deck":
			source_str = "your Cheer Deck"
		"life":
			source_str = "your Life"
	return "Place 1 %s Cheer from %s" % [color_str, source_str]

func build_send_cheer_string(amount_min, amount_max, source):
	var source_str = source
	match source:
		"archive":
			source_str = "your Archive"
		"holomem":
			source_str = "this Holomem"
	var amount_str = "%s" % amount_min
	if amount_min != amount_max:
		amount_str = "%s-%s" % [amount_min, amount_max]
	return "Choose %s Cheer to move from %s" % [amount_str, source_str]

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

func build_choose_cards_string(from_zone, to_zone, amount_min, amount_max, remaining_cards_action, requirement_details):
	var from_zone_str = from_zone
	var to_zone_str = to_zone
	match from_zone:
		"hand":
			from_zone_str = "your hand"
		"deck":
			from_zone_str = "your deck"
		"archive":
			from_zone_str = "your archive"
		"backstage":
			from_zone_str = "your backstage"
		"center":
			from_zone_str = "your center"
		"collab":
			from_zone_str = "your collab"
		"holopower":
			from_zone_str = "your Holopower"
	match to_zone:
		"hand":
			to_zone_str = "your hand"
		"deck":
			to_zone_str = "your deck"
		"archive":
			to_zone_str = "your archive"
		"backstage":
			to_zone_str = "your backstage"
		"center":
			to_zone_str = "your center"
		"collab":
			to_zone_str = "your collab"
		"holopower":
			to_zone_str = "your Holopower"
	var amount_str = "%s" % amount_min
	if amount_min != amount_max:
		amount_str = "%s-%s" % [amount_min, amount_max]
	var remaining_cards_str = ""
	if remaining_cards_action:
		match remaining_cards_action:
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
	var main_text = "Choose %s %s from %s to move to %s%s" % [amount_str, card_str, from_zone_str, to_zone_str, remaining_cards_str]
	if requirement_details and requirement_details["requirement"]:
		match requirement_details["requirement"]:
			"limited":
				main_text += "\nLIMITED cards only"
			"holomem_bloom":
				main_text += "\nBloom cards only"
				if requirement_details["requirement_buzz_blocked"]:
					main_text += " (no Buzz)"
			"holomem_named":
				var name_ids = requirement_details["requirement_names"]
				var names = get_names(name_ids)
				main_text += "\nOnly: %s" % ", ".join(names)
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
