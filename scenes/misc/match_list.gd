class_name MatchList
extends CenterContainer

signal observe_match(match_index)

const MatchRowScene = preload("res://scenes/misc/match_row.tscn")

@onready var match_box : VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/MatchBox

func update_match_list(match_list) -> void:
	while match_box.get_children():
		var child = match_box.get_child(0)
		child.queue_free()
		match_box.remove_child(child)

	var index = 0
	for info in match_list:
		var new_row : MatchRow = MatchRowScene.instantiate()
		match_box.add_child(new_row)
		var saved_index = index
		new_row.populate(info["player1"], info["player1_oshi"], info["player2"], info["player2_oshi"], info["room_name"], index)
		new_row.observe_pressed.connect(func():
			visible = false
			observe_match.emit(saved_index)
		)
		index += 1

func _on_fullscreen_close_pressed() -> void:
	visible = false
