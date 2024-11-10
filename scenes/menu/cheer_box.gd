class_name CheerBox
extends VBoxContainer

signal cheer_changed(cheer_id, color, new_count)

const CheerGroupScene = preload("res://scenes/menu/cheer_group.tscn")

@onready var cheer_grid = $CheerGrid
@onready var cheer_count = $HBoxContainer/CheerCount

var all_cheer_ids = [
	"hY01-001",
	"hY02-001",
	"hY03-001",
	"hY04-001",
	"hY05-001",
]

func create_groups(cheer_deck):
	while cheer_grid.get_child_count():
		var child = cheer_grid.get_child(0)
		child.visible = false
		cheer_grid.remove_child(child)
		child.queue_free()
	for cheer_id in all_cheer_ids:
		var count = 0
		if cheer_id in cheer_deck:
			count = cheer_deck[cheer_id]
		var new_group = CheerGroupScene.instantiate()
		cheer_grid.add_child(new_group)
		var card = CardDatabase.get_card(cheer_id)
		var color = card["colors"][0]
		new_group.set_cheer_info(cheer_id, color, count)
		new_group.value_changed.connect(cheer_value_changed)
	_update_cheer_total()

func _update_cheer_total():
	var total = 0
	for child in cheer_grid.get_children():
		total += child.get_count()
	cheer_count.text = str(total)
	if total != Enums.CHEER_SIZE:
		cheer_count.modulate = Color(1, 0, 0)
	else:
		cheer_count.modulate = Color(1, 1, 1)

func cheer_value_changed(cheer_id, color, new_count):
	_update_cheer_total()
	cheer_changed.emit(cheer_id, color, new_count)
