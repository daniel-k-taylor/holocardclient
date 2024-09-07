class_name CardBase
extends Node2D

signal clicked_card(card_id, card)

const DefaultCardSize = Vector2(250.0, 350.0)
const DefaultCardScale = 0.4

const CheerIndicatorScene = preload("res://scenes/game/cheer_indicator.tscn")

@onready var card_image = $OuterMargin/InnerMargin/PanelContainer/CardImage
@onready var card_id_label = $OuterMargin/InnerMargin/PanelContainer/Overlay/HBoxContainer2/PanelContainer/MarginContainer/CardIdLabel
@onready var card_def_label = $OuterMargin/InnerMargin/PanelContainer/Overlay/HBoxContainer/PanelContainer/MarginContainer/CardDefLabel
@onready var cheer_indicators = $OuterMargin/InnerMargin/PanelContainer/CheerIndicators/PanelContainer/CheerVBox
@onready var info_highlight = $OuterMargin/Highlight
@onready var selection_button = $OuterMargin/Button
var _card_id
var _definition_id

var _cheer : Dictionary = {}
var damage = 0
var _card_type

var _selected = false
var _selectable = false

func create_card(definition_id, card_id, card_type):
	_definition_id = definition_id
	_card_id = card_id
	_card_type = card_type

func initialize_graphics():
	card_image.texture = load("res://assets/cards/" + _definition_id + ".png")
	selection_button.visible = false
	scale = Vector2(0.4, 0.4)
	_update_stats()

func is_holomem_card():
	return _card_type in ["holomem_debut", "holomem_bloom", "holomem_spot"]

func set_selected(is_selected : bool) -> void:
	_selected = is_selected
	info_highlight.visible = is_selected

func set_selectable(is_selectable : bool) -> void:
	_selectable = is_selectable
	selection_button.visible = is_selectable

func set_info_highlight(is_highlighted : bool) -> void:
	info_highlight.visible = is_highlighted

func get_or_create_cheer_indicator(color):
	for cheer_indicator in cheer_indicators.get_children():
		if cheer_indicator.color == color:
			return cheer_indicator
	var cheer_indicator = CheerIndicatorScene.instantiate()
	cheer_indicators.add_child(cheer_indicator)
	cheer_indicator.set_cheer(color, 0)
	return cheer_indicator

func remove_cheer_indicator(color):
	for cheer_indicator in cheer_indicators.get_children():
		if cheer_indicator.color == color:
			cheer_indicators.remove_child(cheer_indicator)
			cheer_indicator.queue_free()
			break

func _update_stats():
	card_def_label.text = _definition_id
	# Use only the card_id part after _ if there is a _.
	# This is to avoid the card_id being too long.
	var small_id = _card_id
	if "_" in _card_id:
		small_id = _card_id.split("_")[1]
	card_id_label.text = small_id
	var cheer_counts = get_cheer_counts()
	for color in cheer_counts:
		var count = cheer_counts[color]
		if count > 0:
			var cheer_indicator = get_or_create_cheer_indicator(color)
			cheer_indicator.set_cheer(color, count)
		else:
			remove_cheer_indicator(color)

func attach_cheer(card_id, colors : Array):
	_cheer[card_id] = colors
	_update_stats()

func remove_cheer(card_id):
	_cheer.erase(card_id)
	_update_stats()

func add_damage(amount):
	damage += amount
	_update_stats()

func remove_damage(amount):
	damage -= amount
	_update_stats()


func get_cheer_counts():
	var blue = 0
	var green = 0
	var red = 0
	var white = 0
	for cheer_id in _cheer:
		var colors = _cheer[cheer_id]
		if "blue" in colors:
			blue += 1
		if "green" in colors:
			green += 1
		if "red" in colors:
			red += 1
		if "white" in colors:
			white += 1
	return {
		"blue": blue,
		"green": green,
		"red": red,
		"white": white,
	}


func _on_button_pressed() -> void:
	clicked_card.emit(_card_id, self)
