class_name CardEntry
extends PanelContainer

signal on_card_pressed(card_id, card_graphic)

@onready var contents_label = $EntryContents/EntryLabel
@onready var selection_highlight = $SelectionHighlight
@onready var selection_button = $SelectionButton
var _card : CardBase = null
var _card_id = -1

var _selected = false
var _selectable = false

func set_data(card : CardBase):
	_card = card
	_card_id = _card._card_id
	_card._selected_graphic_link = self
	selection_button.visible = false
	self.update_stats()

func clear_data():
	_card._selected_graphic_link = null

func update_stats():
	var cheer = _card.get_cheer_counts()
	var label_text = get_card_definition_id()
	if _card.is_holomem_card():
		label_text += "\nDamage %s" % [_card.damage]
		for cheer_name in cheer:
			label_text += "\n%s %s" % [cheer_name, cheer[cheer_name]]
		contents_label.text = label_text

func get_card_id():
	return _card._card_id
	
func get_card_definition_id():
	return _card._definition_id

func _on_selection_button_pressed() -> void:
	on_card_pressed.emit(_card._card_id, self)

func set_selected(is_selected : bool):
	_selected = is_selected
	selection_highlight.visible = _selected

func set_selectable(is_selectable : bool):
	_selectable = is_selectable
	selection_button.visible = _selectable
