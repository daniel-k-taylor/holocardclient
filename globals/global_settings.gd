extends Node

signal settings_loaded
signal setting_changed_UseEnProxies
signal setting_changed_HideEnglishCardText

const ReleaseLoggingEnabled = false # If true, log even on release builds.
const UseAzureServerAlways = false # If true, always defaults to the azure server. Otherwise release=Azure, dev=local.
const ClientVersionString : String = "240924.1930" # YYMMDD.HHMM
const ReplayVersion = 1 # Increment this when you break replay compatibility.

var LoggingEnabled : bool = true

const GameSound = "GameSound"
const UseEnProxies = "UseEnProxies"
const HideEnglishCardText = "HideEnglishCardText"
const SavedDecks = "SavedDecks"
const SelectedDeckIndex = "SelectedDeckIndex"

const user_settings_file = "user://settings.json"

var user_settings = {
	GameSound: true,
	HideEnglishCardText: false,
	UseEnProxies: true,
	SavedDecks: [],
	SelectedDeckIndex: 0,
}

var setting_to_signal_map = {
	HideEnglishCardText: setting_changed_HideEnglishCardText,
	UseEnProxies: setting_changed_UseEnProxies,
}

func get_client_version() -> String:
	var prepend = ""
	if OS.is_debug_build():
		prepend = "dev_"
	return prepend + ClientVersionString

func get_server_url() -> String:
	const azure_url = "wss://holocard-hwdegne5cse4hrfy.eastus-01.azurewebsites.net/ws"
	const local_url = "ws://127.0.0.1:8000/ws"

	if UseAzureServerAlways or not OS.is_debug_build():
		return azure_url
	else:
		return local_url

func is_logging_enabled() -> bool:
	if not LoggingEnabled:
		return false
	if ReleaseLoggingEnabled:
		return true
	return OS.is_debug_build()

func toggle_logging(toggle_on : bool) -> void:
	LoggingEnabled = toggle_on

func get_user_setting(setting_name : String):
	return user_settings[setting_name]

func save_user_setting(setting_name : String, value):
	user_settings[setting_name] = value
	if setting_name in setting_to_signal_map:
		setting_to_signal_map[setting_name].emit()
	save_persistent_settings()

func save_persistent_settings():
	var file = FileAccess.open(user_settings_file, FileAccess.WRITE)
	file.store_line(JSON.stringify(user_settings))

func load_persistent_settings() -> bool:  # returns success code
	if not FileAccess.file_exists(user_settings_file):
		print("Unable to load settings file.")
		return false # Error! We don't have a save to load.

	var file = FileAccess.open(user_settings_file, FileAccess.READ)
	var text = file.get_as_text()
	var json = JSON.parse_string(text)
	print("Settings json: %s" % text)
	# Update the keys in user_settings based on this json.
	for key in json.keys():
		if user_settings.has(key):
			user_settings[key] = json[key]
		else:
			print("Unknown setting in settings file: %s" % key)
	settings_loaded.emit()
	return true
