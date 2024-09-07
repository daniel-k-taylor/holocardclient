class_name PopoutElement
extends PanelContainer

@onready var placeholder : MarginContainer = $MarginContainer/VBoxContainer/CardPlaceholder
@onready var controls = $MarginContainer/VBoxContainer/CardControls

func set_card_controls(enabled:bool):
	controls.visible = enabled

func add_card(card : CardBase):
	placeholder.add_child(card)
	card.position = CardBase.DefaultCardScale * (CardBase.DefaultCardSize / 2)
