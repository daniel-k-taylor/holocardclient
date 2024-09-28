class_name MatchRow
extends PanelContainer

signal observe_pressed

@onready var p1label = $HBoxContainer/Player1
@onready var p2label = $HBoxContainer/Player2
@onready var roomlabel = $HBoxContainer/RoomName

func populate(p1, p2, room, row_index):
	p1label.text = p1
	p2label.text = p2
	roomlabel.text = room
	$LighterBackground.visible = row_index % 2 == 0

func _on_observe_button_pressed() -> void:
	observe_pressed.emit()
