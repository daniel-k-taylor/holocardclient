class_name PopoutElement
extends PanelContainer

@onready var placeholder : MarginContainer = $MarginContainer/VBoxContainer/CardPlaceholder
@onready var controls = $MarginContainer/VBoxContainer/MarginContainer/CardControls
@onready var top_label = $MarginContainer/VBoxContainer/MarginContainer/TopContainer

var _move_callback

func _ready():
	set_top_visible(false)
	placeholder.custom_minimum_size.x = CardBase.DefaultCardSize.x * CardBase.ReferenceCardScale
	placeholder.custom_minimum_size.y = CardBase.DefaultCardSize.y * CardBase.ReferenceCardScale

func set_card_controls(enabled:bool, move_callback):
	controls.visible = enabled
	_move_callback = move_callback

func set_top_visible(is_top):
	top_label.visible = is_top

func add_card(card : CardBase):
	placeholder.add_child(card)

func position_card():
	var card = placeholder.get_child(0)
	card.scale = Vector2(CardBase.ReferenceCardScale, CardBase.ReferenceCardScale)
	var desired_pos = CardBase.ReferenceCardScale * (CardBase.DefaultCardSize / 2)
	card.begin_move_to(desired_pos, true)

func get_card_id():
	return placeholder.get_child(0)._card_id

func _on_minus_button_pressed() -> void:
	_move_callback.call(self, -1)

func _on_plus_button_pressed() -> void:
	_move_callback.call(self, 1)
