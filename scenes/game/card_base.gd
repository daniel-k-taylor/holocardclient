class_name CardBase
extends Node2D

signal clicked_card(card_id, card)
signal hover_card(card_id, card, hover)
signal view_attachments(card_ids)

const DefaultCardSize = Vector2(250.0, 350.0)
const DefaultCardScale = 0.5
const StageCardScale = 0.45
const ReferenceCardScale = 0.6
const ArchiveCardScale = 0.4

const CheerIndicatorScene = preload("res://scenes/game/cheer_indicator.tscn")
const CardTextInfoScene = preload("res://scenes/game/card_text_info.tscn")
const CardBaseScene = preload("res://scenes/game/card_base.tscn")

@onready var card_image : TextureRect = $OuterMargin/InnerMargin/PanelContainer/CardImageHolder/CardImage
@onready var card_id_label = $OuterMargin/InnerMargin/PanelContainer/Overlay/HBoxContainer2/PanelContainer/MarginContainer/CardIdLabel
@onready var card_def_label = $OuterMargin/InnerMargin/PanelContainer/Overlay/HBoxContainer/PanelContainer/MarginContainer/CardDefLabel
@onready var cheer_indicators = $OuterMargin/InnerMargin/PanelContainer/CheerIndicators/PanelContainer/CheerVBox
@onready var selected_highlight = $OuterMargin/Highlight
@onready var info_highlight = $OuterMargin/InfoHighlight
@onready var selection_button = $OuterMargin/Button
@onready var damage_indicator = $OuterMargin/DamageIndicator
@onready var damage_label = $OuterMargin/DamageIndicator/HBox/MarginContainer/MarginContainer/CenterContainer/DamageLabel
@onready var card_text_info_container = $OuterMargin/InnerMargin/PanelContainer/Overlay/PanelContainer/CardTextContainer
@onready var overlay_root = $OuterMargin/InnerMargin/PanelContainer/Overlay
@onready var attachment_box = $OuterMargin/AttachmentIndicator/AttachmentBox
@onready var attachment_count = $OuterMargin/AttachmentIndicator/AttachmentBox/MarginContainer/HBox/AttachmentCount

@export var is_big_card : bool = false

var _card_id
var _definition_id
var _definition

var _cheer : Dictionary = {}
var damage = 0
var dead = false
var _card_type
var _attached_cards = []

var _selected = false
var _selectable = false
var _resting = false

const RotationTime = 0.5
var target_rotation = 0.0
var rotation_start_time = RotationTime

const PositionTime = 0.8
var target_position = Vector2.ZERO
var position_start_time = PositionTime
var _destroy_on_move_completion = false

func _ready():
	info_highlight.visible = false
	selected_highlight.visible = false
	if is_big_card:
		visible = false
		selection_button.visible = false
	if scale.x == 1.0:
		scale = Vector2(DefaultCardScale, DefaultCardScale)
	attachment_box.visible = false

func _process(delta: float) -> void:
	if is_big_card:
		return

	if rotation_degrees != target_rotation:
		rotation_start_time += delta
		rotation_degrees = lerp(rotation_degrees, target_rotation, rotation_start_time / RotationTime)
		if abs(rotation_degrees - target_rotation) < 1:
			rotation_degrees = target_rotation

	if position != target_position:
		position_start_time += delta
		position = lerp(position, target_position, position_start_time / PositionTime)
		if position.distance_to(target_position) < 1:
			position = target_position
			if _destroy_on_move_completion:
				queue_free()

func _begin_rotation(target, immediate : bool):
	if immediate:
		target_rotation = target * 1.0
		rotation_degrees = target * 1.0
	else:
		target_rotation = target * 1.0
		rotation_start_time = 0

func reset_rotation():
	if _resting:
		_begin_rotation(90, false)
	else:
		_begin_rotation(0, false)

func begin_move_to(target, immediate : bool, destroy_on_completion : bool = false):
	_destroy_on_move_completion = destroy_on_completion
	if _destroy_on_move_completion and (target == position or immediate):
		visible = false
		queue_free()
		return
	if immediate:
		target_position = target
		position = target
	else:
		target_position = target
		position_start_time = 0

func create_card(definition, definition_id, card_id, card_type):
	_definition = definition
	_definition_id = definition_id
	_card_id = card_id
	_card_type = card_type

func set_button_visible(button_visible):
	if button_visible:
		selection_button.modulate = Color(1, 1, 1, 1)
	else:
		selection_button.modulate = Color(1, 1, 1, 0)

func initialize_graphics():
	if _definition_id == "HIDDEN":
		card_image.texture = load("res://assets/cardbacks/holo_back.png")
		overlay_root.visible = false
		damage_indicator.visible = false
	else:
		var rarity = CardDatabase.get_card(_definition_id)["rarity"].to_upper()
		var jp_path = "res://assets/cards/" + _definition_id + "_" + rarity + ".png"
		var en_path = "res://assets/cards/en/" + _definition_id  + ".jpg"
		# Check if the en card exists.
		var use_en_proxies = GlobalSettings.get_user_setting(GlobalSettings.UseEnProxies)
		if use_en_proxies and FileAccess.file_exists(en_path):
			card_image.texture = load(en_path)
			overlay_root.visible = false
		else:
			card_image.texture = load(jp_path)
	set_button_visible(false)
	_update_stats()
	_update_english_text()

func _update_english_text():
	if _definition_id == "HIDDEN":
		return

	# Remove any previous text.
	var children = card_text_info_container.get_children()
	for child in children:
		card_text_info_container.remove_child(child)
		child.queue_free()

	var english_data = Strings.build_english_card_text(_definition)
	for info_data in english_data:
		var new_info : CardTextInfo = CardTextInfoScene.instantiate()
		card_text_info_container.add_child(new_info)
		new_info.set_text(info_data["colors"], info_data["text"])

func get_texture():
	return card_image.texture

func copy_stats(card : CardBase):
	damage = card.damage

func copy_graphics(card : CardBase):
	selection_button.visible = false
	card_image.texture = card.get_texture()
	_card_id = card._card_id
	_definition_id = card._definition_id
	_definition = card._definition
	_cheer = card._cheer
	damage = card.damage
	dead = card.dead
	_card_type = card._card_type
	set_selected(card._selected)
	set_selected_highlight(card.selected_highlight.visible)
	_update_stats()
	_update_english_text()
	card_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay_root.visible = card.overlay_root.visible

func is_holomem_card():
	return _card_type in ["holomem_debut", "holomem_bloom", "holomem_spot"]

func set_selected(is_selected : bool) -> void:
	_selected = is_selected
	set_selected_highlight(is_selected)

func set_selectable(is_selectable : bool) -> void:
	_selectable = is_selectable
	set_button_visible(is_selectable)

func set_selected_highlight(is_seleted : bool) -> void:
	selected_highlight.visible = is_seleted

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
	if _definition_id == "HIDDEN":
		return

	var num_attachments = len(_attached_cards)
	attachment_box.visible = num_attachments > 0
	attachment_count.text = str(num_attachments)

	card_def_label.text = "%s - %s" % [_definition_id, _card_id.split("_")[1]]
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

	damage_indicator.visible = damage > 0
	damage_label.text = str(damage)

func attach_cheer(card_id, colors : Array):
	_cheer[card_id] = colors
	_update_stats()

func remove_attached(card_id):
	if card_id in _cheer:
		_cheer.erase(card_id)
		_update_stats()
	elif card_id in _attached_cards:
		_attached_cards.erase(card_id)
		_update_stats()

func remove_cheer(card_id):
	_cheer.erase(card_id)
	_update_stats()

func add_damage(amount, is_dead : bool):
	damage += amount
	dead = is_dead
	_update_stats()

func set_damage(amount):
	damage = amount
	_update_stats()

func set_resting(is_resting, immediate : bool = false):
	if _resting != is_resting:
		_resting = is_resting
		if _resting:
			_begin_rotation(90, immediate)
		else:
			_begin_rotation(0, immediate)

func attach_card(card_id):
	_attached_cards.append(card_id)
	_update_stats()

func get_attached():
	return _attached_cards.duplicate()

func clear_attached():
	_attached_cards = []

func remove_all_attached_cheer():
	var cheer = _cheer.duplicate()
	_cheer = {}
	return cheer

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

func get_compare_value():
	var compare_value = 0
	var card_type = _definition["card_type"]
	var card_name = ""
	match card_type:
		"holomem_spot":
			compare_value = 10000
			card_name = _definition["holomem_names"][0]
		"holomem_debut":
			compare_value = 20000
			card_name = _definition["holomem_names"][0]
		"holomem_bloom":
			compare_value = 30000
			card_name = _definition["holomem_names"][0]
		"support":
			compare_value = 40000
			card_name = _definition["support_names"][0]
	if "bloom_level" in _definition:
		compare_value += _definition["bloom_level"] * 1000
	if "limited" not in _definition or not _definition["limited"]:
		compare_value += 1000

	var compare_str = "%s_%s_%s" % [compare_value, card_name, _definition_id]

	return compare_str

func compare(other : CardBase):
	return get_compare_value() < other.get_compare_value()

func _on_button_pressed() -> void:
	if _selectable:
		clicked_card.emit(_card_id, self)

func _on_button_mouse_entered() -> void:
	if not is_big_card:
		hover_card.emit(_card_id, self, true)

func _on_button_mouse_exited() -> void:
	if not is_big_card:
		hover_card.emit(_card_id, self, false)

func _on_attachment_button_pressed() -> void:
	view_attachments.emit(_attached_cards)
