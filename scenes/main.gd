extends Node2D


const MainMenu = preload("res://scenes/menu/main_menu.gd")

@onready var main_menu : MainMenu = $MainMenu
@onready var login_screen = $Login
var game : Node2D = null

const GameScene = preload("res://scenes/game/game.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSettings.load_persistent_settings()
	main_menu.settings_loaded()
	NetworkManager.connect("game_event", _on_game_event)
	NetworkManager.connect_to_server()


	# TODO: Enable playfab login
	#main_menu.visible = false
	#Playfab.connect("login_error", _on_playfab_login_error)
	#Playfab.connect("login_success", _on_playfab_login_success)
	#login_screen.show_login(true)
	#Playfab.begin_auto_login()

func _on_playfab_login_error(err):
	login_screen.show_login(false, err)

func _on_playfab_login_success():
	login_screen.visible = false
	main_menu.visible = true

func _on_return_from_game():
	remove_child(game)
	game = null

	main_menu.visible = true
	main_menu.returned_from_game()

func _on_game_event(event_type:String, event_data:Dictionary):
	if event_type == Enums.EventType_GameStartInfo:
		# Start the game!
		main_menu.starting_game()
		game = GameScene.instantiate()
		add_child(game)
		game.connect("returning_from_game", _on_return_from_game)
		game.begin_remote_game(event_type, event_data)
	elif game:
		# Pass along events to the game.
		game.handle_game_event(event_type, event_data)
	else:
		Logger.log_menu("ERROR: Game event received but no game exists!")
