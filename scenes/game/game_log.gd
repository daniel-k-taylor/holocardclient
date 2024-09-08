class_name GameLog
extends CenterContainer

@onready var label : RichTextLabel = $PanelContainer/VBoxContainer/PanelContainer/Label

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

func replace_tag(text, tag, color):
	text = text.replace("[%s]" % tag, "[color=%s]" % [color])
	text = text.replace("[/%s]" % tag, "[/color]")
	return text

func add_to_log(log_type, text : String):
	text = text.replace("You", "[color=%s]You[/color]" % [DEFAULT_PLAYER_COLOR])
	text = text.replace("Opponent", "[color=%s]Opponent[/color]" % [DEFAULT_OPPONENT_COLOR])
	text = replace_tag(text, "CARD", CARD_COLOR)
	text = replace_tag(text, "PHASE", PHASE_COLOR)
	text = replace_tag(text, "DECISION", DECISION_COLOR)
	text = replace_tag(text, "SKILL", SKILL_COLOR)
	full_log.append({
		"log_type": log_type,
		"text": text,
	})
	label.text += "\n%s" % text

func _on_close_button_pressed() -> void:
	visible = false
