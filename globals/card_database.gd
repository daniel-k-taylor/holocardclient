extends Node

var card_data = []
var card_definitions_path = "res://data/card_definitions.json"

func _ready():
	card_data = load_json_file(card_definitions_path)

func load_json_file(file_path : String):
	if FileAccess.file_exists(file_path):
		var data = FileAccess.open(file_path, FileAccess.READ)
		var json = JSON.parse_string(data.get_as_text())
		return json
	else:
		print("Card definitions file doesn't exist")

func get_card(definition_id):
	for card in card_data:
		if card['card_id'] == definition_id:
			return card
	assert(false, "Missing card definition: " + definition_id)
	return null
