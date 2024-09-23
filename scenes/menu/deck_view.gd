class_name DeckView
extends MarginContainer

signal select_card_types(types)

const PopoutElementScene = preload("res://scenes/game/popout_element.tscn")

@onready var deck_grid = $ScrollContainer/MarginContainer/VBoxContainer/DeckGrid
@onready var oshi_element = $ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/OshiMargin/OshiElement
@onready var cheer_box = $ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/CheerBox
@onready var deck_name_edit = $ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/DeckNameEdit
@onready var card_total : Label = $ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CardLabels/CardCount

var _current_deck = {}

func initialize(deck):
	_current_deck = deck
	# Create the oshi card
	# Initialize the Cheer
	# Create all the cards and set counts
	remove_all_children(deck_grid)

	# Deck name
	deck_name_edit.text = deck["deck_name"]

	# Setup Oshi
	oshi_element.set_card_controls(false, null)
	var oshi_card = CardDatabase.test_create_card("id_" + str(deck["oshi"]), deck["oshi"])
	oshi_element.add_card(oshi_card)
	oshi_card.initialize_graphics()
	oshi_element.position_card()

	# Setup Cheer Deck
	cheer_box.create_groups(deck["cheer_deck"])

	# Setup Deck
	var num_cards = deck["deck"].size()
	add_card_elements(num_cards)
	var elements  = deck_grid.get_children()
	for i in range(num_cards):
		var element = elements[i]
		var card_id = deck["deck"].keys()[i]
		var card_count = deck["deck"][card_id]
		var card = CardDatabase.test_create_card("id_" + str(card_id), card_id)

		element.add_card(card)
		card.initialize_graphics()
		element.set_number_visible(card_count)
		element.set_card_controls(true, change_card_count)

	reposition_cards()
	update_card_total()

func reposition_cards():
	for element in deck_grid.get_children():
		element.position_card()

func change_card_count(element, amount):
	var current_num = element.get_number()
	var definition_id = element.get_definition_id()
	var card = CardDatabase.get_card(definition_id)
	var max_allowed = Enums.MAX_CARD_COPIES
	if "special_deck_limit" in card:
		max_allowed = card["special_deck_limit"]
	current_num += amount
	if current_num == 0:
		# Remove the card from the deck
		_current_deck["deck"].erase(definition_id)
		element.visible = false
		deck_grid.remove_child(element)
		element.queue_free()
		reposition_cards()
	else:
		if current_num > max_allowed:
			current_num = max_allowed
		_current_deck["deck"][definition_id] = current_num
		element.set_number_visible(current_num)
	update_card_total()

func update_card_total():
	var total = 0
	for child in deck_grid.get_children():
		total += child.get_number()
	card_total.text = str(total)
	if total != Enums.DECK_SIZE:
		card_total.modulate = Color(1, 0, 0)
	else:
		card_total.modulate = Color(1, 1, 1)

func remove_all_children(element):
	var children = element.get_children()
	for child in children:
		element.remove_child(child)
		child.queue_free()

func add_card_elements(count):
	for i in range(count):
		var popout_element = PopoutElementScene.instantiate()
		deck_grid.add_child(popout_element)
		popout_element.set_card_controls(false, null)

func _on_cheer_box_cheer_changed(cheer_id : String, _color: String, new_count) -> void:
	if new_count == 0:
		# Remove the cheer from the deck
		_current_deck["cheer_deck"].erase(cheer_id)
	else:
		# Update the count
		_current_deck["cheer_deck"][cheer_id] = new_count


func _on_deck_name_edit_text_changed(new_text: String) -> void:
	if new_text:
		name = new_text

func _on_oshi_button_pressed() -> void:
	select_card_types.emit(["oshi"])
