class_name CardPopout
extends CenterContainer

@onready var instructions_label : Label = $PanelContainer/VBoxContainer/TitleBar/HBoxContainer/InstructionsLabel
@onready var card_grid : GridContainer = $PanelContainer/VBoxContainer/CardPanel/ScrollContainer/MarginContainer/CardGrid
@onready var card_parent : Node2D = $CardParent
@onready var action_button1 : Button = $PanelContainer/VBoxContainer/TitleBar/HBoxContainer/ActionButton1
@onready var action_button2 : Button = $PanelContainer/VBoxContainer/TitleBar/HBoxContainer/ActionButton2
@onready var action_buttons = [action_button1, action_button2]



const PopoutElementScene = preload("res://scenes/game/popout_element.tscn")

func remove_all_children(element):
	var children = element.get_children()
	for child in children:
		child.free()

func add_card_elements(count):
	for i in range(count):
		var popout_element = PopoutElementScene.instance()
		popout_element.set_card_controls(false)
		card_grid.add_child(popout_element)

func show_panel(instructions, popout_choice_info, cards, callback : Callable):
	visible = true

	remove_all_children(card_grid)

	var count = len(cards)
	add_card_elements(count)

	if count < 10:
		card_grid.columns = count
	else:
		card_grid.columns = 10

	for card in cards:
		card_parent.add_child(card)

	update_panel(instructions, popout_choice_info)

func update_panel(instructions, popout_choice_info):
	if instructions:
		instructions_label.text = instructions
	var choice_info_count = len(popout_choice_info["strings"])
	for i in range(len(action_buttons)):
		action_buttons[i].visible = i < choice_info_count
		if i < choice_info_count:
			action_buttons[i].text = popout_choice_info["strings"][i]
			action_buttons[i].connect("pressed", popout_choice_info["callback"][i])
			action_buttons[i].disabled = not popout_choice_info["enabled"][i]

func clear_panel():
	visible = false
	remove_all_children(card_parent)
	remove_all_children(card_grid)

func _on_click_outside_button_pressed() -> void:
	visible = false
