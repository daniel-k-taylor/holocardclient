@tool
class_name IconButton
extends MarginContainer

signal pressed

@onready var texture_rect : TextureRect = $Image

@export var texture : Texture2D :
	set(value):
		texture = value
		if texture_rect:
			texture_rect.texture = texture

func _ready():
	texture_rect.texture = texture

func _on_button_pressed() -> void:
	pressed.emit()
