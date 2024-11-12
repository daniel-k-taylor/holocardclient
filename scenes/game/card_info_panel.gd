extends PanelContainer

@onready var content = $MarginContainer/Content


const TITLE = "proxy_full_name"
const DESCRIPTION = "proxy_full_text"


func is_show_panel() -> bool:
	return GlobalSettings.get_user_setting(GlobalSettings.ShowPanelInfo)


func update_content(card: CardBase) -> void:
	visible = is_show_panel() and not card.proxy_card_loaded and card._definition_id != "HIDDEN"
	if not visible:
		return

	# clean up
	for child in content.get_children():
		content.remove_child(child)
		child.queue_free()
	content.reset_size()

	for text_item in Strings.build_english_card_text(card._definition):
		var text = _build_cheer_string(text_item["colors"]) + text_item["text"]
		var label = _create_rich_text_label(text)
		content.add_child(label)

	if content.get_children().size() == 0:
		visible = false


func _create_rich_text_label(text: String) -> RichTextLabel:
	var label = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = text
	return label


func _build_cheer_string(colors: Array) -> String:
	var colors_text = ""
	for color in colors:
		colors_text += "[img=%s]res://assets/cheer_icons/%s.png[/img]" % [24, color]
	if colors_text:
		colors_text += "  "
	return colors_text
