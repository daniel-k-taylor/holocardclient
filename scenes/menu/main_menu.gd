extends Control

var oshi_sora = "hSD01-001"
var oshi_azki = "hSD01-002"

### Web-specific variables
var window
var file_load_callback
###

# Buttons
@onready var play_ai_button = $MainButtons/PlayAIButton
@onready var server_connect_button = $MainButtons/ServerConnectButton
@onready var join_queue_button = $MainButtons/JoinQueueButton
@onready var join_match_button = $MainButtons/JoinMatchButton
@onready var leave_queue_button = $MainButtons/LeaveQueueButton
@onready var join_custom_box = $MainButtons/JoinCustomBox

# Labels
@onready var server_status = $ServerStatus/ServerStatusLabel
@onready var client_version = $ClientVersion/ClientVersionLabel
@onready var player_username = $PlayerUsernameLabel
@onready var custom_deck_label = $CustomDeckLabel

# Other
@onready var server_info_list : ItemList = $ServerInfoList
@onready var deck_selector = $DeckControls/HBoxContainer/DeckSelector
@onready var deck_controls = $DeckControls
@onready var save_file_dialog = $SaveFileDialog
@onready var open_file_dialog = $OpenFileDialog
@onready var modal_dialog = $ModalDialog
@onready var custom_room_entry = $MainButtons/JoinCustomBox/CustomRoomEditBox

enum MenuState {
	MenuState_ConnectingToServer,
	MenuState_Connected_Default,
	MenuState_Disconnected,
	MenuState_Queued,
}

var menu_state : MenuState = MenuState.MenuState_ConnectingToServer

var match_queues : Array = []
var loaded_deck
var test_decks = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$DebugSpewButton.visible = OS.is_debug_build()
	_update_buttons()
	NetworkManager.connect("connected_to_server", _on_connected)
	NetworkManager.connect("disconnected_from_server", _on_disconnected)
	NetworkManager.connect("server_info", _on_server_info)
	NetworkManager.connect("join_operation_failed", _on_join_failed)

	client_version.text = GlobalSettings.get_client_version()

	save_file_dialog.visible = false
	open_file_dialog.visible = false
	custom_deck_label.visible = false

	test_decks = CardDatabase.get_test_decks()
	deck_selector.clear()
	for i in range(len(test_decks)):
		var deck = test_decks[i]
		deck_selector.add_item(deck["deck_name"], i)
	deck_selector.selected = 0
	loaded_deck = test_decks[0]

	if OS.has_feature("web"):
		#setupFileLoad defined in the HTML5 export header
		#calls load_deck when file gets user-selected by window.input.click()
		window = JavaScriptBridge.get_interface("window")
		file_load_callback = JavaScriptBridge.create_callback(load_deck)
		window.setupFileLoad(file_load_callback)

func _update_element(button, enabled_value, visibility_value):
	if button is Button:
		button.disabled = not enabled_value
	button.visible = visibility_value

func _update_buttons() -> void:
	match menu_state:
		MenuState.MenuState_ConnectingToServer:
			_update_element(play_ai_button, false, true)
			_update_element(server_connect_button, false, false)
			_update_element(join_queue_button, false, true)
			_update_element(join_match_button, false, false)
			_update_element(leave_queue_button, false, false)
			_update_element(deck_controls, true, true)
			_update_element(join_custom_box, false, false)
			server_status.text = "Connecting to server..."
		MenuState.MenuState_Connected_Default:
			_update_element(play_ai_button, true, true)
			_update_element(server_connect_button, false, false)
			_update_element(join_queue_button, true, true)
			_update_element(join_match_button, false, false)
			_update_element(leave_queue_button, false, false)
			_update_element(deck_controls, true, true)
			_update_element(join_custom_box, true, true)
			server_status.text = "Connected"
		MenuState.MenuState_Disconnected:
			_update_element(play_ai_button, false, false)
			_update_element(server_connect_button, true, true)
			_update_element(join_queue_button, false, false)
			_update_element(join_match_button, false, false)
			_update_element(leave_queue_button, false, false)
			_update_element(deck_controls, true, true)
			_update_element(join_custom_box, false, false)
			server_status.text = "Disconnected from server"
			player_username.text = "Player Name"
		MenuState.MenuState_Queued:
			_update_element(play_ai_button, false, false)
			_update_element(server_connect_button, false, false)
			_update_element(join_queue_button, false, false)
			_update_element(join_match_button, false, false)
			_update_element(leave_queue_button, true, true)
			_update_element(deck_controls, false, false)
			_update_element(join_custom_box, false, false)
		_:
			assert(false, "Unimplemented menu state")
			pass

func returned_from_game():
	if NetworkManager.is_server_connected():
		menu_state = MenuState.MenuState_Connected_Default
		_update_server_info()
	else:
		menu_state = MenuState.MenuState_Disconnected
	_update_buttons()

func settings_loaded():
	pass

func _on_connected():
	menu_state = MenuState.MenuState_Connected_Default
	_update_buttons()

func _on_disconnected():
	menu_state = MenuState.MenuState_Disconnected
	_update_buttons()
	server_info_list.clear()
	server_status.text = "Disconnected from server."

func _update_server_info():
	server_info_list.clear()

	player_username.text = NetworkManager.get_my_player_name()

	match_queues = []
	for player in NetworkManager.get_players_info():
		var player_name = player["username"]
		var queue = player["queue"]
		var game_room = player["game_room"]
		if queue:
			game_room = ""
		if game_room.begins_with("Match_"):
			queue = "in"
			game_room = "Match"
		if game_room == "AI":
			queue = "playing"

		server_info_list.add_item(player_name, null, false)
		server_info_list.add_item(queue, null, false)
		server_info_list.add_item(game_room, null, false)

	for queue in NetworkManager.get_queue_info():
		match_queues.append(queue)

func _on_server_info():
	server_info_list.clear()
	_update_server_info()

func _on_server_connect_button_pressed() -> void:
	menu_state = MenuState.MenuState_ConnectingToServer
	_update_buttons()
	NetworkManager.connect_to_server()

func get_player_oshi():
	return loaded_deck["oshi"]

func get_player_deck():
	return loaded_deck["deck"]

func get_player_cheer_deck():
	return loaded_deck["cheer_deck"]

func _on_join_queue_button_pressed() -> void:
	menu_state = MenuState.MenuState_Queued
	_update_buttons()
	join_match_queue("main_matchmaking_normal")

func _on_join_custom_button_pressed() -> void:
	var desired_room : String = custom_room_entry.text
	desired_room = desired_room.strip_edges(true, true)
	if desired_room:
		menu_state = MenuState.MenuState_Queued
		_update_buttons()
		join_match_queue(desired_room)


func join_match_queue(queue_name):
	NetworkManager.join_match_queue(queue_name, get_player_oshi(), get_player_deck(), get_player_cheer_deck())

func _on_join_failed(error_id) -> void:
	match error_id:
		NetworkManager.ServerError_JoinInvalidDeck:
			modal_dialog.set_text_fields("Invalid deck", "OK", "")
		_:
			modal_dialog.set_text_fields("Join failed", "OK", "")
	menu_state = MenuState.MenuState_Connected_Default
	_update_buttons()

func _on_leave_queue_button_pressed() -> void:
	menu_state = MenuState.MenuState_Connected_Default
	_update_buttons()
	NetworkManager.leave_match_queue()

func _on_debug_spew_button_toggled(toggled_on: bool) -> void:
	GlobalSettings.toggle_logging(toggled_on)

func _on_play_ai_button_pressed() -> void:
	menu_state = MenuState.MenuState_Queued
	_update_buttons()
	join_match_queue("main_matchmaking_ai")


func _on_load_deck_button_pressed():
	if OS.has_feature("web"):
		window.input.click()
	else:
		open_file_dialog.visible = true

func _on_save_deck_button_pressed():
	if OS.has_feature("web"):
		window = JavaScriptBridge.get_interface("window")
		var file_name = "%s.json" % loaded_deck["deck_name"]
		var file_content = JSON.stringify(loaded_deck)
		window.saveTextToFile(file_name, file_content)
	else:
		save_file_dialog.visible = true

func load_deck(data):
	var json = JSON.new()
	if json.parse(data[0]) == OK:
		if "oshi" not in json.data or typeof(json.data["oshi"]) != TYPE_STRING:
			modal_dialog.set_text_fields("Invalid format:\nInvalid oshi", "OK", "")
			return
		if "deck" not in json.data or typeof(json.data["deck"]) != TYPE_DICTIONARY:
			modal_dialog.set_text_fields("Invalid format:\nInvalid deck", "OK", "")
			return
		if "cheer_deck" not in json.data or typeof(json.data["cheer_deck"]) != TYPE_DICTIONARY:
			modal_dialog.set_text_fields("Invalid format:\nInvalid cheer deck", "OK", "")
			return
		for deck_key in json.data["deck"]:
			if typeof(deck_key) != TYPE_STRING:
				modal_dialog.set_text_fields("Invalid format:\nDeck keys not all strings", "OK", "")
				return
			if typeof(json.data["deck"][deck_key]) != TYPE_FLOAT:
				modal_dialog.set_text_fields("Invalid format:\nDeck counts not numbers", "OK", "")
				return
		for cheer_key in json.data["cheer_deck"]:
			if typeof(cheer_key) != TYPE_STRING:
				modal_dialog.set_text_fields("Invalid format:\nCheer Deck keys not all strings", "OK", "")
				return
			if typeof(json.data["cheer_deck"][cheer_key]) != TYPE_FLOAT:
				modal_dialog.set_text_fields("Invalid format:\nCheer Deck counts not numbers", "OK", "")
				return
		var new_deck = {
			"oshi": json.data["oshi"],
			"deck": {},
			"cheer_deck": {},
		}
		for deck_key in json.data["deck"]:
			new_deck["deck"][deck_key] = int(json.data["deck"][deck_key])
		for cheer_key in json.data["cheer_deck"]:
			new_deck["cheer_deck"][cheer_key] = int(json.data["cheer_deck"][cheer_key])
		_on_deck_loaded(new_deck)
	else:
		var error_message = "JSON Parse Error: " + json.get_error_message()
		modal_dialog.set_text_fields(error_message, "OK", "")

func _on_deck_loaded(new_deck):
	loaded_deck = new_deck
	custom_deck_label.visible = true

func _on_save_file_dialog_file_selected(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	var content = JSON.stringify(loaded_deck)
	file.store_string(content)

func _on_open_file_dialog_file_selected(path: String) -> void:
	load_deck([FileAccess.get_file_as_string(path)])

func _on_settings_button_pressed() -> void:
	$SettingsWindow.show_settings()


func _on_deck_selector_item_selected(index: int) -> void:
	loaded_deck = test_decks[index]
	custom_deck_label.visible = false
