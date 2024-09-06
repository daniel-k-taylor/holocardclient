class_name PopoutElement
extends PanelContainer

@onready var placeholder = $MarginContainer/VBoxContainer/CardPlaceholder
@onready var controls = $MarginContainer/VBoxContainer/CardControls

func set_card_controls(enabled:bool):
	controls.visible = enabled

func get_placeholder_global_position() -> Vector2:
	return placeholder.global_position
