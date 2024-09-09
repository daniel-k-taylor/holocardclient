@tool
class_name CardZone
extends PanelContainer

signal zone_pressed

@onready var zone_text_label : Label = $Margin/Layout/ZoneName
@onready var loc1 = $Margin/Layout/GridContainer/ZoneLocation1
@onready var loc2 = $Margin/Layout/GridContainer/ZoneLocation2
@onready var loc3 = $Margin/Layout/GridContainer/ZoneLocation3
@onready var loc4 = $Margin/Layout/GridContainer/ZoneLocation4
@onready var loc5 = $Margin/Layout/GridContainer/ZoneLocation5
@onready var loc6 = $Margin/Layout/GridContainer/ZoneLocation6
@onready var zone_locations = [loc1, loc2, loc3, loc4, loc5, loc6]

@onready var zone_button : TextureButton = $ZoneButton

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
var CenterCardOval
var HorizontalRadius
var VerticalRadius

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
	if layout_style == LayoutStyle.Floating or layout_style == LayoutStyle.Hand:
		set_transparent(true)

	zone_button.visible = layout_style == LayoutStyle.Archive

	if not Engine.is_editor_hint():
		CenterCardOval = Vector2(get_viewport().content_scale_size) * Vector2(0.5, 1.3)
		HorizontalRadius = get_viewport().content_scale_size.x * 0.55
		VerticalRadius = get_viewport().content_scale_size.y * 0.4

func set_transparent(is_transparent):
	if is_transparent:
		modulate = Color(1, 1, 1, 0)
	else:
		modulate = Color(1, 1, 1, 1)

func set_layout_style(style):
	layout_style = style

func add_card(card : CardBase, at_index : int = -1):
	match layout_style:
		LayoutStyle.Hand:
			card.scale = Vector2(CardBase.DefaultCardScale, CardBase.DefaultCardScale)
		LayoutStyle.Archive:
			card.scale = Vector2(CardBase.ArchiveCardScale, CardBase.ArchiveCardScale)
		_:
			card.scale = Vector2(CardBase.StageCardScale, CardBase.StageCardScale)
	if layout_style == LayoutStyle.Floating:
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
		layout_player_hand()
	elif layout_style == LayoutStyle.Backstage:
		assert(len(cards) < 7)
		for i in range(len(cards)):
			var card = cards[i]
			var center = zone_locations[i].global_position + card_offset
			card.begin_move_to(center, false)
	elif layout_style == LayoutStyle.Archive:
		var center = loc1.global_position + card_offset
		for card in cards:
			card.begin_move_to(center, false)
	else:
		var center = loc1.global_position + card_offset
		if cards:
			assert(len(cards) == 1)
			for card in cards:
				card.begin_move_to(center, false)

func get_cards_in_zone():
	return cards

func remove_card(card_id : String):
	for i in range(len(cards)):
		var card = cards[i]
		if card._card_id == card_id:
			cards.erase(card)
			if layout_style == LayoutStyle.Hand:
				card.reset_rotation()
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

func layout_player_hand():
	var num_cards = len(cards)
	if num_cards > 0:
		if num_cards == 1:
			var card : CardBase = cards[0]
			var angle = deg_to_rad(90)
			var ovalAngleVector = Vector2(HorizontalRadius * cos(angle), -VerticalRadius * sin(angle))
			var dst_pos = CenterCardOval + ovalAngleVector
			card.begin_move_to(dst_pos, false)
		else:
			var min_angle = deg_to_rad(60)
			var max_angle = deg_to_rad(120)
			var max_angle_diff = deg_to_rad(10)

			var angle_diff = (max_angle - min_angle) / (num_cards - 1)
			if angle_diff > max_angle_diff:
				angle_diff = max_angle_diff
				var total_angle = min_angle + angle_diff * (num_cards - 1)
				var extra_angle = (max_angle - total_angle) / 2
				min_angle += extra_angle
				max_angle -= extra_angle

			for i in range(num_cards):
				var card : CardBase = cards[num_cards - i - 1]

				# Calculate the angle for this card, distributing the cards evenly between min_angle and max_angle
				var angle = min_angle + i * (max_angle - min_angle) / (num_cards - 1)

				var ovalAngleVector = Vector2(HorizontalRadius * cos(angle), -VerticalRadius * sin(angle))
				var dst_pos = CenterCardOval + ovalAngleVector # - size/2
				var dst_rot = (90 - rad_to_deg(angle)) / 4
				card.begin_move_to(dst_pos, false)
				card._begin_rotation(dst_rot, false)

func _on_zone_button_pressed() -> void:
	zone_pressed.emit()
