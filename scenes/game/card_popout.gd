class_name CardPopout
extends CenterContainer

@onready var instructions_label : RichTextLabel = $PanelContainer/VBoxContainer/TitleBar/VBoxContainer/HBoxContainer/InstructionsLabel
@onready var card_grid : GridContainer = $PanelContainer/VBoxContainer/CardPanel/ScrollContainer/MarginContainer/CardGrid
@onready var action_button1 : MultiChoiceButton = $PanelContainer/VBoxContainer/TitleBar/VBoxContainer/HBoxContainer2/ActionButton1
@onready var action_button2 : MultiChoiceButton = $PanelContainer/VBoxContainer/TitleBar/VBoxContainer/HBoxContainer2/ActionButton2
@onready var action_buttons : Array[MultiChoiceButton] = [action_button1, action_button2]



const PopoutElementScene = preload("res://scenes/game/popout_element.tscn")
var callbacks = []

func _ready():
	for button in action_buttons:
		button.connect("button_pressed", _action_button_pressed)
		
	if get_parent() == get_tree().root:
		var test_cards = []
		for i in range(33):
			test_cards.append(CardDatabase.test_create_card("id_" + str(i), "hSD01-001"))
		
		show_panel(
			"[b]Test[/b] here are some instructions",
			{
				"strings": [Strings.get_string(Strings.STRING_OK), Strings.get_string(Strings.STRING_CANCEL)],
				"callback": [null, null],
				"enabled": [true, true]
			},
			test_cards,
		)

func remove_all_children(element):
	var children = element.get_children()
	for child in children:
		child.free()

func add_card_elements(count):
	for i in range(count):
		var popout_element = PopoutElementScene.instantiate()
		card_grid.add_child(popout_element)
		popout_element.set_card_controls(false)

func show_panel(instructions, popout_choice_info, cards):
	visible = true

	remove_all_children(card_grid)

	var count = len(cards)
	add_card_elements(count)

	if count < 10:
		card_grid.columns = count
	else:
		card_grid.columns = 10

	var popout_elements  = card_grid.get_children()
	for i in range(len(cards)):
		var card = cards[i]
		var element: PopoutElement = popout_elements[i]
		element.add_card(card)
		card.initialize_graphics()
		card.set_selectable(true)

	init_panel(instructions, popout_choice_info)

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

func _on_click_outside_button_pressed() -> void:
	visible = false

func _action_button_pressed(button_value):
	callbacks[button_value].call()
