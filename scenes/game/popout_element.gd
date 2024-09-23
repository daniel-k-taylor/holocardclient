class_name PopoutElement
extends PanelContainer

@onready var placeholder : MarginContainer = $MarginContainer/VBoxContainer/CardPlaceholder
@onready var controls = $MarginContainer/VBoxContainer/MarginContainer/CardControls
@onready var top_container = $MarginContainer/VBoxContainer/MarginContainer/TopContainer
@onready var top_label = $MarginContainer/VBoxContainer/MarginContainer/TopContainer/TopLabelContainer/MarginContainer/TopLabel
@onready var number_label = $MarginContainer/VBoxContainer/MarginContainer/TopContainer/TopLabelContainer/MarginContainer/NumberLabel

var _move_callback

func _ready():
	set_top_visible(false)
	number_label.visible = false
	placeholder.custom_minimum_size.x = CardBase.DefaultCardSize.x * CardBase.ReferenceCardScale
	placeholder.custom_minimum_size.y = CardBase.DefaultCardSize.y * CardBase.ReferenceCardScale

func set_card_controls(enabled:bool, move_callback):
	controls.visible = enabled
	_move_callback = move_callback

func set_top_visible(is_top):
	top_container.visible = is_top

func set_number_visible(num):
	top_container.visible = true
	top_label.visible = false
	number_label.visible = true
	number_label.text = str(num)

func get_number():
	return int(number_label.text)

func add_card(card : CardBase):
	placeholder.add_child(card)

func is_selectable():
	if placeholder.get_child_count() > 0:
		return placeholder.get_child(0)._selectable

func position_card():
	var card = placeholder.get_child(0)
	card.scale = Vector2(CardBase.ReferenceCardScale, CardBase.ReferenceCardScale)
	var desired_pos = CardBase.ReferenceCardScale * (CardBase.DefaultCardSize / 2)
	card.begin_move_to(desired_pos, true)

func get_card_id():
	return placeholder.get_child(0)._card_id

func get_definition_id():
	return placeholder.get_child(0)._definition_id

func _on_minus_button_pressed() -> void:
	_move_callback.call(self, -1)

func _on_plus_button_pressed() -> void:
	_move_callback.call(self, 1)
