extends Node


var STRING_OK = "OK"
var STRING_YES = "Yes"
var STRING_NO = "No"
var STRING_PASS = "Pass"
var STRING_CANCEL = "Cancel"
var STRING_SHOW_CHOICE = "Show Choice"
var STRING_CLOSE = "Close"
var STRING_DONE = "Done"
var STRING_SELECT_CHEER = "Select Cheer"
var STRING_END_ABILITY = "End Ability"

var DECISION_INSTRUCTIONS_MULLIGAN = "Mulligan all cards?"
var DECISION_INSTRUCTIONS_INITIAL_CHOOSE_CENTER = "Debut your Center!"
var DECISION_INSTRUCTIONS_INITIAL_CHOOSE_BACKSTAGE = "Select 0-5 backup members (Debut/Spot)"

var DECISION_INSTRUCTIONS_MAIN_STEP = "Main Step - Choose an action"
var DECISION_INSTRUCTIONS_PERFORMANCE_STEP = "Perform an art or end your turn"
var DECISION_INSTRUCTIONS_PLACE_HOLOMEM = "Choose a Holomem to enter the stage"
var DECISION_INSTRUCTIONS_CHOOSE_BLOOM = "Choose a Bloom card to play"
var DECISION_INSTRUCTIONS_CHOOSE_BLOOM_TARGET = "Choose a Holomem to Bloom"
var DECISION_INSTRUCTIONS_CHOOSE_BATONPASS = "Choose a Holomem for the Baton Pass"
var DECISION_INSTRUCTIONS_CHOOSE_SUPPORT_CARD = "Choose a Support card to play"
var DECISION_INSTRUCTIONS_COLLAB = "Choose a Holomem to Collab"
var DECISION_INSTRUCTIONS_BATON_PASS = "Choose a Holomem to Baton Pass"
var DECISION_INSTRUCTIONS_SEND_COLLAB_BACK = "Send Collab back?"
var DECISION_INSTRUCTIONS_CHOOSE_NEW_CENTER = "Choose a new Center"
var DECISION_INSTRUCTIONS_SWAP_CENTER = "Choose a Holomem to swap into the Center"
var DECISION_INSTRUCTIONS_PERFORMANCE_ART_TARGET = "Choose a target for this Art"
var DECISION_INSTRUCTIONS_CHOOSE_CHEER_SOURCE_HOLOMEM = "Choose a Holomem to remove Cheer from"
var DECISION_INSTRUCTIONS_CHOOSE_CHEER_TARGET_HOLOMEM = "Choose a Holomem to receive Cheer"
var DECISION_INSTRUCTIONS_MAKE_CHOICE = "Choose one effect"

var YOUR_ARCHIVE = "Your Archive"
var OPPONENT_ARCHIVE = "Opponent Archive"
var ATTACHED_CARDS = "Attached Cards"

# Lazy placeholder for loc
func get_string(str_id) -> String:
	return tr(str_id)

func get_names(name_ids):
	var names = []
	for name_id in name_ids:
		names.append(tr(name_id))
	return names

func get_requirement_names(effects):
	var names = []
	for effect in effects:
		names.append_array(effect.get("requirement_names", []))
	return get_names(names)

func get_tags(card_definition):
	var card_tags = []
	card_tags.append_array(card_definition.get("tags", []))
	for effect in card_definition.get("effects", []):
		card_tags.append_array(effect.get("requirement_tags", []))
	return card_tags

func get_tags_strings(tags: Array) -> Array:
	return tags.map(get_string)

func get_skill_string(skill_id):
	return tr(skill_id)

func get_position_string(position):
	match position:
		"center": return tr("Center")
		"backstage": return tr("Back")
		"collab": return tr("Collab")
		_: return "Unknown"

func get_color_string(color_str):
	match color_str:
		"any": return tr("Any-Color")
		"red": return tr("Red")
		"blue": return tr("Blue")
		"green": return tr("Green")
		"yellow": return tr("Yellow")
		"purple": return tr("Purple")
		"white": return tr("White")
		"none": return tr("None-Color")
		_: return "UNKNOWN_COLOR"

func get_color_strings(color_strs):
	var color_names = []
	for color_str in color_strs:
		color_names.append(get_color_string(color_str))
	return color_names

func get_stat_string(stat):
	match stat:
		"damage_added":
			return tr("Additional Damage")
		"damage_prevented":
			return tr("Damage Prevented")
		"power":
			return tr("Power")
	return "UNKNOWN"

func get_incoming_damage_str(amount, special, prevent_life_loss):
	var special_str = ""
	var prevent_str = ""
	if special:
		special_str = "Special "
	if prevent_life_loss:
		prevent_str = " " + tr("(Can't lose LIFE)")
	return tr("Incoming {SpecialStr}Damage: {Amount}{PreventStr}").format({SpecialStr = special_str, Amount = amount, PreventStr = prevent_str})

func get_performance_skill(performer_position, art_id, power):
	var skill = get_skill_string(art_id)
	var position_str = get_position_string(performer_position)
	return "%s: %s (%s)" % [position_str, skill, power]

func build_mulligan_instructions(is_first_player : bool):
	if is_first_player:
		return tr("You are first player.") + "\n" + Strings.get_string(Strings.DECISION_INSTRUCTIONS_MULLIGAN)
	return tr("You are second player.") + "\n" + Strings.get_string(Strings.DECISION_INSTRUCTIONS_MULLIGAN)

func build_choose_die_result_string():
	return tr("Choose the next die result.")

func build_use_oshi_skill_string(skill_id, cost):
	var skill_name = get_skill_string(skill_id)
	var cost_str = ""
	if cost:
		cost_str = " " + tr("({HoloPowerAmount} Holopower)").format({HoloPowerAmount = cost})
	return tr("Oshi:") + "[b]%s[/b]%s" % [skill_name, cost_str]

func build_archive_cheer_string(count):
	return tr("Choose %s Cheer to Archive.") % count

func build_place_cheer_string(source:String, color:String):
	var color_str = get_color_string(color).to_upper()
	var source_str = source
	match source:
		"cheer_deck":
			source_str = tr("YOUR_CHEER_DECK")
		"life":
			source_str = tr("YOUR_LIFE")
	return tr("Place 1 {COLOR} Cheer from {SOURCE}.").format({COLOR = color_str, SOURCE = source_str})

func get_card_location_string(location):
	var source_str = ""
	match location:
		"archive":
			source_str = tr("FROM_YOUR_ARCHIVE")
		"cheer_deck":
			source_str = tr("FROM_YOUR_CHEER_DECK")
		"downed_holomem":
			source_str = tr("FROM_DOWNED_HOLOMEM")
		"hand":
			source_str = tr("FROM_YOUR_HAND")
		"holopower":
			source_str = tr("FROM_YOUR_HOLOPOWER")
		"holomem":
			source_str = tr("FROM_HOLOMEM")
		"self":
			source_str = tr("FROM_THIS_HOLOMEM")
		"opponent_holomem":
			source_str = tr("FROM_OPPONENT_HOLOMEM")
		_:
			source_str = location
	return source_str

func get_action_word_for_location(location):
	var action_word = tr("Send")
	match location:
		"opponent_holomem":
			action_word = tr("REMOVE_CHEER_ACTION_WORD")
		_:
			action_word = tr("Send")
	return action_word

func build_send_cheer_string(amount_min, amount_max, source):
	var action_word = get_action_word_for_location(source)
	var source_str = get_card_location_string(source)
	var amount_str = "%s" % amount_min
	if str(amount_min) != str(amount_max):
		if str(amount_max) == "all":
			amount_str = tr("any amount of")
		else:
			amount_str = "%s-%s" % [amount_min, amount_max]
	return tr("{ACTION} {AMOUNT} Cheer {SOURCE}.").format({ACTION = action_word, AMOUNT = amount_str, SOURCE = source_str})

func build_order_cards_string(to, bottom):
	var dir_str = tr("top")
	if bottom:
		dir_str = tr("the bottom")
	var to_str = ""
	match to:
		"deck":
			to_str = tr("your deck")
		_:
			to_str = "UNKNOWN ZONE"
	return tr("Order these cards to place on {DIR} of {DECK}").format({DIR = dir_str, DECK = to_str})

func build_choose_holomem_for_effect_string(effect, amount_min, amount_max):
	if amount_min == amount_max:
		return tr("Choose {MIN} Holomem for:").format({MIN = amount_min}) + "\n" + get_effect_text(effect)
	else:
		return tr("Choose {MIN}-{MAX} Holomem for:").format({MIN = amount_min, MAX = amount_max}) + "\n" + get_effect_text(effect)

func build_choose_cards_string(from_zone, to_zone, amount_min, amount_max,
	remaining_cards_action, requirement_details, special_reason):

	if special_reason:
		match special_reason:
			"bloom_debut_played_this_turn":
				return tr("You may choose a Bloom card from hand to play on a Debut you played this turn.")
	var from_zone_str = from_zone
	var to_zone_str = to_zone
	match from_zone:
		"hand":
			from_zone_str = tr("FROM_YOUR_HAND")
		"deck":
			from_zone_str = tr("FROM_YOUR_DECK")
		"archive":
			from_zone_str = tr("FROM_YOUR_ARCHIVE")
		"backstage":
			from_zone_str = tr("FROM_YOUR_BACKSTAGE")
		"center":
			from_zone_str = tr("FROM_YOUR_CENTER")
		"cheer_deck":
			from_zone_str = tr("FROM_YOUR_CHEER_DECK")
		"collab":
			from_zone_str = tr("FROM_YOUR_COLLAB")
		"holopower":
			from_zone_str = tr("FROM_YOUR_HOLOPOWER")
		"holomem":
			from_zone_str = tr("FROM_THIS_HOLOMEM")
		"":
			from_zone_str = ""
	match to_zone:
		"archive":
			to_zone_str = tr("YOUR_ARCHIVE")
		"backstage":
			to_zone_str = tr("YOUR_BACKSTAGE")
		"bottom_of_deck":
			to_zone_str = tr("YOUR_BOTTOM_OF_DECK")
		"center":
			to_zone_str = tr("YOUR_CENTER")
		"cheer_deck":
			to_zone_str = tr("YOUR_CHEER_DECK")
		"collab":
			to_zone_str = tr("YOUR_COLLAB")
		"deck":
			to_zone_str = tr("YOUR_DECK")
		"hand":
			to_zone_str = tr("YOUR_HAND")
		"holomem":
			to_zone_str = tr("A_HOLOMEM")
		"holopower":
			to_zone_str = tr("YOUR_HOLOPOWER")
	# requirement_details is actually the effect itself
	var to_limitation_str = ""
	if "to_limitation" in requirement_details:
		var effect = requirement_details
		match requirement_details["to_limitation"]:
			"color_in":
				to_limitation_str = " (%s)" % "/".join(get_color_strings(effect["to_limitation_colors"]))
			"specific_member_name":
				to_limitation_str = " (%s)" % get_names([effect["to_limitation_name"]])[0]
			"tag_in":
				to_limitation_str = " (%s)" % "/".join(get_tags_strings(effect["to_limitation_tags"]))
			"backstage":
				to_limitation_str = " (%s)" % tr("Only to Back members.")
	var amount_str = "%s" % amount_min
	if amount_min != amount_max:
		amount_str = "%s-%s" % [amount_min, amount_max]
	var remaining_cards_str = ""
	if remaining_cards_action:
		match remaining_cards_action:
			"archive":
				remaining_cards_str = "\n" + tr("Archive the remaining cards")
			"shuffle":
				remaining_cards_str = "\n" + tr("Shuffle the remaining cards")
			"order_on_bottom":
				remaining_cards_str = "\n" + tr("Order the rest on bottom")
			"nothing":
				remaining_cards_str = ""
			_:
				remaining_cards_str = "\nUNKNOWN REMAINING CARDS ACTION"
	var card_str = tr("cards")
	if amount_min == 1 and amount_max == 1:
		card_str = tr("card")
	var main_text = tr("Choose {AMOUNT} {CARD} {FROMZONE} to move to {TOZONE}{TOLIMITATION}{REMAIN}.")\
		.format({AMOUNT = amount_str, CARD = card_str, FROMZONE = from_zone_str, TOZONE = to_zone_str, \
			TOLIMITATION=to_limitation_str, REMAIN = remaining_cards_str})
	if "requirement" in requirement_details and requirement_details["requirement"]:
		match requirement_details["requirement"]:
			"buzz":
				main_text += "\n" + tr("ONLY_BUZZ")
			"color_in":
				main_text += "\n" + tr("ONLY_COLOR %s") % "/".join(get_color_strings(requirement_details["requirement_colors"]))
			"color_matches_holomems":
				var tag_str = ""
				if "requirement_only_holomems_with_any_tag" in requirement_details and requirement_details["requirement_only_holomems_with_any_tag"]:
					tag_str = "%s " % ["/".join(requirement_details["requirement_only_holomems_with_any_tag"])]
				main_text += "\n" + tr("Only colors matching your %sHolomems on stage") % tag_str
			"specific_card":
				var card = CardDatabase.get_card(requirement_details["requirement_id"])
				var card_name = "MISSING_CARD_NAME"
				if "card_names" in card:
					card_name = get_names(card["card_names"])[0]
				main_text += "\n" + tr("ONLY_CARD %s") % card_name
			"holomem":
				main_text += "\n" + tr("ONLY_HOLOMEM")
				if requirement_details.get("requirement_buzz_blocked", false):
					main_text += " " + tr("(no Buzz)")
				if requirement_details.get("requirement_bloom_levels", false):
					main_text += " " + tr("(Bloom %s)") % "/".join(requirement_details["requirement_bloom_levels"])
			"holomem_bloom":
				main_text += "\n" + tr("ONLY_BLOOM")
				if requirement_details.get("requirement_buzz_blocked", false):
					main_text += " " + tr("(no Buzz)")
				if requirement_details["requirement_bloom_levels"]:
					main_text += " " + tr("(Bloom %s)") % "/".join(requirement_details["requirement_bloom_levels"])
			"holomem_debut":
				main_text += "\n" + tr("ONLY_DEBUT")
			"holomem_debut_or_bloom":
				main_text += "\n" + tr("ONLY_DEBUT_BLOOM")
				if requirement_details.get("requirement_buzz_blocked", false):
					main_text += " " + tr("(no Buzz)")
				if requirement_details["requirement_bloom_levels"]:
					main_text += " " + tr("(Bloom %s)") % "/".join(requirement_details["requirement_bloom_levels"])
			"holomem_named":
				var name_ids = requirement_details["requirement_names"]
				var names = get_names(name_ids)
				main_text += "\n" + tr("ONLY_HOLOMEM (%s)") % "/".join(names)
			"limited":
				main_text += "\n" + tr("ONLY_LIMITED")
			"support":
				var sub_types = (requirement_details.get("requirement_sub_types", [])
					.map(func(sub_type): return tr("ONLY_" + sub_type.to_upper())))
				main_text += "\n" + ", ".join(sub_types)
			"cheer":
				main_text += "\n" + tr("ONLY_CHEER")
		if requirement_details.get("requirement_block_limited", false):
			main_text += "\n" + tr("NO_LIMITED_CARDS")
		if "requirement_tags" in requirement_details and len(requirement_details["requirement_tags"]) > 0:
			main_text += "\n" + tr("Only Tag: %s") % "/".join(get_tags_strings(requirement_details["requirement_tags"]))
		if requirement_details.get("requirement_match_oshi_color", false):
			main_text += "\n" + tr("Matches Oshi Color")

	if "after_choose_effect" in requirement_details:
		main_text += "\n" + get_effect_text(requirement_details["after_choose_effect"])
	return main_text


func get_action_name(action_type:String):
	match action_type:
		Enums.GameAction_MainStepPlaceHolomem:
			return tr("Place Holomem")
		Enums.GameAction_MainStepBloom:
			return tr("Bloom")
		Enums.GameAction_MainStepCollab:
			return tr("Collab")
		Enums.GameAction_MainStepOshiSkill:
			return tr("Oshi Skill")
		Enums.GameAction_MainStepPlaySupport:
			return tr("Play Support")
		Enums.GameAction_MainStepBatonPass:
			return tr("Baton Pass")
		Enums.GameAction_MainStepBeginPerformance:
			return tr("Begin Performance")
		Enums.GameAction_MainStepEndTurn, Enums.GameAction_PerformanceStepEndTurn:
			return tr("End Turn")
		Enums.GameAction_PerformanceStepCancel:
			return tr("Cancel")
		_:
			return "Unknown Action"

func get_timing_text(timing, timing_source_requirement):
	var text = ""
	match timing:
		"art_cleanup":
			text += ""
		"arts_targeting":
			text += ""
		"after_die_roll":
			if "timing_source_requirement" in timing_source_requirement:
				match timing_source_requirement["timing_source_requirement"]:
					"holomem_ability":
						text += tr("After Die Roll (Holomem Ability):") + " "
			else:
				text += tr("After Die Roll:") + " "
		"after_take_damage":
			text += tr("After taking damage:") + " "
		"before_art":
			text += tr("Art:") + " "
		"before_die_roll":
			if "timing_source_requirement":
				match timing_source_requirement:
					"holomem_ability":
						text += tr("Before Die Roll (Holomem Ability):") + " "
			else:
				text += tr("Before Die Roll:") + " "
		"check_cheer":
			text += ""
		"check_hp":
			text += ""
		"on_bloom_level_up":
			text += tr("When Bloom Level increases:") + " "
		"on_take_damage":
			text += tr("When Holomem takes damage:") + " "
		"on_down":
			text += tr("When Holomem is downed:") + " "
		"on_restore_hp":
			text += tr("When Holomem HP restored:") + " "
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
					bloom_str = " " + tr("(Bloom %s)") % "/".join(required_bloom_levels)
				text += "If attached to %s%s: " % [get_names([condition["required_member_name"]])[0], bloom_str]
			"attached_to_has_tags":
				var tags_str = "/".join(get_tags_strings(condition["required_tags"]))
				if condition.get("inverse", false):
					# Example: `If attached to Holomem without tags #Song/#Art: `
					text += tr("CONDITION__ATTACHED_TO_HAS_TAGS_INVERSE").format({Tags=tags_str})
				else:
					# Example: `If attached to Holomem with tags #Song/#Art: `
					text += tr("CONDITION__ATTACHED_TO_HAS_TAGS").format({Tags=tags_str})
			"attached_owner_is_location":
				var location_str = ""
				match condition["condition_location"]:
					"center_or_collab":
						location_str = tr("CEN_COL_POSITION")
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
				text += tr("Center has tag %s:") % ["/".join(get_tags_strings(condition["condition_tags"]))] + " "
			"center_is_color":
				text += tr("Is %s:") % ["/".join(get_color_strings(condition["condition_colors"]))] + " "
			"chosen_card_has_tag":
				text += "If chosen card has tag %s: " % ["/".join(get_tags_strings(condition["condition_tags"]))]
			"collab_with":
				text += "Collab with %s: " % [get_names([condition["required_member_name"]])[0]]
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
			"has_attached_card":
				text += "If %s is attached: " % get_names([condition["required_card_name"]])[0]
			"has_attachment_of_type":
				text += "Has %s attachment: " % [condition["condition_type"]]
			"has_stacked_holomem":
				text += ""
			"holomem_in_archive":
				var amount_str = ""
				if "amount_min" in condition and "amount_max" not in condition:
					amount_str += "%s+" % condition["amount_min"]
				var tags_str = (" %s" % "/".join(get_tags_strings(condition["tag_in"]))) if "tag_in" in condition else ""
				# Example: `1+ #Myth Holomem in Archive: `
				text += tr("CONDITION__HOLOMEM_IN_ARCHIVE").format({Amount=amount_str, Tags=tags_str})
			"holomem_on_stage":
				var location_str = ""
				match condition.get("location"):
					"center":
						location_str = tr("Center")
					"collab":
						location_str = tr("Collab")
					_:
						location_str = "stage"

				if "required_member_name_in" in condition:
					text += "%s on %s: " % ["/".join(get_names(condition["required_member_name_in"])), location_str]
				elif "exclude_member_name_in" in condition:
					var not_str = " (Not %s)" % "/".join(get_names(condition["exclude_member_name_in"]))
					if "tag_in" in condition:
						text += "%s Holomem on %s%s: " % ["/".join(get_tags_strings(condition["tag_in"])), location_str, not_str]
				else:
					if "tag_in" in condition:
						text += "%s Holomem on %s: " % ["/".join(get_tags_strings(condition["tag_in"])), location_str]
			"not_used_once_per_game_effect":
				text += "Once per game: "
			"not_used_once_per_turn_effect":
				text += "Once per turn: "
			"opponent_turn":
				text += "Opponent's turn: "
			"oshi_is":
				text += tr("OshiIsMemberString") % [get_names([condition["required_member_name"]])[0]] + " "
			"oshi_is_color":
				text += tr("OshiIsColorString") % ["/".join(get_color_strings(condition["condition_colors"]))] + " "
			"performance_target_has_damage_over_hp":
				text += "Damage exceeds hp by %s: " % [condition["amount"]]
			"performer_is_center":
				text += tr("Center:") + " "
			"performer_is_collab":
				text += tr("Collab:") + " "
			"performer_is_color":
				text += tr("Performer is %s:") % ["/".join(get_color_strings(condition["condition_colors"]))] + " "
			"performer_is_specific_id":
				text += tr("Performer is chosen card:") + " "
			"performer_has_any_tag":
				text += tr("Performer has tag %s:") % ["/".join(get_tags_strings(condition["condition_tags"]))] + " "
			"played_support_this_turn":
				text += tr("Played a Support card this turn:") + " "
			"self_has_cheer_color":
				var amount_str = condition["amount_min"]
				var colors_str = "/".join(get_color_strings(condition["condition_colors"]))
				# Example: `Has 1 Red/Blue Cheer: `
				text += tr("CONDITION__SELF_HAS_CHEER_COLOR").format({Amount=amount_str, Colors=colors_str})
			"stage_has_space":
				text += tr("Room on stage:") + " "
			"target_color":
				text += tr("Weak(%s):") % [get_color_string(condition["color_requirement"])] + " "
			"target_has_any_tag":
				text += tr("Target has tag %s:") % ["/".join(get_tags_strings(condition["condition_tags"]))] + " "
			"this_card_is_center":
				text += tr("Center position:") + " "
			"this_card_is_collab":
				text += tr("Collab position:") + " "
			"top_deck_has_any_card_type":
				var card_types_str = "/".join(condition["condition_card_types"].map(get_string))
				text += tr("Top deck card is %s:") % [card_types_str] + " "
			"top_deck_card_has_any_tag":
				text += tr("Top deck card has tag %s:") % ["/".join(get_tags_strings(condition["condition_tags"]))] + " "
	return text

func get_effect_text(effect):
	var text = ""
	if "oshi_effect" in effect:
		var limit = tr("1/Turn")
		if effect["limit"] == "once_per_game":
			limit = tr("1/Game")
		text += "-%s [b]%s[/b] (%s): " % [effect["cost"], get_skill_string(effect["skill_id"]), limit]

	if "full_english_text" in effect:
		# Override the text with the full text.
		return text + tr(effect["full_english_text"])
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
			text += tr("This Turn: %s") % [get_effect_text(turn_effect)]
		"add_turn_effect_for_holomem":
			var turn_effect = effect["turn_effect"]
			var limitation = effect.get("limitation", "")
			if limitation == "last_chosen_holomem":
				text += tr("This Turn: %s") % [get_effect_text(turn_effect)]
			else:
				text += tr("Choose a Holomem. This Turn: %s") % [get_effect_text(turn_effect)]
				match limitation:
					"color_in":
						text += "\n" + tr("ONLY_COLOR %s") % "/".join(get_color_strings(effect["limitation_colors"]))
		"archive_cheer_from_holomem":
			var amount = effect["amount"]
			var from = effect["from"]
			var colors_str = ""
			if "required_colors" in effect:
				colors_str = " (%s)" % "/".join(get_color_strings(effect["required_colors"]))
			var from_str = ""
			match from:
				"self":
					from_str = tr("this Holomem")
			text += tr("Archive {Amount}{Colors} Cheer from {Location}.").format({Amount = amount, Colors = colors_str, Location = from_str})
		"archive_from_hand":
			var amount = effect["amount"]
			var requirement = (" " + tr(effect["requirement"])) if "requirement" in effect else ""
			text += tr("Archive {Amount}{Requirement} from hand.").format({Amount = amount, Requirement = requirement})
		"archive_this_attachment":
			text += "Archive this attachment."
		"archive_top_stacked_holomem":
			text += "Archive the Holomem under this one."
		"attach_card_to_holomem", "attach_card_to_holomem_internal":
			var limitation_str = ""
			if "to_limitation" in effect:
				match effect["to_limitation"]:
					"color_in":
						limitation_str = " (%s)" % "/".join(get_color_strings(effect["to_limitation_colors"]))
					"specific_member_name":
						limitation_str = " (%s)" % get_names([effect["to_limitation_name"]])[0]
					"tag_in":
						limitation_str = " (%s)" % "/".join(get_tags_strings(effect["to_limitation_tags"]))
			text += tr("Attach card to Holomem%s.") % limitation_str + "\n"
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
					look_at = tr("all")
				else:
					look_at = tr("the top %s") % look_at
				text += tr("Look at {Look} cards of your {Location}:").format({Look = look_at, Location = get_card_location_string(effect["from"])}) + " "
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
				special_str = " " + tr("Special")
			var target_str = tr("to") + " "
			if "opponent" in effect and effect["opponent"]:
				target_str += tr("opponent's") + " "
			if "multiple_targets" in effect:
				target_str += "%s " % effect["multiple_targets"]
			match effect["target"]:
				"backstage":
					target_str += tr("BACKHOLOMEM_POSITION")
				"center":
					target_str += tr("CENTER_POSITION")
				"collab":
					target_str += tr("COLLAB_POSITION")
				"center_or_collab":
					target_str += tr("CEN_COL_POSITION")
				"self":
					target_str = tr("THIS_HOLOMEM_POSITION")
				"holomem":
					target_str = tr("ANY_HOLOMEM_POSITION")
			var prevent_life_str = ""
			if "prevent_life_loss" in effect and effect["prevent_life_loss"]:
				prevent_life_str = " " + tr("(Can't lose life)")
			var amount_str = str(effect["amount"])
			if amount_str == "total_damage_on_backstage":
				amount_str = tr("sum of damage on Backstage Holomems")
			text += tr("Deal {Amount}{Special} damage {Target}{PreventLife}.").format({
				Amount = amount_str,
				Special = special_str,
				Target = target_str,
				PreventLife = prevent_life_str
			})
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
			var draw_to_hand_size = effect.get("draw_to_hand_size")
			if draw_to_hand_size:
				text += tr("Draw until you have %s cards in hand") % draw_to_hand_size
			else:
				text += tr("Draw %s.") % [effect["amount"]]
		"force_die_result":
			text += tr("Set next die result to %s.") % [effect["die_result"]]
		"generate_holopower":
			text += "Generate %s Holopower." % [effect["amount"]]
		"go_first":
			var first = effect["first"]
			if first:
				text += tr("Go first.")
			else:
				text += tr("Go second.")
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
					limitation_str = " (Only to %s)" % "/".join(get_tags_strings(to_limitation_tags))
			text += "Move %s Cheer between your Holomems%s." % [amount, limitation_str]
		"pass":
			text += tr("Pass") + "."
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
			var exclude_str = ""
			match effect.get("exclude"):
				"self":
					exclude_str = " other than this "
			var up_to_str = ""
			if "limit" in effect:
				up_to_str = " (up to %sx)" % effect["limit"]
			text += "+%s Power per %s%sHolomem%s." % [effect["amount"], tag_str, exclude_str, up_to_str]
		"power_boost_per_stacked":
			text += tr("+%s Power per stacked Holomem.") % [effect["amount"]]
		"power_boost_per_played_support":
			var support_type = tr(effect["support_sub_type"])
			text += tr("+%s Power per %s played this turn.") % [effect["amount"], support_type]
		"recover_downed_holomem_cards":
			text += "Recover downed Holomem's Holomem cards."
		"reduce_damage":
			if str(effect["amount"]) == "all":
				text += "Reduce all damage."
			else:
				text += "Reduce damage by %s." % [effect["amount"]]
		"reduce_required_archive_count":
			var amount = effect["amount"]
			var cheer_color = effect.get("cheer_color")
			if cheer_color:
				text += "Archive %s less %s cheer from Holomem" % [amount, "/".join(cheer_color.map(get_color_string))]
			else:
				text += "Archive %s less from Hand" % [amount]
		"repeat_art":
			text += tr("Repeat this Art.")
		"restrict_targets_to_collab":
			text += "Restrict Arts targets to this card (except Special damage)."
		"restore_hp":
			var amount = effect["amount"]
			var amount_str = ""
			if str(amount) == "all":
				amount_str = tr("all_amount")
			elif str(amount) == "damage_dealt_floor_round_to_10s":
				amount_str = tr("damage_dealt_floor_round_to_10s")
			else:
				amount_str = "+%s" % amount
			var target_str = ""
			match effect["target"]:
				"attached_owner":
					target_str = tr("ATTACHED_OWNER_EFFECT_STRING")
				"self":
					target_str = tr("THIS_HOLOMEM_POSITION")
				"backstage":
					target_str = tr("BACKHOLOMEM_POSITION")
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
						limitation_str = " (%s)" % "/".join(effect["limitation_colors"])
					"tag_in":
						limitation_str = " (%s)" % "/".join(get_tags_strings(effect["limitation_tags"]))
			text += "Restore %s HP %s%s" % [amount_str, target_str, limitation_str]
		"restore_hp_INTERNAL":
			text += "Restore HP."
		"return_holomem_to_debut":
			text += "Return one of your opponent's Back Holomems to a Debut Holomem\n(remove Damage, leave Cheer, the rest returns to hand)"
		"reveal_top_deck":
			text += tr("Reveal the top card of your deck.")
		"reroll_die":
			text += tr("Reroll.")
		"roll_die":
			text += tr("Roll a die:") + " "
			var die_effects = effect["die_effects"]
			for die_effect in die_effects:
				var sub_effects = die_effect["effects"]
				var sub_text = ""
				for i in range(len(sub_effects)):
					var sub_effect = sub_effects[i]
					if i > 0:
						sub_text += " "
					sub_text += get_effect_text(sub_effect)
				text += "%s = %s\n" % [tr(die_effect["english_values"]), sub_text]
		"send_cheer":
			text += build_send_cheer_string(effect["amount_min"], effect["amount_max"], effect["from"])
			if effect["to"] == "this_holomem":
				text += " " + tr("Only to this Holomem.")
			elif effect["to"] == "archive":
				text += " " + tr("to Archive.")
			if "from_limitation" in effect:
				match effect["from_limitation"]:
					"center":
						text += " " + tr("From Center.")
					"color_in":
						text += " " + tr("Only %s Cheer.") % ["/".join(effect["from_limitation_colors"])]
					"tag_in":
						text += " " + tr("Only from %s.") % ["/".join(get_tags_strings(effect["from_limitation_tags"]))]
			if "to_limitation" in effect:
				match effect["to_limitation"]:
					"attached_owner":
						text += " " + tr("To attached Holomem.")
					"backstage":
						text += " " + tr("Only to Back members.")
					"center":
						text += " " + tr("Only to Center.")
					"center_or_collab":
						text += " " + tr("Only to Center or Collab.")
					"color_in":
						text += " " + tr("Only to %s Holomem.") % "/".join(effect["to_limitation_colors"])
					"specific_member_name":
						text += " " + tr("Only to %s.") % get_names([effect["to_limitation_name"]])[0]
					"tag_in":
						text += " " + tr("Only to %s Holomem.") % "/".join(get_tags_strings(effect["to_limitation_tags"]))
					"card_type":
						match effect["to_limitation_card_type"]:
							"holomem_debut":
								text += " " + tr("ONLY_DEBUT")
			if "to_limitation_exclude_name" in effect:
				text += " " + tr("(Not %s)") % [get_names([effect["to_limitation_exclude_name"]])[0]]
			if "limit_one_per_member" in effect:
				text += " " + tr("(only 1 each)")
		"send_collab_back":
			if "optional" in effect and effect["optional"]:
				text += tr("May send Collab back.")
			else:
				text += tr("Send Collab back.")
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
				var text = "[b]%s: %s[/b]" % [get_skill_string(art["art_id"]), art["power"]]
				if "full_english_text" in art:
					text = tr(art["full_english_text"])
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
				data.append({"colors": [], "text": tr("LIMITED")})
			data.append({"colors": [], "text": tr(definition["sub_type"])})
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
				var limit = tr("1/Turn")
				if action["limit"] == "once_per_game":
					limit = tr("1/Game")
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
			"text": "%s" % " ".join(get_tags_strings(definition["tags"]))
		}
		data.append(next_entry)
	return data
