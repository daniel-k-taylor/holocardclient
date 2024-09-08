class_name CardTextInfo
extends MarginContainer

const IMAGE_WIDTH = 24

@onready var label : RichTextLabel = $Label

func _ready():
	pass

func build_cheer_icon_text(color):
	return "[img=%s]res://assets/cheer_icons/%s.png[/img]" % [IMAGE_WIDTH, color]

func set_text(colors : Array, ability_text):
	var updated_text = ""
	for cheer_color in colors:
		updated_text += build_cheer_icon_text(cheer_color)
	if updated_text:
		updated_text += " "

	updated_text += ability_text
	label.text = updated_text
