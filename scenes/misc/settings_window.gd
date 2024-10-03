extends CenterContainer

signal exit_game_pressed

@onready var game_sound : CheckButton = $PanelContainer/MarginContainer/VBoxContainer/GameSound
@onready var hide_english_card_text : CheckButton = $PanelContainer/MarginContainer/VBoxContainer/HideEnglishCardText
@onready var use_en_proxies : CheckButton = $PanelContainer/MarginContainer/VBoxContainer/UseEnProxies
@onready var exit_button = $PanelContainer/MarginContainer/VBoxContainer/ExitGameButton
@onready var language_select : OptionButton = $PanelContainer/MarginContainer/VBoxContainer/LanguageBox/LanguageSelect
@onready var downloading_panel = $DownloadingPanel
@onready var modal = $ModalDialog
@onready var bytes_downloaded_label : Label = $DownloadingPanel/CenterContainer/PanelContainer/VBox/Progress/BytesDownloaded
@onready var total_bytes_label : Label = $DownloadingPanel/CenterContainer/PanelContainer/VBox/Progress/TotalBytes
@onready var download_percent_label : Label = $DownloadingPanel/CenterContainer/PanelContainer/VBox/ProgressPercent/Value

var active_request : HTTPRequest = null
var active_download_language_code = ""

func _ready():
	var index = 0
	for language_code in GlobalSettings.SupportedLanguages:
		language_select.add_item(GlobalSettings.SupportedLanguages[language_code]["name"], index)
		index += 1

func _process(_delta: float) -> void:
	if active_request and active_download_language_code:
		var bytes_downloaded = active_request.get_downloaded_bytes()
		var total_bytes = GlobalSettings.get_card_pack_size(active_download_language_code)
		bytes_downloaded_label.text = str(bytes_downloaded)
		total_bytes_label.text = str(total_bytes)
		# Format the download percentage to 2 decimal places
		download_percent_label.text = str(snapped((bytes_downloaded * 100.0 / total_bytes), 0.01))

func load_settings():
	game_sound.button_pressed = GlobalSettings.get_user_setting(GlobalSettings.GameSound)
	hide_english_card_text.button_pressed = GlobalSettings.get_user_setting(GlobalSettings.HideEnglishCardText)
	use_en_proxies.button_pressed = GlobalSettings.get_user_setting(GlobalSettings.UseEnProxies)
	language_select.selected = GlobalSettings.SupportedLanguages.keys().find(GlobalSettings.get_user_setting(GlobalSettings.Language))

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

func _on_language_select_item_selected(index: int) -> void:
	var language_code = GlobalSettings.SupportedLanguages.keys()[index]
	if language_code: #GlobalSettings.has_card_language_pack(language_code):
		GlobalSettings.save_user_setting(GlobalSettings.Language, language_code)
	else:
		downloading_panel.visible = true
		active_download_language_code = language_code
		active_request = GlobalSettings.download_card_pack(language_code, func(success: bool):
			active_request = null
			downloading_panel.visible = false
			if success:
				GlobalSettings.save_user_setting(GlobalSettings.Language, language_code)
			else:
				modal.set_text_fields("Failed to download card pack.", "", "OK")
				language_select.selected = GlobalSettings.SupportedLanguages.keys().find(GlobalSettings.get_user_setting(GlobalSettings.Language))
		)
