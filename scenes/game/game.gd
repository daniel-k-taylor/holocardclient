extends Node2D

signal returning_from_game

@onready var message_box = $MessageHistory

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func begin_remote_game(_event_data):
	Logger.log_game("Starting game!")
	
func handle_game_event(event_type, _event_data):
	Logger.log_game("Received game event: %s" % event_type)
	_append_to_messages(event_type)

func _on_exit_game_button_pressed() -> void:
	NetworkManager.leave_game()
	returning_from_game.emit()

func _append_to_messages(message):
	message_box.text += "\n" + message
