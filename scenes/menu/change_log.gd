extends CenterContainer

@onready var content = $PanelContainer/MarginContainer/VBoxContainer/Content

const change_log_file = "res://data//change_log.txt"


func show_logs() -> void:
	if !content.text:
		content.text = _load_change_log()
	visible = true


func hide_logs() -> void:
	visible = false


func _load_change_log() -> String:
	if not FileAccess.file_exists(change_log_file):
		print("Unable to load settings file.")
		visible = false
		return ""

	var file = FileAccess.open(change_log_file, FileAccess.READ)
	return file.get_as_text()
