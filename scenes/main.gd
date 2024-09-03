extends Node2D


const MainMenu = preload("res://scenes/menu/main_menu.gd")

@onready var main_menu : MainMenu = $MainMenu
var game : Node2D = null

const GameScene = preload("res://scenes/game/game.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSettings.load_persistent_settings()
	main_menu.settings_loaded()
	NetworkManager.connect("game_event", _on_game_event)
	NetworkManager.connect_to_server()

func _on_return_from_game():
	remove_child(game)
	game = null
	
	main_menu.visible = true
	main_menu.returned_from_game()

func _on_game_event(event_type:String, event_data:Dictionary):
	if event_type == Enums.EventType_GameStartInfo:
		# Start the game!
		game = GameScene.instantiate()
		add_child(game)
		game.connect("returning_from_game", _on_return_from_game)
		game.begin_remote_game(event_type, event_data)
	elif game:
		# Pass along events to the game.
		game.handle_game_event(event_type, event_data)
	else:
		Logger.log_menu("ERROR: Game event received but no game exists!")
