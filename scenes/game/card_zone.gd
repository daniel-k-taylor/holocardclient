class_name CardZone
extends PanelContainer

#signal on_card_pressed(card_id, card_graphic)

@export var ZoneName = "Unset"
@onready var zone_card_container = $Margin/Layout/ZoneContents

enum LayoutStyle {
	Archive,
	Single,
	Hand,
	Backstage,
}

var layout_style = LayoutStyle.Single

var cards = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Margin/Layout/ZoneName.text = ZoneName

func set_layout_style(style):
	layout_style = style

func add_card(card : CardBase):
	cards.append(card)
	layout_zone()

func layout_zone():
	var center = zone_card_container.global_position
	if cards:
		center += cards[0].scale * (CardBase.DefaultCardSize / 2)
	if layout_style == LayoutStyle.Hand:
		for i in range(len(cards)):
			var card = cards[i]
			card.position = center
			card.position.x += i * 80
	elif layout_style == LayoutStyle.Backstage:
		for i in range(len(cards)):
			var card = cards[i]
			card.position = center
			card.position.x += i * 80
	elif layout_style == LayoutStyle.Archive:
		for card in cards:
			card.position = center
	else:
		if cards:
			assert(len(cards) == 1)
			for card in cards:
				card.position = center

func get_cards_in_zone():
	return cards

func remove_card(card_id : String):
	for card in cards:
		if card._card_id == card_id:
			cards.erase(card)
			layout_zone()
			break
