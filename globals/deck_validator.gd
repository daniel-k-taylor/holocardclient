extends Node

func load_deck(data) -> Dictionary:
	var loaded_deck = {
		"deck_name": "",
		"oshi": "",
		"deck": {},
		"cheer_deck": {},
		"error": "",
	}
	var json = JSON.new()
	var error_message = ""
	if json.parse(data[0]) == OK:
		if "cheerDeck" in json.data:
			return load_deck_holodelta(json.data)
		if "deck_name" in json.data and typeof(json.data["deck_name"]) == TYPE_STRING:
			loaded_deck["deck_name"] = json.data["deck_name"]
		else:
			loaded_deck["deck_name"] = "New Deck"
		if "oshi" not in json.data or typeof(json.data["oshi"]) != TYPE_STRING:
			error_message = "Invalid format:\nInvalid oshi"
		elif "deck" not in json.data or typeof(json.data["deck"]) != TYPE_DICTIONARY:
			error_message = "Invalid format:\nInvalid deck"
		elif "cheer_deck" not in json.data or typeof(json.data["cheer_deck"]) != TYPE_DICTIONARY:
			error_message = "Invalid format:\nInvalid cheer deck"
		else:
			for deck_key in json.data["deck"]:
				if typeof(deck_key) != TYPE_STRING:
					error_message = "Invalid format:\nDeck keys not all strings"
				elif typeof(json.data["deck"][deck_key]) != TYPE_FLOAT:
					error_message = "Invalid format:\nDeck counts not numbers"
			if not error_message:
				for cheer_key in json.data["cheer_deck"]:
					if typeof(cheer_key) != TYPE_STRING:
						error_message = "Invalid format:\nCheer Deck keys not all strings"
					elif typeof(json.data["cheer_deck"][cheer_key]) != TYPE_FLOAT:
						error_message = "Invalid format:\nCheer Deck counts not numbers"
			if not error_message:
				var new_deck = {
					"oshi": json.data["oshi"],
					"deck": {},
					"cheer_deck": {},
				}
				for deck_key in json.data["deck"]:
					new_deck["deck"][deck_key] = int(json.data["deck"][deck_key])
				for cheer_key in json.data["cheer_deck"]:
					new_deck["cheer_deck"][cheer_key] = int(json.data["cheer_deck"][cheer_key])
				loaded_deck = new_deck
	else:
		error_message = "JSON Parse Error: " + json.get_error_message()
	loaded_deck["error"] = error_message
	return loaded_deck

func load_deck_holodelta(data):
	var loaded_deck = {
		"deck_name": "",
		"oshi": "",
		"deck": {},
		"cheer_deck": {},
		"error": "",
	}
	var error_message = ""
	if "deckName" in data and typeof(data["deckName"]) == TYPE_STRING:
		loaded_deck["deck_name"] = data["deckName"]
	else:
		loaded_deck["deck_name"] = "New Deck"
	if "oshi" not in data or typeof(data["oshi"]) != TYPE_ARRAY:
		error_message = "Invalid format:\nInvalid oshi"
	elif "deck" not in data or typeof(data["deck"]) != TYPE_ARRAY:
		error_message = "Invalid format:\nInvalid deck"
	elif "cheerDeck" not in data or typeof(data["cheerDeck"]) != TYPE_ARRAY:
		error_message = "Invalid format:\nInvalid cheer deck"
	else:
		var oshi_info = data["oshi"]
		if typeof(oshi_info) != TYPE_ARRAY or len(oshi_info) != 2:
			error_message = "Invalid format:\nOshi not a list of 2"
		elif typeof(oshi_info[0]) != TYPE_STRING:
			error_message = "Invalid format:\nOshi card ID not string"
		elif typeof(oshi_info[1]) != TYPE_FLOAT:
			error_message = "Invalid format:\nOshi card alt are not number"

		if not error_message:
			for deck_entry in data["deck"]:
				if typeof(deck_entry) != TYPE_ARRAY or len(deck_entry) != 3:
					error_message = "Invalid format:\nDeck entries not lists of 3"
				elif typeof(deck_entry[0]) != TYPE_STRING:
					error_message = "Invalid format:\nDeck entry card IDs not strings"
				elif typeof(deck_entry[1]) != TYPE_FLOAT:
					error_message = "Invalid format:\nDeck entry card counts not numbers"
				elif typeof(deck_entry[2]) != TYPE_FLOAT:
					error_message = "Invalid format:\nDeck entry alt art not numbers"

		if not error_message:
			for cheer_entry in data["cheerDeck"]:
				if typeof(cheer_entry) != TYPE_ARRAY or len(cheer_entry) != 3:
					error_message = "Invalid format:\nCheer entries not lists of 3"
				elif typeof(cheer_entry[0]) != TYPE_STRING:
					error_message = "Invalid format:\nCheer entry card IDs not strings"
				elif typeof(cheer_entry[1]) != TYPE_FLOAT:
					error_message = "Invalid format:\nCheer entry card counts not numbers"
				elif typeof(cheer_entry[2]) != TYPE_FLOAT:
					error_message = "Invalid format:\nCheer entry alt art not numbers"

		if not error_message:
			loaded_deck["oshi"] = oshi_info[0]
			for deck_entry in data["deck"]:
				if deck_entry[0] in loaded_deck["deck"]:
					loaded_deck["deck"][deck_entry[0]] += int(deck_entry[1])
				else:
					loaded_deck["deck"][deck_entry[0]] = int(deck_entry[1])
			for cheer_entry in data["cheerDeck"]:
				if cheer_entry[0] in loaded_deck["cheer_deck"]:
					loaded_deck["cheer_deck"][cheer_entry[0]] += int(cheer_entry[1])
				else:
					loaded_deck["cheer_deck"][cheer_entry[0]] = int(cheer_entry[1])

	loaded_deck["error"] = error_message
	return loaded_deck

func export_deck_holodelta(deck):
	# HoloDelta format is:
	#{
	#  "deckName": "Deck Name",
	#  "oshi": ["oshi_card_id", alt_art],
	#  "deck": [["card_id", count, alt_art], ...],
	#  "cheerDeck": [["card_id", count, alt_art], ...]
	#}
	#
	# Simple deck format passed in is:
	# {
	# 	"deck_name": "",
	# 	"oshi": "",
	# 	"deck": {},
	# 	"cheer_deck": {},
	# 	"error": "",
	# }
	var holo_delta_deck = {
		"deckName": deck["deck_name"],
		"oshi": [deck["oshi"], 0],
		"deck": [],
		"cheerDeck": [],
	}
	for card_id in deck["deck"]:
		holo_delta_deck["deck"].append([card_id, deck["deck"][card_id], 0])
	for card_id in deck["cheer_deck"]:
		holo_delta_deck["cheerDeck"].append([card_id, deck["cheer_deck"][card_id], 0])
	return holo_delta_deck
