extends CenterContainer

@onready var use_en_proxies : CheckButton = $PanelContainer/MarginContainer/VBoxContainer/UseEnProxies

func load_settings():
	use_en_proxies.button_pressed = GlobalSettings.get_user_setting(GlobalSettings.UseEnProxies)
	
func show_settings():
	load_settings()
	visible = true

func close_window():
	visible = false
	
func change_setting(value, setting_name):
	GlobalSettings.save_user_setting(setting_name, value)
