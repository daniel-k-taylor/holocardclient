@tool
class_name CardZone
extends PanelContainer

@onready var zone_text_label : Label = $Margin/Layout/ZoneName
@onready var loc1 = $Margin/Layout/GridContainer/ZoneLocation1
@onready var loc2 = $Margin/Layout/GridContainer/ZoneLocation2
@onready var loc3 = $Margin/Layout/GridContainer/ZoneLocation3
@onready var loc4 = $Margin/Layout/GridContainer/ZoneLocation4
@onready var loc5 = $Margin/Layout/GridContainer/ZoneLocation5
@onready var loc6 = $Margin/Layout/GridContainer/ZoneLocation6
@onready var zone_locations = [loc1, loc2, loc3, loc4, loc5, loc6]

@export var zone_name : String = "Unset" :
	set(value):
		zone_name = value
		if zone_text_label:
			zone_text_label.text = zone_name

enum LayoutStyle {
	Archive,
	Single,
	Hand,
	Backstage,
	Floating,
}

@export var layout_style : LayoutStyle = LayoutStyle.Single :
	set(value):
		layout_style = value
		_update_locations()

var cards = []

func _update_locations():
	if zone_locations:
		for loc in zone_locations:
			if loc:
				if layout_style == LayoutStyle.Backstage:
					for i in range(len(zone_locations) - 1):
						zone_locations[i+1].visible = true
				else:
					for i in range(len(zone_locations) - 1):
						zone_locations[i+1].visible = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	zone_text_label.text = zone_name
	_update_locations()
	if layout_style == LayoutStyle.Floating:
		set_transparent(true)

func set_transparent(is_transparent):
	if is_transparent:
		modulate = Color(1, 1, 1, 0)
	else:
		modulate = Color(1, 1, 1, 1)

func set_layout_style(style):
	layout_style = style

func add_card(card : CardBase, at_index : int = -1):
	set_transparent(false)
	if at_index != -1:
		cards.insert(at_index, card)
	else:
		cards.append(card)
	layout_zone()

func layout_zone():
	var card_offset = Vector2.ZERO
	if cards:
		card_offset = cards[0].scale * (CardBase.DefaultCardSize / 2)
	if layout_style == LayoutStyle.Hand:
		order_hand()
		var center = loc1.global_position + card_offset
		for i in range(len(cards)):
			var card = cards[i]
			card.position = center
			card.position.x += i * 80
	elif layout_style == LayoutStyle.Backstage:
		assert(len(cards) < 7)
		for i in range(len(cards)):
			var card = cards[i]
			var center = zone_locations[i].global_position + card_offset
			card.position = center
	elif layout_style == LayoutStyle.Archive:
		var center = loc1.global_position + card_offset
		for card in cards:
			card.position = center
	else:
		var center = loc1.global_position + card_offset
		if cards:
			assert(len(cards) == 1)
			for card in cards:
				card.position = center

func get_cards_in_zone():
	return cards

func remove_card(card_id : String):
	for i in range(len(cards)):
		var card = cards[i]
		if card._card_id == card_id:
			cards.erase(card)
			layout_zone()
			if len(cards) == 0 and layout_style == LayoutStyle.Floating:
				set_transparent(true)
			return i
	return -1

func order_hand():
	cards.sort_custom(
	func(a, b):
		return a.compare(b)
	)
