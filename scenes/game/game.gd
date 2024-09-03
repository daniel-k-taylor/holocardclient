extends Node2D

signal returning_from_game

const CardZone = preload("res://scenes/game/card_zone.gd")

@onready var message_box = $MessageHistory

@onready var opponent_hand_label = $OpponentStatsGroup/HandIndicator/HandCount
@onready var opponent_deck_label = $OpponentStatsGroup/DeckIndicator/DeckCount
@onready var opponent_cheer_label = $OpponentStatsGroup/CheerIndicator/CheerCount
@onready var opponent_life_label = $OpponentStatsGroup/LifeIndicator/LifeCount
@onready var opponent_archive_label = $OpponentStatsGroup/ArchiveIndicator/ArchiveCount
@onready var opponent_holopower_label = $OpponentStatsGroup/HolopowerIndicator/HolopowerCount

@onready var opponent_center : CardZone = $OpponentCenter
@onready var opponent_collab : CardZone = $OpponentCollab
@onready var opponent_backstage : CardZone = $OpponentBackstage
@onready var opponent_oshi : CardZone = $OpponentOshi

@onready var me_center : CardZone = $MeCenter
@onready var me_collab : CardZone = $MeCollab
@onready var me_backstage : CardZone = $MeBackstage
@onready var me_oshi : CardZone = $MeOshi
@onready var me_hand : CardZone = $MeHand

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NetworkManager.connect("disconnected_from_server", _on_disconnected)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func begin_remote_game(event_type, event_data):
	Logger.log_game("Starting game!")
	handle_game_event(event_type, event_data)
	
func handle_game_event(event_type, event_data):
	Logger.log_game("Received game event: %s" % event_type)
	_append_to_messages(event_type)
	
	match event_type:
		Enums.EventType_AddTurnEffect:
			pass
		Enums.EventType_Bloom:
			pass
		Enums.EventType_BoostStat:
			pass
		Enums.EventType_CheerStep:
			pass
		Enums.EventType_Choice_SendCollabBack:
			pass
		Enums.EventType_Collab:
			pass
		Enums.EventType_Decision_ChooseCards:
			pass
		Enums.EventType_Decision_MainStep:
			pass
		Enums.EventType_Decision_MoveCheerChoice:
			pass
		Enums.EventType_Decision_OrderCards:
			pass
		Enums.EventType_Decision_PerformanceStep:
			pass
		Enums.EventType_Decision_SendCheer:
			pass
		Enums.EventType_Decision_SwapHolomemToCenter:
			pass
		Enums.EventType_Draw:
			_on_draw_event(event_data)
		Enums.EventType_EndTurn:
			pass
		Enums.EventType_ForceDieResult:
			pass
		Enums.EventType_GameError:
			pass
		Enums.EventType_GameOver:
			pass
		Enums.EventType_GameStartInfo:
			_begin_game(event_data)
		Enums.EventType_InitialPlacementBegin:
			_on_initial_placement_begin(event_data)
		Enums.EventType_InitialPlacementPlaced:
			pass
		Enums.EventType_InitialPlacementReveal:
			pass
		Enums.EventType_MainStepStart:
			pass
		Enums.EventType_MoveCard:
			pass
		Enums.EventType_MoveCheer:
			pass
		Enums.EventType_MulliganDecision:
			_on_mulligan_decision_event(event_data)
		Enums.EventType_MulliganReveal:
			pass
		Enums.EventType_OshiSkillActivation:
			pass
		Enums.EventType_PerformanceStepStart:
			pass
		Enums.EventType_PerformArt:
			pass
		Enums.EventType_PlaySupportCard:
			pass
		Enums.EventType_ResetStepActivate:
			pass
		Enums.EventType_ResetStepChooseNewCenter:
			pass
		Enums.EventType_ResetStepCollab:
			pass
		Enums.EventType_RollDie:
			pass
		Enums.EventType_ShuffleDeck:
			pass
		Enums.EventType_TurnStart:
			pass
		_:
			Logger.log_game("Unknown event type: %s" % event_type)
			assert(false)
			
	_update_ui()

func _on_exit_game_button_pressed() -> void:
	NetworkManager.leave_game()
	returning_from_game.emit()

func _on_disconnected():
	_append_to_messages("disconnected")

func _append_to_messages(message):
	message_box.text += "\n" + message

var starting_player_id : String
var all_cards_map

func _get_card_definition_id(card_id):
	for key in all_cards_map:
		if key == card_id:
			return all_cards_map[key]
	return null

class PlayerState:
	var _player_id : String
	var _is_me : bool
	var _game
	
	var hand_count = 0
	var deck_count = Enums.DECK_SIZE
	var life_count = 0
	var cheer_count = Enums.CHEER_SIZE
	var holopower_count = 0
	
	var hand : Array = []
	var archive : Array = []
	var collab : Array = []
	var center : Array = []
	var backstage : Array = []
	var oshi = null
	
	var _hand_zone : CardZone
	var _center_zone : CardZone
	var _collab_zone : CardZone
	var _backstage_zone : CardZone
	var _oshi_zone : CardZone

	func _init(game, player_id:String, is_local_player : bool, backstage_zone, collab_zone, center_zone, oshi_zone, hand_zone):
		_game = game
		_player_id = player_id
		_is_me = is_local_player
		
		_hand_zone = hand_zone
		_center_zone = center_zone
		_collab_zone = collab_zone
		_backstage_zone = backstage_zone
		_oshi_zone = oshi_zone

	func is_me() -> bool:
		return _is_me
		
	func draw_cards(card_ids : Array):
		hand_count += len(card_ids)
		deck_count -= len(card_ids)

		for card_id in card_ids:
			var definition_id = _game._get_card_definition_id(card_id)
			if _hand_zone:
				_hand_zone.add_card(definition_id)

var me : PlayerState
var opponent : PlayerState

func _update_ui():
	opponent_archive_label.text = "%s" % opponent.archive.size()
	opponent_hand_label.text = "%s" % opponent.hand_count
	opponent_holopower_label.text = "%s" % opponent.holopower_count
	opponent_deck_label.text = "%s" % opponent.deck_count
	opponent_life_label.text = "%s" % opponent.life_count
	opponent_cheer_label.text = "%s" % opponent.cheer_count

func _begin_game(event_data):
	starting_player_id = event_data["starting_player"]
	var my_id = event_data["your_id"]
	var opponent_id = event_data["opponent_id"]
	all_cards_map = event_data["game_card_map"]
	
	me = PlayerState.new(self, my_id, true, me_backstage, me_collab, me_center, me_oshi, me_hand)
	opponent = PlayerState.new(self, opponent_id, false, opponent_backstage, opponent_collab, opponent_center, opponent_oshi, null)

func get_player(player_id:String):
	if player_id == me._player_id:
		return me
	return opponent

func _on_draw_event(event_data):
	var drawn_card_ids = event_data["drawn_card_ids"]
	var active_player = get_player(event_data["drawing_player_id"])
	active_player.draw_cards(drawn_card_ids)

func _on_initial_placement_begin(event_data):
	var active_player = get_player(event_data["active_player"])
	if active_player.is_me():
		# TODO: Enable choice
		for card_id in active_player.hand:
			var definition_id = _get_card_definition_id(card_id)
			
		pass
	else: # Opponent
		# Do nothing.
		pass

func _on_mulligan_decision_event(event_data):
	var active_player = get_player(event_data["active_player"])
	if active_player.is_me():
		# TODO: Mulligan yes/no.
		submit_mulligan_choice(false)
	else: # Opponent
		# Do nothing.
		pass


#
# Submit to server funcs
#

func submit_mulligan_choice(do_it : bool):
	var action = {
		"do_mulligan": do_it
	}
	NetworkManager.send_game_message(Enums.GameAction_Mulligan, action)
