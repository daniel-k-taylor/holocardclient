class_name DeckCardSlot
extends PanelContainer

signal value_changed(deck_card_slot, card_id, amount)

const DeckCardIcon_oshi = ""
const DeckCardIcon_1st = "cardicon_1st"
const DeckCardIcon_2nd = "cardicon_2nd"
const DeckCardIcon_debut = "cardicon_debut"
const DeckCardIcon_spot = "cardicon_spot"
const DeckCardIcon_support = ""

@onready var color_icon : TextureRect = $MarginContainer/HBoxContainer/ColorIcon
@onready var card_icon : TextureRect = $MarginContainer/HBoxContainer/Icon
@onready var card_name_label : Label = $MarginContainer/HBoxContainer/CardName
@onready var card_count_label : Label = $MarginContainer/HBoxContainer/PlusMinusButtons/CardCount
@onready var buttons = $MarginContainer/HBoxContainer/PlusMinusButtons

var _card_id

func set_details(card, card_count):
	var icon_str = ""
	match card["card_type"]:
		"oshi":
			icon_str = DeckCardIcon_oshi
			buttons.visible = false
		"holomem_debut":
			icon_str = DeckCardIcon_debut
		"holomem_bloom":
			match int(card["bloom_level"]):
				1:
					icon_str = DeckCardIcon_1st
				2:
					icon_str = DeckCardIcon_2nd
		"holomem_spot":
			icon_str = DeckCardIcon_spot
		"support":
			icon_str = DeckCardIcon_support
	_card_id = card["card_id"]
	if "colors" in card:
		color_icon.texture = load("res://assets/cheer_icons/%s.png" % card["colors"][0])
	else:
		color_icon.visible = false
	card_count_label.text = str(card_count)
	if icon_str:
		card_icon.texture = load("res://assets/icons/%s.webp" % icon_str)
	else:
		card_icon.visible = false
	card_name_label.text = Strings.get_names(card["card_names"])[0]

func update_count(card_count):
	card_count_label.text = str(card_count)

func _on_plus_button_pressed() -> void:
	value_changed.emit(self, _card_id, 1)

func _on_minus_button_pressed() -> void:
	value_changed.emit(self, _card_id, -1)
