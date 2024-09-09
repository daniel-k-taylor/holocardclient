class_name ActionMenu
extends PanelContainer

const MultiChoiceButtonScene = preload("res://scenes/game/multichoicebutton.tscn")

@onready var instruction_label : RichTextLabel = $OuterMargin/MainVBox/PanelContainer/InstructionsHBox/InstructionsLabel
@onready var choice_grid : GridContainer = $OuterMargin/MainVBox/ChoiceButtons
@onready var show_menu_button = $OuterMargin/MainVBox/PanelContainer/InstructionsHBox/ShowMenuButton
@onready var hide_menu_button = $OuterMargin/MainVBox/PanelContainer/InstructionsHBox/HideMenuButton

var choice_buttons : Array[MultiChoiceButton] = []
const MAX_BUTTONS = 10
var _callback : Callable

func _ready() -> void:
	# Initialize the choice buttons and hide them.
	for i in range(MAX_BUTTONS):
		var new_button : MultiChoiceButton = MultiChoiceButtonScene.instantiate()
		new_button.visible = false
		new_button.button_pressed.connect(_on_button_pressed)
		choice_buttons.append(new_button)
		choice_grid.add_child(new_button)

func show_choices(instructions : String, choice_info : Dictionary, callback : Callable):
	_callback = callback
	instruction_label.text = instructions
	for i in range(MAX_BUTTONS):
		choice_buttons[i].visible = false

	var choice_strings = choice_info["strings"]
	var choice_enabled = choice_info["enabled"]
	var choice_count = len(choice_strings)
	for i in range(choice_count):
		var button : MultiChoiceButton  = choice_grid.get_child(i)
		button.set_value(i, choice_strings[i])
		button.set_enabled(choice_enabled[i])

	if choice_count <= 3:
		choice_grid.columns = max(1, choice_count)
	elif choice_count == 4:
		choice_grid.columns = 2
	else:
		choice_grid.columns = 3

	visible = true
	reset_size()

func hide_menu():
	visible = false
	

func update_buttons_enabled(enabled_states : Array):
	for i in range(len(enabled_states)):
		var button : MultiChoiceButton  = choice_grid.get_child(i)
		button.set_enabled(enabled_states[i])

func _on_button_pressed(choice_index):
	visible = false
	_callback.call(choice_index)

func _on_hide_menu_button_pressed() -> void:
	show_menu_button.visible = true
	hide_menu_button.visible = false
	choice_grid.visible = false

func _on_show_menu_button_pressed() -> void:
	show_menu_button.visible = false
	hide_menu_button.visible = true
	choice_grid.visible = true
