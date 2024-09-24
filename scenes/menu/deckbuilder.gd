class_name DeckBuilder
extends Node2D

signal exit_deck_builder

const DeckCardSlotScene = preload("res://scenes/menu/deck_card_slot.tscn")
const CardPlaceholderScene = preload("res://scenes/menu/card_placholder.tscn")

@onready var deck_name_label : LineEdit = $DeckList/DeckName
@onready var oshi_slot : DeckCardSlot = $DeckList/OshiSlot
@onready var cheer_box : CheerBox = $DeckList/CheerBox
@onready var deck_card_count : Label = $DeckList/CardLabels/CardCount
@onready var deck_card_slots : VBoxContainer = $DeckList/ScrollContainer/DeckCards
@onready var deck_option_button : OptionButton = $HBoxContainer/DecksOptionButton
@onready var card_grid : GridContainer = $PanelContainer/MarginContainer/ScrollContainer/Cards/CardGrid

@onready var save_file_dialog = $SaveFileDialog
@onready var open_file_dialog = $OpenFileDialog
@onready var modal_dialog = $ModalDialog

@onready var new_deck_button = $HBoxContainer/GridContainer/NewDeckButton
@onready var load_deck_button = $HBoxContainer/GridContainer/LoadDeckButton
@onready var big_card = $BigCard

var _current_deck = {}
var _current_index = -1
var _all_decks = []

const MaxDecksAllowed = 10

### Web-specific variables
var window
var file_load_callback
###

var all_cards = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent() == get_tree().root:
		load_decks()
		show_deck_builder(0)

	if OS.has_feature("web"):
		#setupFileLoad defined in the HTML5 export header
		#calls load_deck when file gets user-selected by window.input.click()
		window = JavaScriptBridge.get_interface("window")
		file_load_callback = JavaScriptBridge.create_callback(load_deck_from_file)
		window.setupFileLoad(file_load_callback)

	oshi_slot.hover.connect(_on_hover_slot)

func show_deck_builder(selected_index):
	visible = true
	populate_deck_list(selected_index)
	load_card_list()

func load_card_list():
	for card_id in CardDatabase.get_supported_cards():
		var definition = CardDatabase.get_card(card_id)
		if definition["card_type"] == "cheer":
			continue
		var new_card : CardBase = CardDatabase.test_create_card(card_id, card_id)
		all_cards.append(new_card)
		var new_placeholder = CardPlaceholderScene.instantiate()
		new_placeholder.add_child(new_card)
		new_card.scale = Vector2(CardBase.ReferenceCardScale, CardBase.ReferenceCardScale)
		var desired_pos = CardBase.ReferenceCardScale * (CardBase.DefaultCardSize / 2)
		new_card.begin_move_to(desired_pos, true)

		new_card.set_selectable(true)
		new_card.clicked_card.connect(_on_clicked_card)
		new_card.hover_card.connect(_on_hover_card)

		card_grid.call_deferred("add_child", new_placeholder)

func set_deck_index(index):
	_current_index = index
	save_decks_to_settings()

func load_decks():
	var decks = GlobalSettings.get_user_setting(GlobalSettings.SavedDecks)
	var selected_index = GlobalSettings.get_user_setting(GlobalSettings.SelectedDeckIndex)
	if len(decks) == 0:
		# No saved decks, load up the starter deck.
		var deck = CardDatabase.get_test_decks()[0]
		add_deck_to_selector(deck, true)
	else:
		_all_decks = decks
		deck_option_button.clear()
		for i in range(len(decks)):
			var deck = _all_decks[i]
			deck_option_button.add_item(deck["deck_name"], i)
		if selected_index >= len(_all_decks):
			selected_index = 0
		deck_option_button.selected = selected_index
		deck_option_button.text = _all_decks[selected_index]["deck_name"]
		populate_deck_list(selected_index)

func get_decks():
	return _all_decks

func get_current_deck_index():
	return _current_index

func add_deck_to_selector(deck, make_selected = false):
	if "deck_name" not in deck:
		deck["deck_name"] = "New Deck"
	_all_decks.append(deck)
	var index = len(_all_decks) - 1
	deck_option_button.add_item(deck["deck_name"], index)
	if make_selected:
		deck_option_button.selected = index
		populate_deck_list(index)
	update_buttons()
	save_decks_to_settings()

func update_buttons():
	var reached_deck_max = len(_all_decks) >= MaxDecksAllowed
	new_deck_button.disabled = reached_deck_max
	load_deck_button.disabled = reached_deck_max

func populate_deck_list(index):
	_current_index = index
	_current_deck = _all_decks[index]
	deck_name_label.text = _current_deck["deck_name"]
	deck_option_button.text = _current_deck["deck_name"]
	deck_option_button.selected = index

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
	all_card_ids = sort_cards(all_card_ids)
	for card_id in all_card_ids:
		var card = CardDatabase.get_card(card_id, true)
		if card:
			var count = _current_deck["deck"][card_id]
			var new_slot = DeckCardSlotScene.instantiate()
			deck_card_slots.add_child(new_slot)
			new_slot.set_details(card, count)
			new_slot.value_changed.connect(change_card_count)
			new_slot.hover.connect(_on_hover_slot)
		else:
			_current_deck["deck"].erase(card_id)

	update_card_total()

func sort_cards(card_ids):
	var definitions = []
	for card_id in card_ids:
		definitions.append(CardDatabase.get_card(card_id))

	definitions.sort_custom(
		func(a, b):
			return CardDatabase.get_compare_value(a) < CardDatabase.get_compare_value(b)
	)
	card_ids = []
	for definition in definitions:
		card_ids.append(definition["card_id"])
	return card_ids

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
	save_decks_to_settings()

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
	save_decks_to_settings()

func save_decks_to_settings():
	GlobalSettings.save_user_setting(GlobalSettings.SavedDecks, _all_decks)
	GlobalSettings.save_user_setting(GlobalSettings.SelectedDeckIndex, _current_index)

func back_to_main_menu():
	visible = false
	exit_deck_builder.emit()

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
	update_buttons()
	save_decks_to_settings()

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
	save_decks_to_settings()

func _on_clicked_card(card_id, card : CardBase):
	var definition = card._definition
	if definition["card_type"] == "oshi":
		_current_deck["oshi"] = card_id
	else:
		# Check if this card exists in the deck or not.
		if card_id in _current_deck["deck"]:
			_current_deck["deck"][card_id] += 1
			var max_allowed = Enums.MAX_CARD_COPIES
			if "special_deck_limit" in card:
				max_allowed = card["special_deck_limit"]
			if _current_deck["deck"][card_id] > max_allowed:
				_current_deck["deck"][card_id] = max_allowed
				return
		else:
			_current_deck["deck"][card_id] = 1
	save_decks_to_settings()
	populate_deck_list(_current_index)

func _on_hover_slot(card_id, is_hover):
	big_card.visible = is_hover
	if is_hover:
		for card in all_cards:
			if card._definition_id == card_id:
				big_card.copy_graphics(card)
				break

func _on_hover_card(_card_id, card, is_hover):
	big_card.visible = is_hover
	if is_hover:
		big_card.copy_graphics(card)
