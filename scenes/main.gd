extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSettings.load_persistent_settings()
	$MainMenu.settings_loaded()
	NetworkManager.connect_to_server()

func _on_return_from_game():
	$MainMenu.visible = true
	$MainMenu.returned_from_game()
