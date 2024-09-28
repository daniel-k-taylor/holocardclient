extends Node

var card_data = []
var card_definitions_path = "res://data/card_definitions.json"
var test_decks_path = "res://data/test_decks.json"
var sample_decks_path = "res://data/sample_decks.json"

const CardBaseScene = preload("res://scenes/game/card_base.tscn")

func _ready():
	card_data = load_json_file(card_definitions_path)

func load_json_file(file_path : String):
	if FileAccess.file_exists(file_path):
		var data = FileAccess.open(file_path, FileAccess.READ)
		var json = JSON.parse_string(data.get_as_text())
		return json
	else:
		print("Card definitions file doesn't exist")

func get_test_decks():
	if FileAccess.file_exists(test_decks_path):
		var data = FileAccess.open(test_decks_path, FileAccess.READ)
		var json = JSON.parse_string(data.get_as_text())
		return json
	else:
		print("Test decks file doesn't exist")

func get_sample_decks():
	if FileAccess.file_exists(sample_decks_path):
		var data = FileAccess.open(sample_decks_path, FileAccess.READ)
		var json = JSON.parse_string(data.get_as_text())
		return json
	else:
		print("Sample decks file doesn't exist")

func get_supported_cards():
	var card_ids = []
	for card in card_data:
		card_ids.append(card["card_id"])
	return card_ids

func get_cards_of_types(types):
	var card_ids = []
	for card in card_data:
		if card["card_type"] in types:
			card_ids.append(card["card_id"])
	return card_ids

func get_card(definition_id, allow_missing = false) -> Dictionary:
	for card in card_data:
		if card['card_id'] == definition_id:
			return card
	if not allow_missing:
		assert(false, "Missing card definition: " + definition_id)
	return {}

func test_create_card(card_id : String, definition_id : String) -> CardBase:
	var definition = CardDatabase.get_card(definition_id)
	var card_type = definition["card_type"]
	var new_card : CardBase = CardBaseScene.instantiate()
	new_card.create_card(definition, definition_id, card_id, card_type)
	return new_card


func get_compare_value(definition):
	var compare_value = 0
	var card_type = definition["card_type"]
	var card_name = ""
	match card_type:
		"holomem_spot":
			compare_value = 10000
			card_name = definition["card_names"][0]
		"holomem_debut":
			compare_value = 20000
			card_name = definition["card_names"][0]
		"holomem_bloom":
			compare_value = 30000
			card_name = definition["card_names"][0]
		"support":
			compare_value = 40000
			card_name = definition["card_names"][0]
	if "bloom_level" in definition:
		compare_value += definition["bloom_level"] * 1000
	if "limited" not in definition or not definition["limited"]:
		compare_value += 1000

	var compare_str = "%s_%s_%s" % [compare_value, card_name, definition]

	return compare_str
