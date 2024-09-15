class_name HowToPlay
extends CenterContainer

@onready var page_label = $PanelContainer/VBoxContainer/HBoxContainer/PageCountLabel
@onready var page1 = $PanelContainer/VBoxContainer/HelpImage
@onready var page2 = $PanelContainer/VBoxContainer/HelpImage2
@onready var prev = $PanelContainer/VBoxContainer/HBoxContainer/PreviousPageButton
@onready var next = $PanelContainer/VBoxContainer/HBoxContainer/NextPageButton

func show_help():
	visible = true
	_on_previous_page_button_pressed()

func _on_previous_page_button_pressed() -> void:
	page_label.text = str(1)
	page1.visible = true
	page2.visible = false
	prev.disabled = true
	next.disabled = false

func _on_next_page_button_pressed() -> void:
	page_label.text = str(2)
	page2.visible = true
	page1.visible = false
	prev.disabled = false
	next.disabled = true

func _on_fullscreen_close_button_pressed() -> void:
	visible = false
