class_name CheerIndicator
extends MarginContainer

var color
var count

@onready var cheer_image = $HBox/CheerImage
@onready var cheer_count = $HBox/CheerCount

func set_cheer(set_color: String, amount : int):
	# Load the right cheer image based on the color.
	color = set_color
	count = amount

	var image_texture = load("res://assets/cheer_icons/" + color + ".png")
	cheer_image.texture = image_texture
	cheer_count.text = str(amount)
