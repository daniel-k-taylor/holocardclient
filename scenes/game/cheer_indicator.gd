extends HBoxContainer

var color
var count

func set_cheer(set_color: String, amount : int):
	# Load the right cheer image based on the color.
	color = set_color
	count = amount

	var cheer_image = load("res://assets/cheer_icons/" + color + ".png")
	$CheerImage.texture = cheer_image
	$CheerCount.text = str(amount)
