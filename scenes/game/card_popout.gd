class_name CardPopout
extends CenterContainer

@onready var instructions_label : RichTextLabel = $PanelContainer/VBoxContainer/TitleBar/VBoxContainer/HBoxContainer/InstructionsLabel
@onready var card_grid : GridContainer = $PanelContainer/VBoxContainer/CardPanel/ScrollContainer/MarginContainer/CardGrid
@onready var action_button1 : MultiChoiceButton = $PanelContainer/VBoxContainer/TitleBar/VBoxContainer/HBoxContainer2/ActionButton1
@onready var action_button2 : MultiChoiceButton = $PanelContainer/VBoxContainer/TitleBar/VBoxContainer/HBoxContainer2/ActionButton2
@onready var action_buttons : Array[MultiChoiceButton] = [action_button1, action_button2]
@onready var show_all_cards_toggle : CheckButton = $PanelContainer/VBoxContainer/TitleBar/VBoxContainer/CheckboxContainer/ShowAllCardsToggleButton

const MaxColumns = 6

const PopoutElementScene = preload("res://scenes/game/popout_element.tscn")
var callbacks = []

func _ready():
	for button in action_buttons:
		button.connect("button_pressed", _action_button_pressed)

	if get_parent() == get_tree().root:
		var test_cards = []
		var selectable_ids = []
		for i in range(33):
			var card_id = "hSD01-003"
			if i % 2 == 0:
				card_id = "hSD01-004"
			test_cards.append(CardDatabase.test_create_card("id_" + str(i), card_id))
			if i % 2 == 0:
				selectable_ids.append(test_cards[i]._card_id)
		

		show_panel(
			"[b]Test[/b] here are some instructions",
			{
				"strings": [Strings.get_string(Strings.STRING_OK), Strings.get_string(Strings.STRING_CANCEL)],
				"callback": [null, null],
				"enabled": [true, true],
				"order_cards_mode": false,
			},
			test_cards, selectable_ids
		)

func remove_all_children(element):
	var children = element.get_children()
	for child in children:
		element.remove_child(child)
		child.queue_free()

func add_card_elements(count):
	for i in range(count):
		var popout_element = PopoutElementScene.instantiate()
		card_grid.add_child(popout_element)
		popout_element.set_card_controls(false, null)

func show_panel(instructions, popout_choice_info, cards, chooseable_card_ids : Array):
	visible = true

	remove_all_children(card_grid)

	var count = len(cards)
	add_card_elements(count)
	
	var toggle_show_cards_mode = len(cards) != len(chooseable_card_ids)
	if popout_choice_info.get("ignore_chooseable_checkbox", false):
		toggle_show_cards_mode = false
	show_all_cards_toggle.visible = toggle_show_cards_mode
	show_all_cards_toggle.button_pressed = not toggle_show_cards_mode

	if count < MaxColumns:
		card_grid.columns = max(1, count)
	else:
		card_grid.columns = MaxColumns

	var order_cards_mode = popout_choice_info["order_cards_mode"]

	var popout_elements  = card_grid.get_children()
	for i in range(len(cards)):
		var card = cards[i]
		var element: PopoutElement = popout_elements[i]
		element.add_card(card)
		card.initialize_graphics()
		if order_cards_mode:
			element.set_card_controls(true, _reorder_card_element)
			if i == 0:
				element.set_top_visible(true)
		else:
			if card._card_id in chooseable_card_ids:
				card.set_selectable(true)
			else:
				card.set_selectable(false)

	init_panel(instructions, popout_choice_info)
	for element in popout_elements:
		element.position_card()
		
	_show_all_cards(not toggle_show_cards_mode)

func _reorder_card_element(element, direction):
	# Get the index of the element in the grid.
	card_grid.get_child(0).set_top_visible(false)
	var index = element.get_index()
	var max_index = card_grid.get_child_count() - 1
	var new_index = index + direction
	if index == 0 and direction == -1:
		new_index = max_index
	elif index == max_index and direction == 1:
		new_index = 0
	card_grid.move_child(element, new_index)
	card_grid.get_child(0).set_top_visible(true)

func update_panel_states(instructions, enabled_states):
	var update_count = len(enabled_states)
	if instructions:
		instructions_label.text = instructions
	for i in range(len(action_buttons)):
		if i < update_count:
			action_buttons[i].set_enabled(enabled_states[i])

func init_panel(instructions, popout_choice_info):
	instructions_label.text = instructions
	callbacks = popout_choice_info["callback"]
	var choice_info_count = len(popout_choice_info["strings"])
	for i in range(len(action_buttons)):
		action_buttons[i].visible = i < choice_info_count
		if i < choice_info_count:
			action_buttons[i].set_value(i, popout_choice_info["strings"][i])
			action_buttons[i].set_enabled(popout_choice_info["enabled"][i])

func clear_panel():
	visible = false
	remove_all_children(card_grid)

func _show_all_cards(show_all : bool):
	for popout_element in card_grid.get_children():
		popout_element.visible = show_all or popout_element.is_selectable()

func get_ordered_card_ids():
	var card_ids = []
	var popout_elements = card_grid.get_children()
	for element in popout_elements:
		card_ids.append(element.get_card_id())
	return card_ids

func minimize():
	visible = false

func _on_click_outside_button_pressed() -> void:
	minimize()

func _action_button_pressed(button_value):
	callbacks[button_value].call()

func _on_minimize_button_pressed() -> void:
	minimize()

func _on_show_all_cards_toggle_button_toggled(toggled_on: bool) -> void:
	_show_all_cards(toggled_on)
