extends PanelContainer

@export var ZoneName = "Unset"

const CardEntry = preload("res://scenes/game/card_entry.gd")
const CardEntryScene = preload("res://scenes/game/card_entry.tscn")

@onready var zone_contents = $Margin/Layout/ZoneContents


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Margin/Layout/ZoneName.text = ZoneName

func add_card(card_id : String):
	var new_entry : CardEntry = CardEntryScene.instantiate()
	zone_contents.add_child(new_entry)
	new_entry.set_data(card_id)
	
func remove_card(card_id : String):
	for child in zone_contents.get_children():
		if child is CardEntry and child.get_card_id() == card_id:
			zone_contents.remove_child(child)
			break
