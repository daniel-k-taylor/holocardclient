extends PanelContainer

@onready var content = $MarginContainer/Content


const TITLE = "proxy_full_name"
const DESCRIPTION = "proxy_full_text"


func update_content(card: CardBase) -> void:
	visible = card.show_card_info_panel
	if not visible:
		return

	# clean up
	for child in content.get_children():
		content.remove_child(child)
		child.queue_free()
	content.reset_size()

	var card_data = card._definition
	match card_data["card_type"]:
		"oshi":
			var skills = []
			skills.append_array(card_data.get("actions", []))
			skills.append_array(card_data.get("effects", []))
			content.add_child(_create_oshi_content(Strings.get_string("Oshi Skill"), skills[0]))
			content.add_child(_create_oshi_content(Strings.get_string("SP Oshi Skill"), skills[1]))
		"holomem_debut", "holomem_bloom", "holomem_spot":
			for content_item in _create_holomem_content(card_data):
				content.add_child(content_item)
		_:
			visible = false

	if content.get_children().size() == 0:
		visible = false


func _create_holomem_content(card) -> Array:
	var controls = []
	# process gifts, blooms, and collabs
	var specials = [
		{ "tag": "Gift:", "effects": card.get("gift_effects", []) },
		{ "tag": "Bloom:", "effects": card.get("bloom_effects", []) },
		{ "tag": "Collab:", "effects": card.get("collab_effects", []) }
	]
	for special in specials:
		var tag = special["tag"]
		for effect in special["effects"]:
			var title_label = _create_rich_text_label("[u]%s  [b]%s[/b][/u]" % \
				[Strings.get_string(tag), Strings.get_string(effect.get(TITLE, ""))])
			var description_label = _create_text_label(Strings.get_string(effect.get(DESCRIPTION, "")))
			controls.append(_create_vcontainer([title_label, description_label]))

	# process arts
	var arts = card.get("arts", [])
	for art in arts:
		var costs_text = ""
		for cost in art.get("costs", []):
			for i in range(cost["amount"]):
				costs_text += _build_cheer_string(cost["color"])
		var art_label = _create_rich_text_label("% [b][u]%s[/u]  %s[/b]" % \
			[costs_text, Strings.get_skill_string(art["art_id"]), art["power"]])
		var description_label = _create_text_label(Strings.get_string(art.get(DESCRIPTION, "")))
		controls.append(_create_vcontainer([art_label, description_label]))

	# process tags
	var tags_label = _create_text_label("  ".join(Strings.get_tags_strings(card["tags"])))
	controls.append(tags_label)
	#
	return controls


func _create_oshi_content(tag: String, data) -> VBoxContainer:
	var title_label = _create_rich_text_label(
		"[u]%s:  [b]-%s %s[/b][/u]" % [tag, data["cost"], Strings.get_skill_string(data["skill_id"])])
	var description_label = _create_text_label(Strings.get_string(data.get(DESCRIPTION, "")))
	return _create_vcontainer([title_label, description_label])


func _create_rich_text_label(text: String) -> RichTextLabel:
	var label = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = text
	return label


func _create_text_label(text: String) -> Label:
	var label = Label.new()
	label.add_theme_font_size_override("font_size", 12)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = text
	return label


func _create_vcontainer(children: Array[Control] = []) -> VBoxContainer:
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 5)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in children:
		container.add_child(child)
	return container


func _build_cheer_string(color: String) -> String:
	return "[img=%s]res://assets/cheer_icons/%s.png[/img]" % [24, color]
