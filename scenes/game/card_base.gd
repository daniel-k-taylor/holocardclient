class_name CardBase
extends Node2D


var _card_id
var _definition_id
var _selected_graphic_link : CardEntry

var _cheer : Dictionary = {}
var damage = 0
var _card_type

func create_card(definition_id, card_id, card_type):
	_definition_id = definition_id
	_card_id = card_id
	_selected_graphic_link = null
	_card_type = card_type

func is_holomem_card():
	return _card_type in ["holomem_debut", "holomem_bloom", "holomem_spot"]

func set_selected(is_selected : bool) -> void:
	assert(_selected_graphic_link, "This hack expects this to always be set if a card is on the board.")
	if _selected_graphic_link:
		_selected_graphic_link.set_selected(is_selected)

func set_selectable(is_selectable : bool) -> void:
	assert(_selected_graphic_link, "This hack expects this to always be set if a card is on the board.")
	if _selected_graphic_link:
		_selected_graphic_link.set_selectable(is_selectable)

func attach_cheer(card_id, colors : Array):
	_cheer[card_id] = colors
	_selected_graphic_link.update_stats()

func remove_cheer(card_id):
	_cheer.erase(card_id)
	_selected_graphic_link.update_stats()

func add_damage(amount):
	damage += amount
	_selected_graphic_link.update_stats()

func remove_damage(amount):
	damage -= amount
	_selected_graphic_link.update_stats()
	

func get_cheer_counts():
	var blue = 0
	var green = 0
	var red = 0
	var white = 0
	for cheer_id in self._cheer:
		var colors = _cheer[cheer_id]
		if "blue" in colors:
			blue += 1
		if "green" in colors:
			green += 1
		if "red" in colors:
			red += 1
		if "white" in colors:
			white += 1
	return {
		"blue": blue,
		"green": green,
		"red": red,
		"white": white,
	}
