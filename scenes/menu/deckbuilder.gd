class_name DeckBuilder
extends Node2D

const DeckCardSlotScene = preload("res://scenes/menu/deck_card_slot.tscn")

@onready var deck_name_label : LineEdit = $DeckList/DeckName
@onready var oshi_slot : DeckCardSlot = $DeckList/OshiSlot
@onready var cheer_box : CheerBox = $DeckList/CheerBox
@onready var deck_card_count : Label = $DeckList/CardLabels/CardCount
@onready var deck_card_slots : VBoxContainer = $DeckList/ScrollContainer/DeckCards
@onready var deck_option_button : OptionButton = $HBoxContainer/DecksOptionButton

@onready var save_file_dialog = $SaveFileDialog
@onready var open_file_dialog = $OpenFileDialog
@onready var modal_dialog = $ModalDialog

var _current_deck = {}
var _current_index = -1
var _all_decks = []

### Web-specific variables
var window
var file_load_callback
###

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent() == get_tree().root:
		show_deck_builder()

	if OS.has_feature("web"):
		#setupFileLoad defined in the HTML5 export header
		#calls load_deck when file gets user-selected by window.input.click()
		window = JavaScriptBridge.get_interface("window")
		file_load_callback = JavaScriptBridge.create_callback(load_deck_from_file)
		window.setupFileLoad(file_load_callback)

func show_deck_builder():
	visible = true
	load_decks()

func load_decks():
	var decks = GlobalSettings.get_user_setting(GlobalSettings.SavedDecks)
	if len(decks) == 0:
		# No saved decks, load up the starter deck.
		var deck = CardDatabase.get_test_decks()[0]
		add_deck_to_selector(deck, true)

func add_deck_to_selector(deck, make_selected = false):
	if "deck_name" not in deck:
		deck["deck_name"] = "New Deck"
	_all_decks.append(deck)
	var index = len(_all_decks) - 1
	deck_option_button.add_item(deck["deck_name"], index)
	if make_selected:
		deck_option_button.selected = index
		populate_deck_list(index)

func populate_deck_list(index):
	_current_index = index
	_current_deck = _all_decks[index]
	deck_name_label.text = _current_deck["deck_name"]

	# Oshi
	var oshi_card = CardDatabase.get_card(_current_deck["oshi"], true)
	if not oshi_card:
		_current_deck["oshi"] = "hSD01-001"
		oshi_card = CardDatabase.get_card(_current_deck["oshi"])
	oshi_slot.set_details(oshi_card, 1)

	# Cheer
	cheer_box.create_groups(_current_deck["cheer_deck"])

	# Deck
	while deck_card_slots.get_child_count():
		var child = deck_card_slots.get_child(0)
		child.visible = false
		child.queue_free()
		deck_card_slots.remove_child(child)
	var all_card_ids = _current_deck["deck"].keys()
	for card_id in all_card_ids:
		var card = CardDatabase.get_card(card_id, true)
		if card:
			var count = _current_deck["deck"][card_id]
			var new_slot = DeckCardSlotScene.instantiate()
			deck_card_slots.add_child(new_slot)
			new_slot.set_details(card, count)
			new_slot.value_changed.connect(change_card_count)
		else:
			_current_deck["deck"].erase(card_id)

	update_card_total()


func change_card_count(slot : DeckCardSlot, card_id, amount):
	var definition_id = card_id
	var card = CardDatabase.get_card(definition_id)
	var max_allowed = Enums.MAX_CARD_COPIES
	if "special_deck_limit" in card:
		max_allowed = card["special_deck_limit"]
	var amount_in_deck = _current_deck["deck"][card_id]
	var new_amount = amount_in_deck + amount
	if new_amount == 0:
		# Remove the card from the deck
		_current_deck["deck"].erase(definition_id)
		slot.visible = false
		deck_card_slots.remove_child(slot)
		slot.queue_free()
	else:
		if new_amount > max_allowed:
			new_amount = max_allowed
		_current_deck["deck"][definition_id] = new_amount
		slot.update_count(new_amount)
	update_card_total()

func update_card_total():
	var total = 0
	for card_id in _current_deck["deck"]:
		total += _current_deck["deck"][card_id]
	deck_card_count.text = str(total)
	if total != Enums.DECK_SIZE:
		deck_card_count.modulate = Color(1, 0, 0)
	else:
		deck_card_count.modulate = Color(1, 1, 1)

func _on_cheer_box_cheer_changed(cheer_id : String, _color: String, new_count) -> void:
	if new_count == 0:
		# Remove the cheer from the deck
		_current_deck["cheer_deck"].erase(cheer_id)
	else:
		# Update the count
		_current_deck["cheer_deck"][cheer_id] = new_count


func back_to_main_menu():
	visible = false

func _on_new_deck_button_pressed() -> void:
	var deck_contents = {
		"deck_name": "New Deck",
		"oshi": "hSD01-001",
		"deck": {},
		"cheer_deck": {},
	}
	add_deck_to_selector(deck_contents, true)

func _on_delete_deck_button_pressed() -> void:
	deck_option_button.remove_item(_current_index)
	_all_decks.remove_at(_current_index)
	var new_index = min(_current_index, len(_all_decks) - 1)
	if new_index == -1:
		var deck = CardDatabase.get_test_decks()[0]
		add_deck_to_selector(deck, true)
	else:
		deck_option_button.selected = new_index
		deck_option_button.text = _all_decks[new_index]["deck_name"]
		populate_deck_list(new_index)

func _on_load_deck_button_pressed() -> void:
	if OS.has_feature("web"):
		window.input.click()
	else:
		open_file_dialog.visible = true

func _on_save_file_dialog_file_selected(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	var content = JSON.stringify(_current_deck)
	file.store_string(content)

func _on_open_file_dialog_file_selected(path: String) -> void:
	load_deck_from_file([FileAccess.get_file_as_string(path)])

func load_deck_from_file(data):
	var new_deck = DeckValidator.load_deck(data)
	if new_deck.get("error", ""):
		modal_dialog.set_text_fields(new_deck["error"], "OK", "")
	else:
		add_deck_to_selector(new_deck, true)

func _on_save_deck_button_pressed() -> void:
	if OS.has_feature("web"):
		window = JavaScriptBridge.get_interface("window")
		var file_name = "%s.json" % _current_deck["deck_name"]
		var file_content = JSON.stringify(_current_deck)
		window.saveTextToFile(file_name, file_content)
	else:
		save_file_dialog.visible = true


func _on_decks_option_button_item_selected(index: int) -> void:
	populate_deck_list(index)

func _on_deck_name_text_changed(new_text: String) -> void:
	_current_deck["deck_name"] = new_text
	deck_option_button.set_item_text(_current_index, new_text)
	deck_option_button.text = new_text
