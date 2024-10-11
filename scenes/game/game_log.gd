class_name GameLog
extends CenterContainer

signal save_log_pressed

@onready var label : RichTextLabel = $HBox/PanelContainer/VBoxContainer/PanelContainer/Label

@onready var debug_check = $HBox/PanelContainer/VBoxContainer/HBoxContainer/ShowDebugCheckbox
@onready var big_card = $BigCard

const DEFAULT_PLAYER_COLOR = "#16c2f7"
const DEFAULT_OPPONENT_COLOR = "#ff0000"
const PHASE_COLOR = "#e3ed2e"
const CARD_COLOR = "#d675ff"
const DECISION_COLOR = "#ff7e0d"
const SKILL_COLOR = "#ff0d9a"

enum GameLogLine {
	Debug,
	Detail,
}

var full_log = []

func _ready() -> void:
	big_card.visible = false
	big_card._update_stats()

func replace_tag(text, tag, color):
	text = text.replace("[%s]" % tag, "[color=%s]" % [color])
	text = text.replace("[/%s]" % tag, "[/color]")
	return text

func add_to_log(log_type, text : String):
	if text.begins_with("You"):
		text = text.erase(0, 3)
		text = "[color=%s]You[/color]" % [DEFAULT_PLAYER_COLOR] + text
	elif text.begins_with("Opponent"):
		text = text.erase(0, 8)
		text = "[color=%s]Opponent[/color]" % [DEFAULT_OPPONENT_COLOR] + text

	# If there is a [CARD] tag, get the text between it and [/CARD].
	while text.find("[CARD]") != -1:
		var start = text.find("[CARD]") + 6
		var end = text.find("[/CARD]", start)
		var card_id = text.substr(start, end - start)
		text = text.replace("[CARD]%s[/CARD]" % [card_id], "[url=%s][CARDCOLORTAG]%s[/CARDCOLORTAG][/url]" % [card_id, card_id])

	# Perform the same for [SKILLSOURCE] tag
	while text.find("[SKILLSOURCE]") != -1:
		var start = text.find("[SKILLSOURCE]") + 13
		var end = text.find("[/SKILLSOURCE]", start)
		var content_text = text.substr(start, end - start)
		var content_items = Array(content_text.split("|")) # [source_card_id, stat]
		text = text.replace(
			"[SKILLSOURCE]%s[/SKILLSOURCE]" % content_text,
			"[url=?][SKILL]?[/SKILL][/url]".format(content_items, "?")
		)

	text = replace_tag(text, "CARDCOLORTAG", CARD_COLOR)
	text = replace_tag(text, "PHASE", PHASE_COLOR)
	text = replace_tag(text, "DECISION", DECISION_COLOR)
	text = replace_tag(text, "SKILL", SKILL_COLOR)
	full_log.append({
		"log_type": log_type,
		"text": text,
	})
	if _is_log_type_enabled(log_type):
		label.text += "\n%s" % text

func _on_close_button_pressed() -> void:
	visible = false

func _is_log_type_enabled(log_type):
	match log_type:
		GameLogLine.Debug:
			return debug_check.button_pressed
		_:
			return true

func get_text() -> String:
	return label.text

func _generate_full_text():
	var text = ""
	for logline in full_log:
		if _is_log_type_enabled(logline["log_type"]):
			text += logline["text"] + "\n"
	label.text = text

func _on_show_debug_checkbox_toggled(_toggled_on: bool) -> void:
	_generate_full_text()

func _on_save_log_button_pressed() -> void:
	save_log_pressed.emit()

func _on_label_meta_hover_started(meta: Variant) -> void:
	if meta != "?":
		big_card.visible = true
		big_card._definition_id = meta
		big_card._card_id = meta
		big_card._definition = CardDatabase.get_card(meta, false)
		big_card.initialize_graphics()

func _on_label_meta_hover_ended(_meta: Variant) -> void:
	big_card.visible = false
