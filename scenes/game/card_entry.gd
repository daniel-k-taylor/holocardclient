extends PanelContainer

@onready var contents_label = $EntryContents/EntryLabel
var _card_id = -1

func set_data(card_id : String):
	_card_id = card_id
	contents_label.text = _card_id

func get_card_id():
	return _card_id
