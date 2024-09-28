extends Node

signal disconnected_from_server
signal connected_to_server
signal server_info(queue_info)
signal join_operation_failed()
signal game_event(event_type, event_data)

enum NetworkState {
	NetworkState_NotConnected,
	NetworkState_Connecting,
	NetworkState_Connected,
}

var _socket : WebSocketPeer = null
var network_state : NetworkState = NetworkState.NetworkState_NotConnected
var cached_server_info = {}

var connection_start_time = 0
var first_connection = false

const ServerMessageType_GameEvent = "game_event"
const ServerMessageType_Error = "error"
const ServerMessageType_ServerInfo = "server_info"

const ServerError_JoinInvalidDeck = "joinmatch_invaliddeck"
const ServerError_InvalidRoom = "invalid_room"

const ClientMessage_GameAction = "game_action"
const ClientMessage_LeaveGame = "leave_game"
const ClientMessage_LeaveMatchmakingQueue = "leave_matchmaking_queue"
const ClientMessage_JoinMatchmakingQueue = "join_matchmaking_queue"
const ClientMessage_JoinServer = "join_server"
const ClientMessage_ObserveRoom = "observe_room"
const ClientMessage_ObserverGetEvents = "observer_get_events"

func is_server_connected() -> bool:
	return _socket != null

func connect_to_server():
	if _socket != null: return
	first_connection = true
	_socket = WebSocketPeer.new()
	var server_url = GlobalSettings.get_server_url()
	_socket.connect_to_url(server_url)
	Logger.log(Logger.LogArea_Network, "Connecting to server...")
	network_state = NetworkState.NetworkState_Connecting
	connection_start_time = Time.get_unix_time_from_system()

func _process(_delta):
	_handle_sockets()

func _handle_sockets():
	if _socket:
		_socket.poll()
		var state = _socket.get_ready_state()
		match state:
			WebSocketPeer.STATE_OPEN:
				if network_state == NetworkState.NetworkState_Connecting:
					var end_time = Time.get_unix_time_from_system()
					var elapsed_time = end_time - connection_start_time
					Logger.log(Logger.LogArea_Network, "Connected to server: %s" % elapsed_time)
					# Send the join_server message.
					_send_join_server()
				network_state = NetworkState.NetworkState_Connected
				while _socket.get_available_packet_count():
					var packet = _socket.get_packet()
					if _socket.was_string_packet():
						var strpacket = packet.get_string_from_utf8()
						_handle_server_response(strpacket)
			WebSocketPeer.STATE_CLOSING:
				pass
			WebSocketPeer.STATE_CLOSED:
				disconnected_from_server.emit()
				network_state = NetworkState.NetworkState_NotConnected
				var code = _socket.get_close_code()
				var reason = _socket.get_close_reason()
				Logger.log(Logger.LogArea_Network, "WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
				_socket = null

func _handle_server_response(data):
	var parser = JSON.new()
	var result = parser.parse(data)
	if result != OK:
		Logger.log(Logger.LogArea_Network, "Error parsing JSON from server: %s" % data)
		return

	var data_obj = parser.get_data()
	var message_type = data_obj["message_type"]
	match message_type:
		ServerMessageType_ServerInfo:
			_handle_server_info(data_obj)
		ServerMessageType_Error:
			_handle_server_error(data_obj)
		ServerMessageType_GameEvent:
			_handle_game_event(data_obj)
		_:
			Logger.log(Logger.LogArea_Network, "Unhandled message type: %s" % message_type)

func _handle_server_info(message):
	cached_server_info = message
	if first_connection:
		Logger.log(Logger.LogArea_Network, "Connected to server!")
		connected_to_server.emit()
		first_connection = false
	server_info.emit()

func get_players_info():
	return cached_server_info["players_info"]

func get_queue_info():
	return cached_server_info["queue_info"]

func get_room_info():
	return cached_server_info["room_info"]

func get_my_player_id():
	return cached_server_info["your_id"]

func get_my_player_name():
	return cached_server_info["your_username"]

func _handle_server_error(message):
	Logger.log(Logger.LogArea_Network, "ERROR: %s - %s" % [message["error_id"], message["error_message"]])

	match message["error_id"]:
		ServerError_JoinInvalidDeck:
			join_operation_failed.emit(ServerError_JoinInvalidDeck)
		ServerError_InvalidRoom:
			join_operation_failed.emit(ServerError_InvalidRoom)
		_:
			# No special error handling.
			pass

func _handle_game_event(message):
	_handle_game_event_internal(message["event_data"])

func _handle_game_event_internal(event):
	var event_type = event["event_type"]
	#Logger.log(Logger.LogArea_Network, "Game event (%s): %s" % [event_type, message["event_data"]])
	game_event.emit(event_type, event)

func _send_join_server():
	var message = {
		"message_type": ClientMessage_JoinServer,
	}
	_send_message(message)

func _send_message(message):
	var json = JSON.stringify(message)
	if _socket:
		_socket.send_text(json)

### Commands ###

func join_match_queue(queue_name, oshi_id, deck, cheer_deck):
	var game_type = "versus"
	var custom_game = true
	for queue in get_queue_info():
		if queue["queue_name"] == queue_name:
			game_type = queue["game_type"]
			custom_game = queue["custom_game"]
	var message = {
		"message_type": ClientMessage_JoinMatchmakingQueue,
		"custom_game": custom_game,
		"queue_name": queue_name,
		"game_type": game_type,
		"oshi_id": oshi_id,
		"deck": deck,
		"cheer_deck": cheer_deck,
	}
	_send_message(message)


func leave_match_queue():
	var message = {
		"message_type": ClientMessage_LeaveMatchmakingQueue,
	}
	_send_message(message)

func leave_game():
	var message = {
		"message_type": ClientMessage_LeaveGame,
	}
	_send_message(message)

func send_game_message(action_type:String, action_data :Dictionary):
	var message = {
		"message_type": ClientMessage_GameAction,
		"action_type": action_type,
		"action_data": action_data,
	}
	Logger.log_net("Sending game message - %s: %s" % [action_type, message])
	_send_message(message)

func observe_room(room_index):
	var room_id = cached_server_info["room_info"][room_index]["room_id"]
	var message = {
		"message_type": ClientMessage_ObserveRoom,
		"room_id": room_id,
	}
	_send_message(message)

func observer_get_events(event_index):
	var message = {
		"message_type": ClientMessage_ObserverGetEvents,
		"next_event_index": event_index,
	}
	_send_message(message)
