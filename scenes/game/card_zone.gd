class_name CardZone
extends PanelContainer

#signal on_card_pressed(card_id, card_graphic)

@export var ZoneName = "Unset"

enum LayoutStyle {
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
	if layout_style == LayoutStyle.Hand:
		for i in range(len(cards)):
			var card = cards[i]
			card.position = global_position
			card.position.x += i * 80
	elif layout_style == LayoutStyle.Backstage:
		for i in range(len(cards)):
			var card = cards[i]
			card.position = global_position
			card.position.x += i * 80
	else:
		assert(len(cards) == 1)
		for card in cards:
			card.position = global_position


func get_cards_in_zone():
	return cards

func remove_card(card_id : String):
	for card in cards:
		if card._card_id == card_id:
			cards.erase(card)
			layout_zone()
			break
