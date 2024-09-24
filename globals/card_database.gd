extends Node

var card_data = []
var card_definitions_path = "res://data/card_definitions.json"
var test_decks_path = "res://data/test_decks.json"

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
