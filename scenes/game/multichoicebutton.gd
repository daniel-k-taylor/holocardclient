@tool
class_name MultiChoiceButton
extends MarginContainer

signal button_pressed(value)

@onready var button_label = $MarginContainer/Label
@onready var button : Button = $Button

@export var button_label_text : String :
	set(value):
		button_label_text = value
		if button_label:
			button_label.text = button_label_text


const EnabledColor = Color(1.0, 1.0, 1.0)
const DisabledColor = Color(0.43, 0.43, 0.43)

var button_value : int = 0

func _ready():
	button_label.text = button_label_text


func set_value(value, label):
	button_value = value
	button_label_text = label
	visible = true

func _on_button_pressed() -> void:
	button_pressed.emit(button_value)

func set_enabled(is_enabled : bool) -> void:
	button.disabled = not is_enabled
	var color = DisabledColor
	if is_enabled: color = EnabledColor
	button_label.modulate = color
