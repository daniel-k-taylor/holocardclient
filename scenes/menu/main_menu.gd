extends Control

const MatchmakingQueueName = "main_matchmaking_normal"
const AIQueueName = "main_matchmaking_ai"

var oshi_sora = "hSD01-001"
var oshi_azki = "hSD01-002"

# Buttons
@onready var play_ai_button = $MainButtons/PlayAIButton
@onready var server_connect_button = $MainButtons/ServerConnectButton
@onready var join_queue_button = $MainButtons/JoinQueueButton
@onready var join_match_button = $MainButtons/JoinMatchButton
@onready var leave_queue_button = $MainButtons/LeaveQueueButton
@onready var join_custom_box = $MainButtons/JoinCustomBox
@onready var deck_builder_button = $DeckBuilderButton
@onready var how_to_play_button = $HowToPlayButton

# Labels
@onready var server_status = $ServerStatus/ServerStatusLabel
@onready var client_version = $ClientVersion/ClientVersionLabel
@onready var player_username = $PlayerUsernameLabel
@onready var player_count_label = $PlayerCountLabel
@onready var match_count_label = $HBoxContainer/MatchCount

# Other
@onready var server_info_list : ItemList = $ServerInfoList
@onready var deck_selector = $DeckControls/HBoxContainer/DeckSelector
@onready var debug_deck_selector = $DebugDeckSelector
@onready var deck_controls = $DeckControls
@onready var modal_dialog = $ModalDialog
@onready var custom_room_entry = $MainButtons/JoinCustomBox/CustomRoomEditBox
@onready var supported_cards_list : ItemList = $SupportedCardsList
@onready var howtoplay = $HowToPlayButton
@onready var match_list = $MatchList
@onready var match_list_button = $HBoxContainer/ViewMatchListButton

@onready var deck_builder : DeckBuilder = $Deckbuilder

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
var seen_joinable_match = false
var queued_for_ai = false
var in_game = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$DebugSpewButton.visible = OS.is_debug_build()
	_update_buttons()
	NetworkManager.connect("connected_to_server", _on_connected)
	NetworkManager.connect("disconnected_from_server", _on_disconnected)
	NetworkManager.connect("server_info", _on_server_info)
	NetworkManager.connect("join_operation_failed", _on_join_failed)

	client_version.text = GlobalSettings.get_client_version()

	var supported_cards = CardDatabase.get_supported_cards()
	# Sort supported cards by alpha.
	supported_cards.sort()
	for card in supported_cards:
		supported_cards_list.add_item(card)

	if OS.is_debug_build():
		test_decks = CardDatabase.get_test_decks()
		debug_deck_selector.clear()
		for i in range(len(test_decks)):
			var deck = test_decks[i]
			debug_deck_selector.add_item(deck["deck_name"], i)
		debug_deck_selector.selected = -1
	else:
		debug_deck_selector.visible = false

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
			_update_element(deck_builder_button, true, true)
			_update_element(how_to_play_button, true, true)
			_update_element(match_list_button, false, true)
			server_status.text = "Connecting to server..."
		MenuState.MenuState_Connected_Default:
			_update_element(play_ai_button, true, true)
			_update_element(server_connect_button, false, false)
			_update_element(join_queue_button, not seen_joinable_match, not seen_joinable_match)
			_update_element(join_match_button, seen_joinable_match, seen_joinable_match)
			_update_element(leave_queue_button, false, false)
			_update_element(deck_controls, true, true)
			_update_element(join_custom_box, true, true)
			_update_element(deck_builder_button, true, true)
			_update_element(how_to_play_button, true, true)
			_update_element(match_list_button, true, true)
			server_status.text = "Connected"
		MenuState.MenuState_Disconnected:
			_update_element(play_ai_button, false, false)
			_update_element(server_connect_button, true, true)
			_update_element(join_queue_button, false, false)
			_update_element(join_match_button, false, false)
			_update_element(leave_queue_button, false, false)
			_update_element(deck_controls, true, true)
			_update_element(join_custom_box, false, false)
			_update_element(deck_builder_button, true, true)
			_update_element(how_to_play_button, true, true)
			_update_element(match_list_button, false, true)
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
			_update_element(deck_builder_button, false, false)
			_update_element(how_to_play_button, false, false)
			_update_element(match_list_button, false, true)
		_:
			assert(false, "Unimplemented menu state")
			pass

func returned_from_game():
	in_game = false
	seen_joinable_match = false
	if NetworkManager.is_server_connected():
		menu_state = MenuState.MenuState_Connected_Default
		_update_server_info()
	else:
		menu_state = MenuState.MenuState_Disconnected
	_update_buttons()

func starting_game():
	in_game = true
	if menu_state == MenuState.MenuState_Queued and not queued_for_ai:
		if GlobalSettings.get_user_setting(GlobalSettings.GameSound):
			$MatchJoinedSound.play()

func settings_loaded():
	deck_builder.load_decks()
	load_user_decks()

func load_user_decks():
	var decks = deck_builder.get_decks()
	deck_selector.clear()
	for i in range(len(decks)):
		var deck = decks[i]
		deck_selector.add_item(deck["deck_name"], i)
	deck_selector.selected = deck_builder.get_current_deck_index()
	loaded_deck = decks[deck_selector.selected]
	deck_selector.text = loaded_deck["deck_name"]

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
	var players_info = NetworkManager.get_players_info()
	player_count_label.text = str(players_info.size())
	for player in players_info:
		var player_name = player["username"]
		var queue = player["queue"]
		var game_room = player["game_room"]
		if queue:
			game_room = ""
		else:
			if game_room == "Lobby":
				queue = "in"
			elif game_room == "AI":
				queue = "playing"
			elif game_room.begins_with("Match_"):
				if player["observing"]:
					queue = "watching"
				else:
					queue = "in"
				game_room = "Match"
			else:
				queue = ""
				if player["observing"]:
					queue = "watching"
		

		server_info_list.add_item(player_name, null, false)
		server_info_list.add_item(queue, null, false)
		server_info_list.add_item(game_room, null, false)

	for queue in NetworkManager.get_queue_info():
		match_queues.append(queue)

	# Check if a match is joinable.
	var joinable_match = false
	for queue in match_queues:
		if queue["queue_name"] == MatchmakingQueueName:
			joinable_match = queue["players_count"] > 0
	if joinable_match and not seen_joinable_match:
		seen_joinable_match = true
		if not in_game and GlobalSettings.get_user_setting(GlobalSettings.GameSound):
			$MatchAvailableSound.play()
	if not joinable_match:
		seen_joinable_match = false

	var match_info = get_match_list_info()
	match_count_label.text = str(len(match_info))
	match_list.update_match_list(match_info)

	_update_buttons()

func _on_server_info():
	server_info_list.clear()
	player_count_label.text = ""
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
	queued_for_ai = false
	seen_joinable_match = true
	_update_buttons()
	join_match_queue(MatchmakingQueueName)

func _on_join_custom_button_pressed() -> void:
	queued_for_ai = false
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
	seen_joinable_match = false
	_update_server_info()
	_update_buttons()

func _on_leave_queue_button_pressed() -> void:
	queued_for_ai = false
	menu_state = MenuState.MenuState_Connected_Default
	_update_buttons()
	NetworkManager.leave_match_queue()

func _on_debug_spew_button_toggled(toggled_on: bool) -> void:
	GlobalSettings.toggle_logging(toggled_on)

func _on_play_ai_button_pressed() -> void:
	queued_for_ai = true
	menu_state = MenuState.MenuState_Queued
	_update_buttons()
	join_match_queue(AIQueueName)

func _on_settings_button_pressed() -> void:
	$SettingsWindow.show_settings()

func _on_deck_selector_item_selected(index: int) -> void:
	deck_builder.set_deck_index(index)
	loaded_deck = deck_builder.get_decks()[index]

func _on_debug_deck_selector_item_selected(index: int) -> void:
	loaded_deck = test_decks[index]

func _on_how_to_play_button_pressed() -> void:
	howtoplay.show_help()

func _on_deck_builder_button_pressed() -> void:
	deck_builder.show_deck_builder(deck_selector.selected)

func _on_deckbuilder_exit_deck_builder() -> void:
	load_user_decks()

func get_match_list_info():
	var match_list_info = []
	for info in NetworkManager.cached_server_info["room_info"]:
		var room :String = info["room_name"]
		if room.begins_with("Match"):
			room = "Match"
		elif room.begins_with("Custom"):
			room = room.replace("Custom_", "")
		match_list_info.append({
			"room_name": room,
			"player1": info["players"][0]["username"],
			"player2": info["players"][1]["username"],
		})
	return match_list_info

func _on_view_match_list_button_pressed() -> void:
	match_list.visible = true

func _on_match_list_observe_match(match_index: Variant) -> void:
	queued_for_ai = true
	menu_state = MenuState.MenuState_Queued
	_update_buttons()
	NetworkManager.observe_room(match_index)
