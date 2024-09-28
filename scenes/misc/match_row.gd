class_name MatchRow
extends PanelContainer

signal observe_pressed

@onready var p1label = $HBoxContainer/Player1
@onready var p1oshi = $HBoxContainer/Player1Oshi
@onready var p2label = $HBoxContainer/Player2
@onready var p2oshi = $HBoxContainer/Player2Oshi
@onready var roomlabel = $HBoxContainer/RoomName

func populate(p1, p1oshi_name, p2, p2oshi_name, room, row_index):
	p1label.text = p1
	p1oshi.text = p1oshi_name
	p2label.text = p2
	p2oshi.text = p2oshi_name
	roomlabel.text = room
	$LighterBackground.visible = row_index % 2 == 0

func _on_observe_button_pressed() -> void:
	observe_pressed.emit()
