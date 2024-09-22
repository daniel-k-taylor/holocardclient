extends CenterContainer

signal exit_game_pressed

@onready var use_en_proxies : CheckButton = $PanelContainer/MarginContainer/VBoxContainer/UseEnProxies
@onready var exit_button = $PanelContainer/MarginContainer/VBoxContainer/ExitGameButton

func load_settings():
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
