class_name DeckBuilder
extends Node2D

const DeckViewScene = preload("res://scenes/menu/deck_view.tscn")

@onready var tab_container : TabContainer = $TabContainer
@onready var card_popout : CardPopout = $CardPopout

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent() == get_tree().root:
		show_deck_builder()


func show_deck_builder():
	visible = true
	load_decks()

func load_decks():
	var decks = GlobalSettings.get_user_setting(GlobalSettings.SavedDecks)
	if len(decks) == 0:
		# No saved decks, load up the starter deck.
		var deck = CardDatabase.get_test_decks()[0]
		var deck_view = add_new_deck(deck["deck_name"])
		deck_view.initialize(deck)

func add_new_deck(potential_name = "New Deck"):
	var new_deck_view = DeckViewScene.instantiate()
	var duplicate_index = 0
	if not potential_name:
		potential_name = "New Deck"
	var desired_name_base = potential_name
	var new_deck_name = ""
	while not new_deck_name:
		var desired_name = desired_name_base
		var dupe_found = false
		for child in tab_container.get_children():
			if duplicate_index > 0:
				desired_name = "%s %s" % [desired_name_base, duplicate_index]
			if child.name == desired_name:
				duplicate_index += 1
				dupe_found = true
				break
		if not dupe_found:
			new_deck_name = desired_name
	new_deck_view.name = new_deck_name
	new_deck_view.select_card_types.connect(_on_select_card_types)
	tab_container.add_child(new_deck_view)
	return new_deck_view

func back_to_main_menu():
	visible = false


func _on_new_deck_button_pressed() -> void:
	var deck_view = add_new_deck()
	var deck_contents = {
		"deck_name": deck_view.name,
		"oshi": "hSD01-001",
		"deck": {},
		"cheer_deck": {},
	}
	deck_view.initialize(deck_contents)
	tab_container.current_tab = tab_container.get_tab_count() - 1


func _on_delete_deck_button_pressed() -> void:
	pass # Replace with function body.


func _on_load_deck_button_pressed() -> void:
	pass # Replace with function body.

func _on_select_card_types(types):
	card_popout.show_panel("Select a card", {}, [], [])
