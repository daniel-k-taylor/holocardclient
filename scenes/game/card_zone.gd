extends PanelContainer

signal on_card_pressed(card_id, card_graphic)

@export var ZoneName = "Unset"

const CardEntry = preload("res://scenes/game/card_entry.gd")
const CardEntryScene = preload("res://scenes/game/card_entry.tscn")

@onready var zone_contents = $Margin/Layout/ZoneContents


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Margin/Layout/ZoneName.text = ZoneName

func add_card(card):
	var new_entry : CardEntry = CardEntryScene.instantiate()
	zone_contents.add_child(new_entry)
	new_entry.set_data(card)
	new_entry.connect("on_card_pressed", func(card_id, card_graphic): on_card_pressed.emit(card_id, card_graphic))

func get_card_ids_in_zone():
	var card_ids = []
	for child in zone_contents.get_children():
		if child is CardEntry:
			card_ids.append(child.get_card_id())
	return card_ids

func remove_card(card_id : String):
	for child in zone_contents.get_children():
		if child is CardEntry and child.get_card_id() == card_id:
			child.clear_data()
			zone_contents.remove_child(child)
			break
