extends Node2D


var _card_id
var _definition_id
var _selected_graphic_link

func create_card(definition_id, card_id):
	_definition_id = definition_id
	_card_id = card_id
	_selected_graphic_link = null

func set_selected(is_selected : bool) -> void:
	assert(_selected_graphic_link, "This hack expects this to always be set if a card is on the board.")
	if _selected_graphic_link:
		_selected_graphic_link.set_selected(is_selected)

func set_selectable(is_selectable : bool) -> void:
	assert(_selected_graphic_link, "This hack expects this to always be set if a card is on the board.")
	if _selected_graphic_link:
		_selected_graphic_link.set_selectable(is_selectable)
