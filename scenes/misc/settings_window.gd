extends CenterContainer

signal exit_game_pressed

@onready var game_sound : CheckButton = $PanelContainer/MarginContainer/VBoxContainer/GameSound
@onready var hide_english_card_text : CheckButton = $PanelContainer/MarginContainer/VBoxContainer/HideEnglishCardText
@onready var use_en_proxies : CheckButton = $PanelContainer/MarginContainer/VBoxContainer/UseEnProxies
@onready var exit_button = $PanelContainer/MarginContainer/VBoxContainer/ExitGameButton

func load_settings():
	game_sound.button_pressed = GlobalSettings.get_user_setting(GlobalSettings.GameSound)
	hide_english_card_text.button_pressed = GlobalSettings.get_user_setting(GlobalSettings.HideEnglishCardText)
	use_en_proxies.button_pressed = GlobalSettings.get_user_setting(GlobalSettings.UseEnProxies)
	
func show_settings(exit_game_visible = false):
	load_settings()
	visible = true
	exit_button.visible = exit_game_visible

func close_window():
	visible = false
	
func change_setting(value, setting_name):
	GlobalSettings.save_user_setting(setting_name, value)

func _on_button_pressed() -> void:
	exit_game_pressed.emit()
