class_name DeckView
extends MarginContainer

const PopoutElementScene = preload("res://scenes/game/popout_element.tscn")

@onready var deck_grid = $ScrollContainer/MarginContainer/VBoxContainer/DeckGrid
@onready var oshi_element = $ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/OshiElement

func initialize(deck):
	# Create the oshi card
	# Initialize the Cheer
	# Create all the cards and set counts
	remove_all_children(deck_grid)

	oshi_element.set_card_controls(false, null)
	var oshi_card = CardDatabase.test_create_card("id_" + str(deck["oshi"]), deck["oshi"])
	oshi_element.add_card(oshi_card)
	oshi_card.initialize_graphics()
	oshi_element.position_card()

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

func reposition_cards():
	for element in deck_grid.get_children():
		element.position_card()

func change_card_count(element, amount):
	var current_num = element.get_number()
	current_num += amount
	if current_num == 0:
		# Remove the card from the deck
		element.visible = false
		element.queue_free()
		reposition_cards()
	else:
		element.set_number_visible(current_num)

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
