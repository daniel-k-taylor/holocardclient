extends Control

# Buttons
@onready var server_connect_button = $MainButtons/ServerConnectButton
@onready var join_queue_button = $MainButtons/JoinQueueButton
@onready var join_match_button = $MainButtons/JoinMatchButton
@onready var leave_queue_button = $MainButtons/LeaveQueueButton

# Labels
@onready var server_status = $ServerStatus/ServerStatusLabel

# Other
@onready var server_info_list : ItemList = $ServerInfoList

enum MenuState {
	MenuState_ConnectingToServer,
	MenuState_Connected_Default,
	MenuState_Disconnected,
}

var menu_state : MenuState = MenuState.MenuState_ConnectingToServer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_buttons()
	NetworkManager.connect("connected_to_server", _on_connected)
	NetworkManager.connect("disconnected_from_server", _on_disconnected)
	NetworkManager.connect("server_info", _on_server_info)
	
func _update_buttons() -> void:
	match menu_state:
		MenuState.MenuState_ConnectingToServer:
			server_connect_button.disabled = true
			server_connect_button.visible = false
			join_queue_button.disabled = true
			join_queue_button.visible = true
			join_match_button.disabled = true
			join_match_button.visible = false
			leave_queue_button.disabled = true
			leave_queue_button.visible = false
			server_status.text = "Connecting to server..."
		MenuState.MenuState_Connected_Default:
			server_connect_button.disabled = true
			server_connect_button.visible = false
			join_queue_button.disabled = false
			join_queue_button.visible = true
			join_match_button.disabled = true
			join_match_button.visible = false
			leave_queue_button.disabled = true
			leave_queue_button.visible = false
			server_status.text = "Connected"
		MenuState.MenuState_Disconnected:
			server_connect_button.disabled = false
			server_connect_button.visible = true
			join_queue_button.disabled = true
			join_queue_button.visible = false
			join_match_button.disabled = true
			join_match_button.visible = false
			leave_queue_button.disabled = true
			leave_queue_button.visible = false
			server_status.text = "Disconnected from server"
		_:
			assert(false, "Unimplemented menu state")
			pass

func returned_from_game():
	pass

func settings_loaded():
	pass
	
func _on_connected():
	menu_state = MenuState.MenuState_Connected_Default
	_update_buttons()

func _on_disconnected():
	menu_state = MenuState.MenuState_Disconnected
	_update_buttons()
	server_status.text = "Disconnected from server."

func _on_server_info(queue_info):
	server_info_list.clear()
	for queue in queue_info:
		var queue_str = "%s - %s" % [queue["queue_name"], queue["players_count"]]
		server_info_list.add_item(queue_str, null, false)
		
