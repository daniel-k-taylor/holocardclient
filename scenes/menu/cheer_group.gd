class_name CheerGroup
extends HBoxContainer

signal value_changed(cheer_id, color, new_count)

var _cheer_id = ""
var _color = "any"
var _count = 0

func set_cheer_info(cheer_id, color, count):
	_cheer_id = cheer_id
	_color = color
	_count = count
	$Count.text = str(_count)
	$Icon.texture = load("res://assets/cheer_icons/%s.png" % [color])

func get_count():
	return _count

func _on_minus_pressed() -> void:
	if _count == 0:
		return
	_count -= 1
	$Count.text = str(_count)
	value_changed.emit(_cheer_id, _color, _count)

func _on_plus_pressed() -> void:
	if _count >= 20:
		return
	_count += 1
	$Count.text = str(_count)
	value_changed.emit(_cheer_id, _color, _count)
