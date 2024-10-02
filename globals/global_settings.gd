extends Node

signal settings_loaded
signal setting_changed_UseEnProxies
signal setting_changed_HideEnglishCardText
signal settings_changed_Language

const ReleaseLoggingEnabled = false # If true, log even on release builds.
const UseAzureServerAlways = false # If true, always defaults to the azure server. Otherwise release=Azure, dev=local.
const ClientVersionString : String = "241001.0130" # YYMMDD.HHMM
const ReplayVersion = 1 # Increment this when you break replay compatibility.

const PlayfabTitleId = "57B37"

var LoggingEnabled : bool = true

const GameSound = "GameSound"
const UseEnProxies = "UseEnProxies"
const HideEnglishCardText = "HideEnglishCardText"
const SavedDecks = "SavedDecks"
const SelectedDeckIndex = "SelectedDeckIndex"
const PlayfabId = "PlayfabId"
const PlayfabSessionTicket = "PlayfabSessionTicket"
const PlayfabUsername = "PlayfabUsername"
const Language = "Language"

const language_dir = "user://card_assets"
const language_details_file = "details.json"

const user_settings_file = "user://settings.json"

var user_settings = {
	GameSound: true,
	HideEnglishCardText: false,
	UseEnProxies: true,
	SavedDecks: [],
	SelectedDeckIndex: 0,
	PlayfabId: "",
	PlayfabSessionTicket: "",
	PlayfabUsername: "",
	Language: "en",
}

var setting_to_signal_map = {
	HideEnglishCardText: setting_changed_HideEnglishCardText,
	UseEnProxies: setting_changed_UseEnProxies,
	Language: settings_changed_Language,
}

const SupportedLanguages = {
	"en": {
		"name": "English",
		"code": "en",
		"version": 1,
		"download_url": "",
		"size": 0,
	},
	"kr": {
		"name": "한국어",
		"code": "kr",
		"version": 1,
		"download_url": "https://fightingcardsstorage.blob.core.windows.net/cardpacks/kr.zip",
		"size": 175355917
	},
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
	if setting_name == GlobalSettings.Language:
		TranslationServer.set_locale(value)
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
	TranslationServer.set_locale(user_settings[GlobalSettings.Language])
	settings_loaded.emit()
	return true

func has_card_language_pack(language_code) -> bool:
	if language_code == "en":
		return true
	var expected_version = SupportedLanguages[language_code]["version"]
	var language_details_file_path = language_dir + "/" + language_code + "/" + language_details_file
	if FileAccess.file_exists(language_details_file_path):
		var file = FileAccess.open(language_details_file_path, FileAccess.READ)
		var text = file.get_as_text()
		var json = JSON.parse_string(text)
		return json.has("version") and json["version"] == expected_version
	return false

func get_card_language_path() -> String:
	return language_dir + "/" + get_user_setting(Language)

func get_card_pack_size(language_code) -> int:
	return SupportedLanguages[language_code]["size"]

func download_card_pack(language_code, callback : Callable):
	var url = SupportedLanguages[language_code]["download_url"]
	var download_dir = language_dir + "/" + language_code
	var download_file = download_dir + ".zip"
	# Make sure download_dir exists.
	if DirAccess.make_dir_recursive_absolute(download_dir) != OK:
		print("Failed to create directory: %s" % download_dir)
		callback.call(false)
		return

	print("Downloading card pack for %s from %s to %s" % [language_code, url, download_file])
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.download_file = download_file
	var custom_headers = []
	http_request.request_completed.connect(func(result, response_code, _headers, body):
		_on_card_pack_download_complete(result, response_code, body, callback, language_code)
	)
	var error = http_request.request(url, custom_headers, HTTPClient.METHOD_GET)
	if error != OK:
		callback.call(false)
		return null
	return http_request

func _on_card_pack_download_complete(result, response_code, _body, callback, language_code):
	if result != OK or response_code != 200:
		print("ERROR: Result (%s) - %s" % [result, response_code])
		callback.call(false)
		return
	var download_dir = language_dir + "/" + language_code
	var download_file = download_dir + ".zip"
	# var file = FileAccess.open(download_file, FileAccess.WRITE)
	# file.store_buffer(body)
	# file.close()
	_unpack_zip_file(download_file, download_dir)

	# Write the updated details file.
	var details_file_path = download_dir + "/" + language_details_file
	var details_file = FileAccess.open(details_file_path, FileAccess.WRITE)
	details_file.store_line(JSON.stringify(SupportedLanguages[language_code]))
	details_file.close()

	callback.call(true)

func _unpack_zip_file(zip_file, destination_dir):
	var zip = ZIPReader.new()
	zip.open(zip_file)
	var files = zip.get_files()
	for file in files:
		var data = zip.read_file(file)
		var file_path = destination_dir + "/" + file
		var file_access = FileAccess.open(file_path, FileAccess.WRITE)
		file_access.store_buffer(data)
		file_access.close()
	zip.close()
