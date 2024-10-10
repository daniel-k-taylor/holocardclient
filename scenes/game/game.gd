class_name Game
extends Node2D

### Web-specific variables
var window
###

signal returning_from_game

const CardBaseScene = preload("res://scenes/game/card_base.tscn")
const PopupMessageScene = preload("res://scenes/game/popup_message.tscn")

@onready var action_menu : ActionMenu = $UIOverlay/VBoxContainer/HBoxContainer/ActionMenu
@onready var all_cards : Node2D = $AllCards

@onready var thinking_spinner : TextureProgressBar = $ThinkingSpinner

@onready var opponent_stats : StatsGroup = $OpponentStatsGroup
@onready var me_stats : StatsGroup = $MeStatsGroup

@onready var opponent_username_label = $OpponentUsernameLabel
@onready var me_username_label = $MeUsernameLabel
@onready var opponent_clock = $OpponentClock
@onready var me_clock = $MeClock

@onready var opponent_hand_label = $OpponentStatsGroup/HandIndicator/HandCount
@onready var opponent_deck_label = $OpponentStatsGroup/DeckIndicator/DeckCount
@onready var opponent_cheer_label = $OpponentStatsGroup/CheerIndicator/CheerCount
@onready var opponent_life_label = $OpponentStatsGroup/LifeIndicator/LifeCount
@onready var opponent_archive_label = $OpponentStatsGroup/ArchiveIndicator/ArchiveCount
@onready var opponent_holopower_label = $OpponentStatsGroup/HolopowerIndicator/HolopowerCount

@onready var opponent_archive : CardZone = $OpponentArchive
@onready var opponent_center : CardZone = $OpponentCenter
@onready var opponent_collab : CardZone = $OpponentCollab
@onready var opponent_backstage : CardZone = $OpponentBackstage
@onready var opponent_oshi : CardZone = $OpponentOshi
@onready var opponent_hand = $OpponentHand
@onready var opponent_deck_spawn = $OpponentDeckSpawn
@onready var opponent_hand_indicator = $OpponentHandIndicator/HandCount

@onready var floating_zone : CardZone = $FloatingCardZone

@onready var me_archive: CardZone = $MeArchive
@onready var me_center : CardZone = $MeCenter
@onready var me_collab : CardZone = $MeCollab
@onready var me_backstage : CardZone = $MeBackstage
@onready var me_oshi : CardZone = $MeOshi
@onready var me_hand : CardZone = $MeHand
@onready var me_deck_spawn = $MeDeckSpawn
@onready var me_hand_indicator = $MeHandIndicator/HandCount

@onready var card_popout : CardPopout = $CardPopout
@onready var archive_card_popout : CardPopout = $ArchiveCardPopout
@onready var game_log : GameLog = $GameLog
@onready var game_over_text = $UIOverlay/VBoxContainer/GameOverContainer/CenterContainer/GameOverText

@onready var save_file_dialog = $SaveFileDialog

@onready var big_card = $BigCard
@onready var settings_window = $SettingsWindow

@onready var turnstart_audio : AudioStreamPlayer2D = $TurnStartAudio

enum UIPhase {
	UIPhase_Init,
	UIPhase_MakeChoiceCanSelectCards,
	UIPhase_ClickCardsForAction,
	UIPhase_MainStepAction,
	UIPhase_WaitingOnServer,
}

class PlayerState:
	var _player_id : String
	var _is_me : bool
	var _game
	var _username : String
	var _observer_mode : bool

	var hand_count = 0
	var deck_count = Enums.DECK_SIZE
	var life_count = 0
	var cheer_count = Enums.CHEER_SIZE
	var holopower_count = 0
	var played_limited_this_turn = false
	var used_oshi_turn_skill = false
	var used_oshi_game_skill = false

	var _archive_zone : CardZone
	var _backstage_zone : CardZone
	var _center_zone : CardZone
	var _collab_zone : CardZone
	var _hand_zone : CardZone
	var _oshi_zone : CardZone
	var _floating_zone : CardZone
	var _deck_spawn_zone
	var _hand_indicator : Label

	var stage_zones = []

	func _init(game, player_id:String, is_local_player : bool, username : String,
		archive_zone, backstage_zone, collab_zone,
		center_zone, oshi_zone, hand_zone, hand_indicator,
		floating_zone, deck_spawn_zone
	):
		_game = game
		_observer_mode = _game.observer_mode
		_player_id = player_id
		_is_me = is_local_player
		_username = username

		_archive_zone = archive_zone
		_hand_zone = hand_zone
		_center_zone = center_zone
		_collab_zone = collab_zone
		_backstage_zone = backstage_zone
		_oshi_zone = oshi_zone
		_floating_zone = floating_zone
		_deck_spawn_zone = deck_spawn_zone
		_hand_indicator = hand_indicator

		stage_zones = [center_zone, collab_zone, backstage_zone]

	func is_me() -> bool:
		return _is_me

	func get_name() -> String:
		return _username

	func get_name_decorated() -> String:
		var color = GameLog.DEFAULT_PLAYER_COLOR
		if not is_me():
			color = GameLog.DEFAULT_OPPONENT_COLOR
		return "[color=%s]%s[/color]" % [color, _username]

	func clear_played_this_turn():
		played_limited_this_turn = false
		used_oshi_turn_skill = false

	func draw_cards(count, cards : Array):
		hand_count += count
		deck_count -= count

		if _hand_zone and is_me() and not _observer_mode:
			for card in cards:
				_hand_zone.add_card(card)
			_game._put_cards_on_top(_hand_zone.cards)
		else:
			for card in cards:
				card.begin_move_to(get_card_spawn_location(), true)
				card.begin_move_to(get_hand_placeholder_location(), false, true)

	func get_card_spawn_location() -> Vector2:
		return _deck_spawn_zone.global_position + (CardBase.DefaultCardScale * CardBase.DefaultCardSize * 0.5)

	func get_holopower_spawn_location() -> Vector2:
		return _oshi_zone.global_position + (CardBase.DefaultCardScale * CardBase.DefaultCardSize * 0.5)

	func get_life_spawn_location() -> Vector2:
		return _oshi_zone.global_position + (CardBase.DefaultCardScale * CardBase.DefaultCardSize * 0.5)

	func get_cheer_deck_spawn_location() -> Vector2:
		return _oshi_zone.global_position + (CardBase.DefaultCardScale * CardBase.DefaultCardSize * 0.5)

	func get_hand_placeholder_location() -> Vector2:
		return _hand_zone.global_position

	func get_archive_count() -> int:
		return len(_archive_zone.get_cards_in_zone())

	func get_hand_count() -> int:
		return hand_count

	func remove_from_archive(card_id : String):
		_archive_zone.remove_card(card_id)

	func add_card_to_archive(card:CardBase):
		card.clear_attached()
		_archive_zone.add_card(card, 0)
		_game._put_cards_on_top([card])

	func add_card_to_hand(card : CardBase):
		hand_count += 1
		if is_me() and not _observer_mode:
			_hand_zone.add_card(card)
			_game._put_cards_on_top(_hand_zone.cards)
		else:
			card.begin_move_to(get_hand_placeholder_location(), false, true)

	func remove_from_hand(card_id : String):
		hand_count -= 1
		_hand_zone.remove_card(card_id)

	func get_card_ids_in_hand(card_types: Array):
		assert(is_me(), "Only the local player can get their hand")
		var matched_ids = []
		for card in _hand_zone.get_cards_in_zone():
			var card_data = CardDatabase.get_card(card._definition_id)
			if card_data["card_type"] in card_types:
				matched_ids.append(card._card_id)
		return matched_ids

	func add_card_to_deck(card : CardBase):
		deck_count += 1
		if card:
			card.begin_move_to(get_card_spawn_location(), false, true)

	func remove_card_from_deck(_card_id : String):
		deck_count -= 1

	func add_card_to_cheer_deck(card : CardBase):
		cheer_count += 1
		if card:
			card.begin_move_to(get_cheer_deck_spawn_location(), false, true)

	func remove_card_from_cheer_deck(_card_id : String):
		cheer_count -= 1

	func are_cards_in_zone_visible(to_zone : String):
		if to_zone in ["archive", "backstage", "center", "collab", "floating", "oshi"]:
			return true
		if to_zone == "hand" and is_me() and not _observer_mode:
			return true
		return false

	func add_backstage(card : CardBase):
		_backstage_zone.add_card(card)
		order_backstage()

	func order_backstage():
		for back_card in _backstage_zone.get_cards_in_zone():
			# Always order them near the front because they can't show over the hand cards.
			_game.all_cards.move_child(back_card, 0)

	func remove_backstage(card_id : String):
		_backstage_zone.remove_card(card_id)

	func add_center(card : CardBase):
		_center_zone.add_card(card)

	func remove_center(card_id : String):
		_center_zone.remove_card(card_id)

	func add_collab(card : CardBase):
		_collab_zone.add_card(card)

	func remove_collab(card_id : String):
		_collab_zone.remove_card(card_id)

	func add_floating(card : CardBase):
		_floating_zone.add_card(card)

	func remove_floating(card_id : String):
		_floating_zone.remove_card(card_id)

	func replace_card_on_stage(target_card_id, new_card):
		for zone in stage_zones:
			var index = zone.remove_card(target_card_id)
			if index != -1:
				zone.add_card(new_card, index)
				break

	func bloom(bloom_card_id, target_card_id, from_zone):
		if from_zone == "hand":
			remove_from_hand(bloom_card_id)
		else:
			assert(false, "Unimplemented")

		# The bloom card will always show up, so find/create it.
		var bloom_card = _game.find_card_on_board(bloom_card_id)
		if not bloom_card:
			assert(not is_me() or _observer_mode)
			bloom_card = _game.create_card(bloom_card_id)
			var spawn_at = get_hand_placeholder_location()
			bloom_card.begin_move_to(spawn_at, true)

		# Figure out where the target card is and replace it.
		replace_card_on_stage(target_card_id, bloom_card)

		# TODO: Somehow attach the target card to the bloom card.
		# The target card is no longer need so delete it.
		var target_card = _game.find_card_on_board(target_card_id)
		assert(target_card)
		# Copy the damage/resting states from the target card.
		# TODO: Attach the target card to the bloom card for viewing? Maybe a little flower icon that shows a popout?
		bloom_card.add_damage(target_card.damage, false)
		bloom_card.set_resting(target_card._resting, true)
		var attached_card_ids = target_card.get_attached()
		for attached_card_id in attached_card_ids:
			bloom_card.attach_card(attached_card_id)
		target_card.clear_attached()
		var cheer_map = target_card.remove_all_attached_cheer()
		for cheer_id in cheer_map:
			bloom_card.attach_cheer(cheer_id, cheer_map[cheer_id])

		bloom_card.attach_card(target_card._card_id)
		_game.destroy_card(target_card)
		order_backstage()

	func generate_holopower(holopower_generated):
		holopower_count += holopower_generated
		deck_count -= holopower_generated

	func remove_holopower(removed_count):
		holopower_count -= removed_count

	func set_oshi(oshi_id : String):
		var oshi_card_id = _player_id + "_oshi"
		var card = _game.create_card(oshi_card_id, oshi_id)
		card.begin_move_to(get_card_spawn_location(), true)
		_oshi_zone.add_card(card)

	func set_starting_life(starting_life_count):
		life_count = starting_life_count

	func set_starting_cheer(starting_cheer_count):
		cheer_count = starting_cheer_count

var me : PlayerState
var opponent : PlayerState

var observer_mode : bool = false
var catch_up_mode : bool = false
var catch_up_mode_end_when_caught_up : bool = false
var catch_up_last_requested_event_index : int = 0
var starting_player_id : String
var game_card_map

var ui_phase : UIPhase = UIPhase.UIPhase_Init
var selectable_card_ids : Array = []
var selection_min : int = 0
var selection_max : int = 0
var selected_cards = []
var action_menu_choice_info = {}
var card_popout_choice_info = {}
var click_cards_actions_remaining = []
var multi_step_decision_info = {}
var move_card_ids_already_handled = []
var initial_placement_state = {}
var main_step_action_data = {}
var preformance_step_action_data = {}
var last_network_event = null
var game_over = false
var event_queue = []
var remaining_animation_seconds = 0
var after_animation_continuation = null
var full_event_log = []
var phase_duration_time = 0
var me_clock_value = 0
var opponent_clock_value = 0
var active_targeted_damage_showing = null
var current_performance_target_card = null
var current_clock_player_id = ""
var sent_performance_step_notification_this_turn = false

const PhaseStartTimeBuffer = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NetworkManager.connect("disconnected_from_server", _on_disconnected)

	$DebugPlayLastEvent.visible = OS.is_debug_build()

	save_file_dialog.visible = false
	$UIOverlay.visible = true
	action_menu.visible = false
	thinking_spinner.visible = true
	settings_window.visible = false
	settings_window.connect("exit_game_pressed", _on_exit_game_button_pressed)

	me_stats.visible = false
	opponent_stats.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	phase_duration_time += delta
	thinking_spinner.radial_initial_angle += delta * 360
	if is_playing_animation():
		remaining_animation_seconds -= delta
	else:
		if after_animation_continuation:
			var callback = after_animation_continuation
			after_animation_continuation = null
			callback.call()
		else:
			_update_stats_ui()
			_process_next_event()
			if not is_playing_animation() and ui_phase == UIPhase.UIPhase_WaitingOnServer and not game_over:
				thinking_spinner.visible = true
			else:
				thinking_spinner.visible = false
	if ui_phase == UIPhase.UIPhase_WaitingOnServer:
		if observer_mode and current_clock_player_id == me._player_id:
			me_clock_value += delta
		else:
			opponent_clock_value += delta
	else:
		me_clock_value += delta
	update_clock(me_clock, me_clock_value)
	update_clock(opponent_clock, opponent_clock_value)

func is_playing_animation():
	return remaining_animation_seconds > 0

func _process_next_event():
	if catch_up_mode:
		while true:
			var event = event_queue.pop_front()
			if not event:
				if catch_up_mode_end_when_caught_up:
					catch_up_mode = false
					break
				if catch_up_last_requested_event_index < len(full_event_log):
					NetworkManager.observer_get_events(len(full_event_log))
					catch_up_last_requested_event_index = len(full_event_log)
				break
			update_clocks_from_event(event)
			process_game_event(event["event_type"], event)
	else:
		var event = event_queue.pop_front()
		if event:
			process_game_event(event["event_type"], event)

func begin_remote_game(event_type, event_data):
	Logger.log_game("Starting game!")
	handle_game_event(event_type, event_data)

func update_clock(clock_label, clock_value):
	var minutes = int(clock_value / 60)
	var seconds = int(clock_value) % 60
	clock_label.text = "%02d:%02d" % [minutes, seconds]

func update_clocks_from_event(event_data):
	if "your_clock_used" in event_data:
		me_clock_value = event_data["your_clock_used"]
	if "opponent_clock_used" in event_data:
		opponent_clock_value = event_data["opponent_clock_used"]

func check_switch_decision_owner(event_data):
	if event_data["event_type"] in Enums.DecisionEventTypes:
		var active_player = null
		if "effect_player_id" in event_data:
			active_player = get_player(event_data["effect_player_id"])
		elif "active_player" in event_data:
			active_player = get_player(event_data["active_player"])
		current_clock_player_id = active_player._player_id

func handle_game_event(event_type, event_data):
	Logger.log_game("Received game event: %s\n%s" % [event_type, event_data])
	if event_type == Enums.EventType_ObserverCaughtUp:
		catch_up_mode_end_when_caught_up = true
		return
	if len(full_event_log) > 0 and event_data["event_number"] <= full_event_log[-1]["event_number"]:
		Logger.log_game("Ignoring event %s because it has already been processed" % event_data["event_number"])
		return
	update_clocks_from_event(event_data)
	full_event_log.append(event_data)
	event_queue.append(event_data)

func process_game_event(event_type, event_data):
	game_log.add_to_log(GameLog.GameLogLine.Debug, "Event: %s" % event_type)

	check_switch_decision_owner(event_data)

	match event_type:
		Enums.EventType_AddTurnEffect:
			_on_add_turn_effect(event_data)
		Enums.EventType_Bloom:
			_on_bloom_event(event_data)
		Enums.EventType_BoostStat:
			_on_boost_stat_event(event_data)
		Enums.EventType_CheerStep:
			_on_cheer_step(event_data)
		Enums.EventType_Choice_SendCollabBack:
			_on_send_collab_back_event(event_data)
		Enums.EventType_Collab:
			_on_collab_event(event_data)
		Enums.EventType_DamageDealt:
			_on_damage_dealt_event(event_data)
		Enums.EventType_Decision_Choice:
			_on_choice_event(event_data)
		Enums.EventType_Decision_ChooseCards:
			_on_choose_cards_event(event_data)
		Enums.EventType_Decision_ChooseHolomemForEffect:
			_on_choose_holomem_for_effect_event(event_data)
		Enums.EventType_Decision_MainStep:
			_on_main_step_decision(event_data)
		Enums.EventType_Decision_OrderCards:
			_on_order_cards_event(event_data)
		Enums.EventType_Decision_PerformanceStep:
			_on_performance_step_decision(event_data)
		Enums.EventType_Decision_SendCheer:
			_on_send_cheer_event(event_data)
		Enums.EventType_Decision_SwapHolomemToCenter:
			_on_swap_holomem_to_center_event(event_data)
		Enums.EventType_DownedHolomem:
			_on_downed_holomem_event(event_data)
		Enums.EventType_DownedHolomem_Before:
			_on_downed_holomem_before_event(event_data)
		Enums.EventType_Draw:
			_on_draw_event(event_data)
		Enums.EventType_EndTurn:
			_on_end_turn_event(event_data)
		Enums.EventType_ForceDieResult:
			_on_force_die_result_event(event_data)
		Enums.EventType_GameError:
			_on_game_error(event_data)
		Enums.EventType_GameOver:
			_on_game_over(event_data)
		Enums.EventType_GameStartInfo:
			_begin_game(event_data)
		Enums.EventType_GenerateHolopower:
			_on_generate_holopower(event_data)
		Enums.EventType_InitialPlacementBegin:
			_on_initial_placement_begin(event_data)
		Enums.EventType_InitialPlacementPlaced:
			_on_initial_placement_placed(event_data)
		Enums.EventType_InitialPlacementReveal:
			_on_initial_placement_revealed(event_data)
		Enums.EventType_MainStepStart:
			_on_main_step_start(event_data)
		Enums.EventType_ModifyHP:
			_on_modify_hp_event(event_data)
		Enums.EventType_MoveCard:
			_on_move_card_event(event_data)
		Enums.EventType_MoveAttachedCard:
			_on_move_attached_card_event(event_data)
		Enums.EventType_MulliganDecision:
			_on_mulligan_decision_event(event_data)
		Enums.EventType_MulliganReveal:
			_on_mulligan_reveal_event(event_data)
		Enums.EventType_OshiSkillActivation:
			_on_oshi_skill_activation(event_data)
		Enums.EventType_PerformanceStepStart:
			on_performance_step_start(event_data)
		Enums.EventType_PerformArt:
			_on_perform_art_event(event_data)
		Enums.EventType_PlaySupportCard:
			_on_play_support_card_event(event_data)
		Enums.EventType_ResetStepActivate:
			_on_reset_step_activate_event(event_data)
		Enums.EventType_ResetStepChooseNewCenter:
			_on_reset_step_choose_new_center_event(event_data)
		Enums.EventType_ResetStepCollab:
			_on_reset_step_collab_event(event_data)
		Enums.EventType_RestoreHP:
			_on_restore_hp_event(event_data)
		Enums.EventType_RevealCards:
			_on_reveal_cards_event(event_data)
		Enums.EventType_RollDie:
			_on_roll_die_event(event_data)
		Enums.EventType_ShuffleDeck:
			_on_shuffle_deck_event(event_data)
		Enums.EventType_TurnStart:
			_on_turn_start(event_data)
		_:
			Logger.log_game("Unknown event type: %s" % event_type)
			assert(false)

	if event_data["event_type"] != Enums.EventType_GameError:
		last_network_event = event_data

	if not is_playing_animation():
		_update_stats_ui()

func _on_disconnected():
	game_log.add_to_log(GameLog.GameLogLine.Detail, "Lost connection to server")
	game_over_text.visible = true
	game_over_text.text = game_over_text.text.replace("WINNER_TEXT", "Lost connection to server")

func _get_card_definition_id(card_id):
	for key in game_card_map:
		if key == card_id:
			return game_card_map[key]
	return null

func _is_cheer_card(card_id):
	var definition_id = _get_card_definition_id(card_id)
	var card = CardDatabase.get_card(definition_id)
	return card["card_type"] == "cheer"

func _get_card_colors(card_id):
	var definition_id = _get_card_definition_id(card_id)
	var card = CardDatabase.get_card(definition_id)
	return card["colors"]

func _update_player_stats(player, stats_group):
	var stats_info = {
		"archive": player.get_archive_count(),
		"hand": player.get_hand_count(),
		"holopower": player.holopower_count,
		"deck": player.deck_count,
		"life": player.life_count,
		"cheer": player.cheer_count,
		"limited_available": not player.played_limited_this_turn,
		"oshi_turn_available": not player.used_oshi_turn_skill,
		"oshi_game_available": not player.used_oshi_game_skill,
	}
	stats_group.update_stats(stats_info)
	player._hand_indicator.text = str(player.hand_count)

func _update_stats_ui():
	if ui_phase == UIPhase.UIPhase_Init:
		return
	_update_player_stats(me, me_stats)
	_update_player_stats(opponent, opponent_stats)

func _on_game_error(event_data):
	var error_id = event_data["error_id"]
	var error_message = event_data["error_message"]
	game_log.add_to_log(GameLog.GameLogLine.Debug, "[PHASE]Error (%s):[/PHASE] %s" % [
		error_id,
		error_message
	])
	# TODO: Show a message box.
	# Replay the last event.
	#process_game_event(last_network_event["event_type"], last_network_event)

func _on_game_over(event_data):
	var winner_id = event_data["winner_id"]
	var winner_player = get_player(winner_id)
	var _loser_id = event_data["loser_id"]
	var _reason_id = event_data["reason_id"]
	game_log.add_to_log(GameLog.GameLogLine.Detail, "[PHASE]Winner:[/PHASE] %s!" % [
		winner_player.get_name_decorated(),
	])
	game_over_text.visible = true
	if observer_mode:
		game_over_text.text = game_over_text.text.replace("WINNER_TEXT", "%s Wins!" % [winner_player.get_name()])
	elif winner_player.is_me():
		game_over_text.text = game_over_text.text.replace("WINNER_TEXT", "YOU WIN!")
	else:
		game_over_text.text = game_over_text.text.replace("WINNER_TEXT", "YOU LOSE!")
	thinking_spinner.visible = false
	game_over = true
	action_menu.visible = false
	card_popout.visible = false

func _begin_game(event_data):
	starting_player_id = event_data["starting_player"]
	observer_mode = event_data["event_player_id"] == "observer"
	if observer_mode:
		catch_up_mode = true
	var my_id = event_data["your_id"]
	var opponent_id = event_data["opponent_id"]
	game_card_map = event_data["game_card_map"]

	me_username_label.text = event_data["your_username"]
	opponent_username_label.text = event_data["opponent_username"]

	me = PlayerState.new(self, my_id, true, event_data["your_username"],
		me_archive, me_backstage, me_collab,
		me_center, me_oshi, me_hand, me_hand_indicator,
		floating_zone, me_deck_spawn
	)
	opponent = PlayerState.new(self, opponent_id, false, event_data["opponent_username"],
		opponent_archive, opponent_backstage, opponent_collab,
		opponent_center, opponent_oshi, opponent_hand, opponent_hand_indicator,
		floating_zone, opponent_deck_spawn
	)

func create_card(card_id : String, definition_id_for_oshi : String = "", skip_add_to_all : bool = false) -> CardBase:
	var generic_hidden_card = card_id == "HIDDEN"
	var definition_id = definition_id_for_oshi
	var card_type = "oshi"
	var new_card : CardBase
	if generic_hidden_card:
		new_card = CardBaseScene.instantiate()
		new_card.create_card({}, "HIDDEN", card_id, "support")
	else:
		if definition_id_for_oshi:
			definition_id = definition_id_for_oshi
		else:
			definition_id = _get_card_definition_id(card_id)
		var definition = CardDatabase.get_card(definition_id)
		card_type = definition["card_type"]
		new_card = CardBaseScene.instantiate()
		new_card.create_card(definition, definition_id, card_id, card_type)
		new_card.connect("clicked_card", _on_card_pressed)
		new_card.connect("hover_card", _on_card_hovered)
		new_card.connect("view_attachments", _on_view_attachments)
	if not skip_add_to_all:
		all_cards.add_child(new_card)
	return new_card

func destroy_card(card : CardBase) -> void:
	if card:
		all_cards.remove_child(card)
		card.queue_free()

func _put_cards_on_top(cards : Array):
	for card in cards:
		all_cards.move_child(card, all_cards.get_child_count() - 1)

func find_card_on_board(card_id : String) -> CardBase:
	for card in all_cards.get_children():
		if card._card_id == card_id:
			return card
	return null

func get_player(player_id:String):
	if player_id == me._player_id:
		return me
	return opponent

func can_select_card(card_id: String):
	match ui_phase:
		UIPhase.UIPhase_MakeChoiceCanSelectCards:
			if _is_card_selected(card_id) or (card_id in selectable_card_ids and selected_cards.size() < selection_max):
				return true
		UIPhase.UIPhase_ClickCardsForAction:
			return _is_card_selected(card_id)
		_:
			return false

func select_card(card : CardBase):
	match ui_phase:
		UIPhase.UIPhase_MakeChoiceCanSelectCards:
			if _is_card_selected(card._card_id):
				card.set_selected(false)
				selected_cards.erase(card)
			else:
				# Set the card as selected.
				selected_cards.append(card)
				card.set_selected(true)
			if big_card._card_id == card._card_id:
				big_card.set_selected(card._selected)

			# After selection is changed, update buttons.
			var enabled_states = []
			for enable_check : Callable in action_menu_choice_info["enable_check"]:
				enabled_states.append(enable_check.call())
			action_menu.update_buttons_enabled(enabled_states)
			var popout_enabled_states = []
			if "enable_check" in card_popout_choice_info:
				for enable_check : Callable in card_popout_choice_info["enable_check"]:
					popout_enabled_states.append(enable_check.call())
			if popout_enabled_states:
				# TODO: Here is where to update instructions for # / # remaining.
				card_popout.update_panel_states("", popout_enabled_states)
		UIPhase.UIPhase_ClickCardsForAction:
			var current_selection = click_cards_actions_remaining[0]
			var callback : Callable = current_selection["callback"]
			callback.call(card._card_id)
		_:
			assert(false, "Unimplemented selection phase")

func _deselect_cards():
	for card : CardBase in all_cards.get_children():
		card.set_selected(false)
		card.set_selectable(false)
		card.set_info_highlight(false)
	selected_cards = []

func _is_selection_requirement_met():
	var count = len(selected_cards)
	return selection_min <= count and count <= selection_max

func _is_card_selected(card_id : String):
	for card_graphic in selected_cards:
		if card_id == card_graphic._card_id:
			return true
	return false

func _allowed():
	return true

func _play_popup_message(text :String, fast:bool = false):
	if catch_up_mode:
		return
	var popup = PopupMessageScene.instantiate()
	add_child(popup)
	popup.position = $PopupLocation.position
	remaining_animation_seconds = PopupMessage.MessageDurationSeconds
	if fast:
		remaining_animation_seconds = PopupMessage.FastMessageDurationSeconds
	popup.play_message(text, fast)

func _play_transient_icon_message(text : String, pos : Vector2, icon_type : PopupMessage.IconMessageType, fast : bool = false):
	if catch_up_mode:
		return
	var popup = PopupMessageScene.instantiate()
	add_child(popup)
	popup.position = pos
	remaining_animation_seconds = PopupMessage.MessageDurationSeconds
	if fast:
		remaining_animation_seconds = PopupMessage.FastMessageDurationSeconds
	popup.play_icon_message(text, icon_type, fast)

#
# Game Event Handlers
#

func _on_add_turn_effect(event_data):
	var active_player = get_player(event_data["effect_player_id"])
	var turn_effect = event_data["turn_effect"]
	var effect_text = tr("This Turn:") + " " + Strings.get_effect_text(turn_effect)
	game_log.add_to_log(GameLog.GameLogLine.Detail, "%s %s" % [
		active_player.get_name_decorated(),
		effect_text
	])
	_play_popup_message(effect_text)
	# TODO: Animation for turn effect being added / permanent indicator somewhere?
	pass

func _on_bloom_event(event_data):
	var active_player = get_player(event_data["bloom_player_id"])
	var bloom_card_id = event_data["bloom_card_id"]
	var target_card_id = event_data["target_card_id"]
	var bloom_from_zone = event_data["bloom_from_zone"]
	game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [CARD]%s[/CARD] blooms into [CARD]%s[/CARD]" % [
		active_player.get_name_decorated(),
		_get_card_definition_id(target_card_id),
		_get_card_definition_id(bloom_card_id)
	])
	if not active_player.is_me() or observer_mode:
		_play_popup_message("Bloom!", true)
	active_player.bloom(bloom_card_id, target_card_id, bloom_from_zone)

func _on_boost_stat_event(event_data):
	var card_id = event_data["card_id"]
	var stat = event_data["stat"]
	var amount = event_data["amount"]
	var for_art = event_data["for_art"]
	var source_card_id = event_data["source_card_id"] if event_data.has("source_card_id") else ""

	var card_str = ""
	if card_id:
		card_str = "[CARD]%s[/CARD] " % _get_card_definition_id(card_id)

	var skill_str = ""
	if source_card_id:
		skill_str = "[SKILLSOURCE]%s|%s[/SKILLSOURCE]" % [
			_get_card_definition_id(source_card_id),
			Strings.get_stat_string(stat)]
	else:
		skill_str = "[SKILL]%s[/SKILL]" % Strings.get_stat_string(stat)

	# TODO: Animation - show stat boost.
	game_log.add_to_log(GameLog.GameLogLine.Detail, "%s+%s %s " % [
		card_str,
		amount,
		skill_str
	])

	if for_art:
		var change_amount = amount
		if stat == "damage_prevented":
			change_amount = -amount
		current_performance_target_card.update_target_reticle(change_amount)

	if stat == "damage_prevented":
		var card = find_card_on_board(card_id)
		_play_transient_icon_message(str(amount), card.get_center_position(), PopupMessage.IconMessageType.Shield, true)
	else:
		_play_popup_message("+%s %s" % [amount, Strings.get_stat_string(stat)])


func _on_cheer_step(event_data):
	var active_player = get_player(event_data["active_player"])
	# TODO: Animation for Cheer Step
	if active_player.is_me() and not observer_mode:
		var cheer_to_place = event_data["cheer_to_place"]
		var source = event_data["source"]
		var options = event_data["options"]
		game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [DECISION]Choice: Cheer Step[/DECISION]" % [
			active_player.get_name()
		])
		var remaining_cheer_placements = []
		for cheer_id in cheer_to_place:
			# For now, assume cheer has 1 color.
			var color = _get_card_colors(cheer_id)[0]
			remaining_cheer_placements.append({
				"source": source,
				"cheer_id": cheer_id,
				"color": color,
				"allowed_placements": options,
				"callback": _place_cheer_on_card,
			})
		_begin_place_cheer(remaining_cheer_placements)
	else:
		pass

func _on_send_collab_back_event(event_data):
	var active_player = get_player(event_data["effect_player_id"])
	if active_player.is_me() and not observer_mode:
		game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [DECISION]Choice: Send Collab back[/DECISION]" % [
			active_player.get_name()
		])
		_begin_make_choice([], 0, 0)
		var instructions = Strings.get_string(Strings.DECISION_INSTRUCTIONS_SEND_COLLAB_BACK)
		action_menu_choice_info = {
			"strings": [Strings.get_string(Strings.STRING_NO), Strings.get_string(Strings.STRING_YES)],
			"enabled": [true, true],
			"enable_check": [_allowed, _allowed],
		}
		action_menu.show_choices(instructions, action_menu_choice_info, func(choice_index):
			# 0 is No, 1 is Yes
			submit_effect_resolution_make_choice(choice_index)
			_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
		)


func _on_collab_event(event_data):
	var active_player = get_player(event_data["collab_player_id"])
	var collab_card_id = event_data["collab_card_id"]
	var holopower_generated = event_data["holopower_generated"]
	game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [CARD]%s[/CARD] collabs" % [
		active_player.get_name_decorated(),
		_get_card_definition_id(collab_card_id)
	])
	if not active_player.is_me() or observer_mode:
		_play_popup_message("Collab!", true)
	do_move_cards(active_player, "backstage", "collab", "", [collab_card_id])
	active_player.generate_holopower(holopower_generated)

func _on_choice_event(event_data):
	var active_player = get_player(event_data["effect_player_id"])
	if active_player.is_me() and not observer_mode:
		var choices = event_data["choice"]
		var choice_texts = []
		var enabled = []
		var allowed = []
		var incoming_damage_str = ""
		for choice in choices:
			if "incoming_damage_info" in choice:
				incoming_damage_str = "\n" + Strings.get_incoming_damage_str(
					choice["incoming_damage_info"]["amount"],
					choice["incoming_damage_info"]["special"],
					choice["incoming_damage_info"]["prevent_life_loss"],
				)
				var target_card = find_card_on_board(choice["incoming_damage_info"]["target_id"])
				target_card.show_targeted_damage()
				active_targeted_damage_showing = target_card
			choice_texts.append(Strings.get_effect_text(choice))
			enabled.append(true)
			allowed.append(_allowed)
		game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [DECISION]Choice:[/DECISION]\n- %s" % [
			active_player.get_name_decorated(),
			"\n- ".join(choice_texts)
		])
		_begin_make_choice([], 0, 0)
		var instructions = Strings.get_string(Strings.DECISION_INSTRUCTIONS_MAKE_CHOICE) + incoming_damage_str
		action_menu_choice_info = {
			"strings": choice_texts,
			"enabled": enabled,
			"enable_check": allowed,
		}
		action_menu.show_choices(instructions, action_menu_choice_info, func(choice_index):
			submit_effect_resolution_make_choice(choice_index)
			_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
		)

	else:
		# Nothing for opponent.
		pass

func _on_choose_cards_event(event_data):
	var active_player = get_player(event_data["effect_player_id"])
	if active_player.is_me() and not observer_mode:
		var all_card_seen = event_data["all_card_seen"]
		var cards_can_choose = event_data["cards_can_choose"]
		var from_zone = event_data["from_zone"]
		var to_zone = event_data["to_zone"]
		var amount_min = event_data["amount_min"]
		var amount_max = event_data["amount_max"]
		#var reveal_chosen = event_data["reveal_chosen"]
		var remaining_cards_action = event_data["remaining_cards_action"]
		var requirement_details = event_data.get("requirement_details", {})
		var special_reason = event_data.get("special_reason", "")
		game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [DECISION]Choice: Choose Cards[/DECISION]" % [
			active_player.get_name()
		])
		if active_player.are_cards_in_zone_visible(from_zone) and from_zone != "archive":
			# Select from already on screen cards.
			assert(len(cards_can_choose) == len(all_card_seen))
			_begin_make_choice(cards_can_choose, amount_min, amount_max)
			var instructions = Strings.build_choose_cards_string(
				from_zone, to_zone, amount_min, amount_max,
				remaining_cards_action, requirement_details, special_reason
			)
			action_menu_choice_info = {
				"strings": [Strings.get_string(Strings.STRING_OK)],
				"enabled": [false],
				"enable_check": [_is_selection_requirement_met],
			}
			if amount_min == 0:
				action_menu_choice_info["strings"].append(Strings.get_string(Strings.STRING_PASS))
				action_menu_choice_info["enabled"].append(true)
				action_menu_choice_info["enable_check"].append(_allowed)
			action_menu.show_choices(instructions, action_menu_choice_info, func(choice_index):
				# Submit the choice. 0 is OK, 1 is Pass.
				# So on one, ignore the selected cards.
				var selected_ids = []
				if choice_index == 0:
					for card in selected_cards:
						selected_ids.append(card._card_id)
				submit_effect_resolution_choose_cards_for_effect(selected_ids)
				_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
			)
		else:
			# Need to create cards in a popout.
			var instructions = Strings.build_choose_cards_string(
				from_zone, to_zone, amount_min, amount_max,
				remaining_cards_action, requirement_details, special_reason
			)
			_show_popout(instructions, all_card_seen, cards_can_choose, amount_min, amount_max, false,
				func():
					var card_ids = []
					for card in selected_cards:
						card_ids.append(card._card_id)
					submit_effect_resolution_choose_cards_for_effect(card_ids)
					_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
					pass,
				null
			)

	else:
		# Nothing for opponent.
		pass

func _on_choose_holomem_for_effect_event(event_data):
	var active_player = get_player(event_data["effect_player_id"])
	if active_player.is_me() and not observer_mode:
		var cards_can_choose = event_data["cards_can_choose"]
		var effect = event_data["effect"]
		var amount_min = event_data.get("amount_min", 1)
		var amount_max = event_data.get("amount_max", 1)
		_begin_make_choice(cards_can_choose, amount_min, amount_max)
		var instructions = Strings.build_choose_holomem_for_effect_string(effect, amount_min, amount_max)
		action_menu_choice_info = {
			"strings": [Strings.get_string(Strings.STRING_OK)],
			"enabled": [false],
			"enable_check": [_is_selection_requirement_met],
		}
		action_menu.show_choices(instructions, action_menu_choice_info, func(_choice_index):
			# Submit the choice.
			var selected_ids = []
			for card in selected_cards:
				selected_ids.append(card._card_id)
			submit_effect_resolution_choose_cards_for_effect(selected_ids)
			_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
		)
	else:
		# Nothing for opponent.
		pass

func _on_order_cards_event(event_data):
	var active_player = get_player(event_data["effect_player_id"])
	if active_player.is_me() and not observer_mode:
		var card_ids = event_data["card_ids"]
		#var from_zone = event_data["from_zone"]
		var to_zone = event_data["to_zone"]
		var bottom = event_data["bottom"]
		var no_cancel_callback = null
		var instructions = Strings.build_order_cards_string(to_zone, bottom)
		game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [DECISION]Choice: Order Cards[/DECISION]" % [
			active_player.get_name()
		])
		_show_popout(instructions, card_ids, card_ids, 0, 0, true,
			func():
				var ordered_card_ids = card_popout.get_ordered_card_ids()
				submit_effect_resolution_order_cards(ordered_card_ids)
				_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
				pass,
			no_cancel_callback
		)
	else:
		# Nothing for opponent.
		pass

func _on_main_step_decision(event_data):
	var active_player = get_player(event_data["active_player"])
	if active_player.is_me() and not observer_mode:
		game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [DECISION]Choice: Main Step Action[/DECISION]" % [
			me.get_name()
		])
		var available_actions = event_data["available_actions"]
		action_menu_choice_info = {
			"strings": [],
			"enabled": [],
			"enable_check": [],
			"action_type": [],
			"actions_in_menu": [],
			"main_step_action_list": available_actions,
		}
		for action in available_actions:
			if action["action_type"] == Enums.GameAction_MainStepOshiSkill:
				# List oshi skills separately.
				var skill_id = action["skill_id"]
				var cost = action["skill_cost"]
				action_menu_choice_info["strings"].append(Strings.build_use_oshi_skill_string(skill_id, cost))
				action_menu_choice_info["enabled"].append(true)
				action_menu_choice_info["enable_check"].append(_allowed)
				action_menu_choice_info["action_type"].append(action["action_type"])
				action_menu_choice_info["actions_in_menu"].append(action)
			elif action["action_type"] not in action_menu_choice_info["action_type"]:
				# These are batched actions where there are multiple in the list of available actions
				# But we only want 1 UI item to show up.
				action_menu_choice_info["strings"].append(Strings.get_action_name(action["action_type"]))
				action_menu_choice_info["enabled"].append(true)
				action_menu_choice_info["enable_check"].append(_allowed)
				action_menu_choice_info["action_type"].append(action["action_type"])
				action_menu_choice_info["actions_in_menu"].append(action)

		_start_main_step_decision()
	else:
		# Nothing for opponent.
		pass

func _start_main_step_decision():
	_begin_make_choice([], 0, 0)
	var instructions = Strings.get_string(Strings.DECISION_INSTRUCTIONS_MAIN_STEP)
	action_menu.show_choices(instructions, action_menu_choice_info, func(choice_index):
		_on_main_step_action_chosen(choice_index)
	)

func _on_performance_step_decision(event_data):
	clear_performance_indicators()
	var active_player = get_player(event_data["active_player"])
	if active_player.is_me() and not observer_mode:
		game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [DECISION]Choice: Performance Step Action[/DECISION]" % [
			me.get_name()
		])
		var available_actions = event_data["available_actions"]
		action_menu_choice_info = {
			"strings": [],
			"enabled": [],
			"enable_check": [],
			"action_type": [],
			"performance_step_actions": available_actions,
		}
		for action in available_actions:
			var action_type = action["action_type"]
			if action_type == Enums.GameAction_PerformanceStepUseArt:
				var performer_position = action["performer_position"]
				var power = action["power"]
				action_menu_choice_info["strings"].append(Strings.get_performance_skill(performer_position, action["art_id"], power))
				action_menu_choice_info["enabled"].append(true)
				action_menu_choice_info["enable_check"].append(_allowed)
			else:
				# End Turn
				action_menu_choice_info["strings"].append(Strings.get_action_name(action["action_type"]))
				action_menu_choice_info["enabled"].append(true)
				action_menu_choice_info["enable_check"].append(_allowed)

		preformance_step_action_data = action_menu_choice_info
		_start_performance_step_decision()
	else:
		# Nothing for opponent.
		pass

func _start_performance_step_decision():
	var performance_step_actions = preformance_step_action_data["performance_step_actions"]
	_begin_make_choice([], 0, 0)
	var instructions = Strings.get_string(Strings.DECISION_INSTRUCTIONS_PERFORMANCE_STEP)
	action_menu.show_choices(instructions, action_menu_choice_info, func(choice_index):
		var chosen_action = performance_step_actions[choice_index]
		if chosen_action["action_type"] == Enums.GameAction_PerformanceStepEndTurn:
			submit_performance_step_end_turn()
			_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
		elif chosen_action["action_type"] == Enums.GameAction_PerformanceStepCancel:
			submit_performance_step_cancel()
			_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
		else:
			assert(chosen_action["action_type"] == Enums.GameAction_PerformanceStepUseArt)
			var valid_targets = chosen_action["valid_targets"]
			if len(valid_targets) == 1:
				var target_id = valid_targets[0]
				submit_performance_step_use_art(chosen_action["performer_id"], chosen_action["art_id"], target_id)
				_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
			else:
				# Save the chosne performance and let the user pick targets.
				multi_step_decision_info = {
					"performer_id": chosen_action["performer_id"],
					"skill_id": chosen_action["art_id"],
					"target_id": "",
				}
				# Need to select between the targets.
				_show_click_cards_action_menu(
					valid_targets,
					func(card_id): # Performance decision complete
						submit_performance_step_use_art(
							multi_step_decision_info["performer_id"],
							multi_step_decision_info["skill_id"],
							card_id
						)
						_change_ui_phase(UIPhase.UIPhase_WaitingOnServer),
					Strings.get_string(Strings.DECISION_INSTRUCTIONS_PERFORMANCE_ART_TARGET),
					_cancel_to_performance_step,
				)
				_highlight_info_cards([chosen_action["performer_id"]])
	)

func _highlight_selectable_cards(card_ids : Array):
	selectable_card_ids = card_ids
	selected_cards = []
	for card : CardBase in all_cards.get_children():
		var selectable = card._card_id in selectable_card_ids
		card.set_selectable(selectable)
		if selectable:
			card.set_selected(true)
			selected_cards.append(card)

func _highlight_info_cards(card_ids : Array):
	for card : CardBase in all_cards.get_children():
		if card._card_id in card_ids:
			card.set_info_highlight(true)

func _show_click_cards_action_menu(card_ids, callback, instructions : String, cancel_callback, cancel_string_id = Strings.STRING_CANCEL):
	_change_ui_phase(UIPhase.UIPhase_ClickCardsForAction)
	_highlight_selectable_cards(card_ids)

	click_cards_actions_remaining = [{
		"callback": callback
	}]

	action_menu_choice_info = {
		"strings": [],
		"enabled": [],
		"enable_check": []
	}
	if cancel_callback:
		action_menu_choice_info["strings"].append(Strings.get_string(cancel_string_id))
		action_menu_choice_info["enabled"].append(true)
		action_menu_choice_info["enable_check"].append(_allowed)
	action_menu.show_choices(instructions, action_menu_choice_info, func(_choice_index):
		# Must be a cancel.
		cancel_callback.call()
	)

func _cancel_to_main_step():
	action_menu_choice_info = main_step_action_data
	_start_main_step_decision()

func _cancel_to_performance_step():
	action_menu_choice_info = preformance_step_action_data
	_start_performance_step_decision()

func _show_popout(instructions : String, seen_card_ids : Array, chooseable_card_ids : Array,
	amount_min, amount_max, order_cards_mode : bool, completion_callback : Callable, cancel_callback,
	ok_string_id = Strings.STRING_OK, cancel_string_id = Strings.STRING_CANCEL
	):
	# Also show the action menu with two buttons: Show Choice and Cancel
	_change_ui_phase(UIPhase.UIPhase_MakeChoiceCanSelectCards)

	action_menu_choice_info = {
		"strings": [
			Strings.get_string(Strings.STRING_SHOW_CHOICE),
		],
		"enabled": [true],
		"enable_check": [_allowed]
	}
	if cancel_callback:
		action_menu_choice_info["strings"].append(Strings.get_string(cancel_string_id))
		action_menu_choice_info["enabled"].append(true)
		action_menu_choice_info["enable_check"].append(_allowed)

	selection_max = amount_max
	selection_min = amount_min
	card_popout_choice_info = {
		"strings": [
			Strings.get_string(ok_string_id),
		],
		"enabled": [amount_min == 0],
		"enable_check": [_is_selection_requirement_met],
		"callback": [completion_callback],
		"order_cards_mode": order_cards_mode,
	}
	if cancel_callback:
		card_popout_choice_info["strings"].append(Strings.get_string(cancel_string_id))
		card_popout_choice_info["enabled"].append(true)
		card_popout_choice_info["enable_check"].append(_allowed)
		card_popout_choice_info["callback"].append(cancel_callback)

	action_menu.show_choices(instructions, action_menu_choice_info, func(choice_index):
		if choice_index == 0:
			# Re-show the popout.
			card_popout.visible = true
			action_menu.visible = true
		else:
			# Cancel
			cancel_callback.call()
	)

	var card_copies = []
	selectable_card_ids = []
	for card_id in seen_card_ids:
		var new_card = create_card(card_id, "", true)
		card_copies.append(new_card)
		if amount_max > 0:
			if card_id in chooseable_card_ids:
				selectable_card_ids.append(card_id)
	card_popout.show_panel(instructions, card_popout_choice_info, card_copies, chooseable_card_ids)

func _get_main_step_actions_of_type(action_type):
	var found_actions = []
	for i in range(len(main_step_action_data["main_step_action_list"])):
		if main_step_action_data["main_step_action_list"][i]["action_type"] == action_type:
			found_actions.append(main_step_action_data["main_step_action_list"][i])
	return found_actions

func _on_main_step_action_chosen(choice_index):
	# Save action data in case the user cancels.
	main_step_action_data = action_menu_choice_info
	var chosen_action = action_menu_choice_info["actions_in_menu"][choice_index]
	var chosen_action_type = chosen_action["action_type"]
	var valid_actions = _get_main_step_actions_of_type(chosen_action_type)
	match chosen_action_type:
		Enums.GameAction_MainStepPlaceHolomem:
			# The valid actions have all holomems that are selectable to place.
			var valid_card_ids = []
			for action in valid_actions:
				valid_card_ids.append(action["card_id"])
			_show_click_cards_action_menu(
				valid_card_ids,
				_place_holomem_backstage,
				Strings.get_string(Strings.DECISION_INSTRUCTIONS_PLACE_HOLOMEM),
				_cancel_to_main_step
			)
		Enums.GameAction_MainStepBloom:
			# The valid actions have all combinations of bloom and target.
			# First, select a card to bloom from hand.
			# After that, you can select amongst the valid targets.
			var valid_card_ids = []
			for action in valid_actions:
				valid_card_ids.append(action["card_id"])
			_show_click_cards_action_menu(
				valid_card_ids,
				_bloom_target_selection,
				Strings.get_string(Strings.DECISION_INSTRUCTIONS_CHOOSE_BLOOM),
				_cancel_to_main_step
			)
		Enums.GameAction_MainStepCollab:
			# The valid actions have all holomems that are selectable to collab.
			var valid_card_ids = []
			for action in valid_actions:
				valid_card_ids.append(action["card_id"])
			_show_click_cards_action_menu(
				valid_card_ids,
				_collab_holomem,
				Strings.get_string(Strings.DECISION_INSTRUCTIONS_COLLAB),
				_cancel_to_main_step
			)
		Enums.GameAction_MainStepOshiSkill:
			submit_main_step_oshi_skill(chosen_action["skill_id"])
			_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
		Enums.GameAction_MainStepPlaySupport:
			var valid_card_ids = []
			for action in valid_actions:
				valid_card_ids.append(action["card_id"])
			_show_click_cards_action_menu(
				valid_card_ids,
				func(card_id):
					var support_card_action = null
					for action in valid_actions:
						if action["card_id"] == card_id:
							support_card_action = action
					if support_card_action["play_requirements"]:
						# If this card has additional play requirements,
						# Ask the user to fulfill them.
						assert(len(support_card_action["play_requirements"].keys()) == 1, "Unimplemented multiple play requirements")
						var requirement_name = support_card_action["play_requirements"].keys()[0]
						match requirement_name:
							"cheer_to_archive_from_play":
								var amount = support_card_action["play_requirements"]["cheer_to_archive_from_play"]["length"]
								assert(amount == 1, "Unimplemented other amounts")
								var cheer_on_each_mem = support_card_action["cheer_on_each_mem"]
								var valid_mem_ids = []
								for mem_id in cheer_on_each_mem.keys():
									if len(cheer_on_each_mem[mem_id]) > 0:
										valid_mem_ids.append(mem_id)
								# First, the user must select a holomem to pull cheer from.
								_show_click_cards_action_menu(
									valid_mem_ids,
									func(chosen_mem_id):
										# Now that the holomem with cheer is chosen, show the popout to pick cheer from them to archive.
										var cheer_options = cheer_on_each_mem[chosen_mem_id]
										var instructions = Strings.build_archive_cheer_string(amount)
										_show_popout(instructions, cheer_options, cheer_options, 1, 1, false,
											func():
												var chosen_cheer_ids = []
												for card in selected_cards:
													chosen_cheer_ids.append(card._card_id)
												var additional_play_requirements = {
													"cheer_to_archive_from_play": chosen_cheer_ids,
												}
												submit_main_step_play_support(card_id, additional_play_requirements)
												_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
												pass,
											_cancel_to_main_step
										)
										pass,
									Strings.get_string(Strings.DECISION_INSTRUCTIONS_CHOOSE_CHEER_SOURCE_HOLOMEM),
									_cancel_to_main_step
								)
							_:
								assert(false, "Unknown play requirement")
					else:
						# No play requirements, just play it.
						submit_main_step_play_support(card_id, {})
						_change_ui_phase(UIPhase.UIPhase_WaitingOnServer),
				Strings.get_string(Strings.DECISION_INSTRUCTIONS_CHOOSE_SUPPORT_CARD),
				_cancel_to_main_step
			)
		Enums.GameAction_MainStepBatonPass:
			# There is only one possible action for baton pass and
			# it has the backstage options and cheer options in it.
			# First, present the user a card popout with the cheer to select.
			# Once they've selected the required cheer, then they'll pick the backstage to swap.
			var cost = valid_actions[0]["cost"]
			var available_cheer = valid_actions[0]["available_cheer"]
			var instructions = Strings.build_archive_cheer_string(cost)
			_show_popout(instructions, available_cheer, available_cheer, cost, cost, false, _baton_pass_target_selection, _cancel_to_main_step)
		Enums.GameAction_MainStepBeginPerformance:
			submit_main_step_begin_performance()
			_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
		Enums.GameAction_MainStepEndTurn:
			submit_main_step_end_turn()
			_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
		_:
			assert(false, "Unknown action type")

func _on_send_cheer_event(event_data):
	var active_player = get_player(event_data["effect_player_id"])
	if active_player.is_me() and not observer_mode:
		game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [DECISION]Choice: Send Cheer[/DECISION]" % [
			me.get_name()
		])
		var amount_min = event_data["amount_min"]
		var amount_max = event_data["amount_max"]
		var from_zone = event_data["from_zone"]
		var to_zone = event_data["to_zone"]
		var cheer_to_send = event_data["from_options"].duplicate()
		var valid_targets = event_data["to_options"].duplicate()
		var holomem_to_cheer_list_map = event_data["cheer_on_each_mem"]
		var cancel_callback = null
		var multi_to = event_data.get("multi_to", false)
		var limit_one_per_member = event_data.get("limit_one_per_member", false)
		if amount_min == 0:
			cancel_callback = _send_no_cheer

		assert(to_zone in ["holomem", "archive"])
		assert(from_zone in ["archive", "cheer_deck", "life", "holomem", "downed_holomem", "opponent_holomem"])
		# For multi_to, and the cheer is from a single zone (one holo or archive) pick a target holomem then pick the cheers to give them, continue until all done.
		# For from holomem, first choose a mem, then choose a cheer on them in from_options, then choose a different holomem.
		# For archive/life/cheer deck, use the popout to select cheer, then choose a holomem.
		if multi_to and from_zone in ["downed_holomem", "archive"]:
			var cheer_source = null
			var max_can_place = min(amount_max, len(cheer_to_send))
			if from_zone == "archive":
				cheer_source = "archive"
			else:
				for mem_id in holomem_to_cheer_list_map.keys():
					var cheer_ids = holomem_to_cheer_list_map[mem_id]
					if cheer_to_send[0] in cheer_ids:
						cheer_source = mem_id
						break
			multi_step_decision_info = {
				"placements": {},
				"remaining_cheer": cheer_to_send,
				"source": cheer_source,
				"can_stop_at": amount_min,
				"remaining_cheer_allowed": max_can_place,
				"limit_one_per_member": limit_one_per_member,
			}
			_multi_send_cheer_continue(valid_targets, from_zone)
		elif from_zone == "holomem" or from_zone == "opponent_holomem":
			var max_can_place = min(amount_max, len(cheer_to_send))

			multi_step_decision_info = {
				"placements": {},
				"remaining_cheer": cheer_to_send,
				"can_stop_at": amount_min,
				"remaining_cheer_allowed": max_can_place,
				"holomem_to_cheer_list_map": holomem_to_cheer_list_map,
				"to_zone": to_zone,
				"valid_targets": valid_targets,
			}
			_multi_source_multi_target_send_cheer_continue()
		elif from_zone == "life" or from_zone == "cheer_deck":
			# Distribute the cheer sequentially.
			multi_step_decision_info = {
				"remaining_cheer_to_send": cheer_to_send,
				"valid_targets": valid_targets,
				"source": from_zone,
				"placements": {},
			}
			_send_cheer_continue()

		elif from_zone == "archive":
			# Show the popout to choose cheer from the archive.
			var instructions = Strings.build_send_cheer_string(
				amount_min, amount_max, from_zone
			)
			_show_popout(instructions, cheer_to_send, cheer_to_send, amount_min, amount_max, false,
				func():
					var chosen_cheer_ids = []
					for card in selected_cards:
						chosen_cheer_ids.append(card._card_id)
					# Now that cheer is chosen, select the target holomem.
					if len(valid_targets) == 1:
						# Move it all to the only target.
						var placements = {}
						for cheer_id in chosen_cheer_ids:
							placements[cheer_id] = valid_targets[0]
						submit_effect_resolution_move_cheer_between_holomems(placements)
						_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
					else:
						_show_click_cards_action_menu(
							valid_targets,
							func(chosen_target_mem):
								var placements = {}
								for cheer_id in chosen_cheer_ids:
									placements[cheer_id] = chosen_target_mem
								submit_effect_resolution_move_cheer_between_holomems(placements)
								_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
								pass,
							Strings.DECISION_INSTRUCTIONS_CHOOSE_CHEER_TARGET_HOLOMEM,
							cancel_callback
						)
					pass,
				cancel_callback
			)
		else:
			Logger.log_game("Unknown from_zone %s" % from_zone)
	else:
		# Nothing for opponent.
		pass

func _multi_send_cheer_continue(valid_targets, from_zone):
	var can_stop_multi_send = multi_step_decision_info["can_stop_at"] <= len(multi_step_decision_info["placements"].keys())
	var cancel_callback = null
	if can_stop_multi_send:
		cancel_callback = func():
			submit_effect_resolution_move_cheer_between_holomems(multi_step_decision_info["placements"])
			_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)

	# First choose a member.
	if multi_step_decision_info["limit_one_per_member"]:
		# Remove any members that are in the placements values.
		for mem_id in multi_step_decision_info["placements"].values():
			valid_targets.erase(mem_id)
		if len(valid_targets) == 0:
			# All members have cheer.
			submit_effect_resolution_move_cheer_between_holomems(multi_step_decision_info["placements"])
			_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
			return
	_show_click_cards_action_menu(
		valid_targets,
		func(chosen_target_mem):
			# Show popout with remaining unsent cheer.
			var instructions = Strings.build_send_cheer_string(
				0, multi_step_decision_info["remaining_cheer_allowed"], from_zone
			)
			var amount_can_pick = 1
			if not multi_step_decision_info["limit_one_per_member"]:
				amount_can_pick = multi_step_decision_info["remaining_cheer_allowed"]
			_show_popout(instructions, multi_step_decision_info["remaining_cheer"], multi_step_decision_info["remaining_cheer"],
				0, amount_can_pick, false,
				func():
					for card in selected_cards:
						multi_step_decision_info["placements"][card._card_id] = chosen_target_mem
						multi_step_decision_info["remaining_cheer"].erase(card._card_id)
						do_move_cards(me, multi_step_decision_info["source"], "holomem", chosen_target_mem, [card._card_id])
						move_card_ids_already_handled.append(card._card_id)
					multi_step_decision_info["remaining_cheer_allowed"] -= len(selected_cards)
					if multi_step_decision_info["remaining_cheer_allowed"] == 0:
						# All cheer sent, submit the effect resolution.
						submit_effect_resolution_move_cheer_between_holomems(multi_step_decision_info["placements"])
						_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
					else:
						# More cheer to send.
						_multi_send_cheer_continue(valid_targets, from_zone)
					pass,
				cancel_callback,
				Strings.STRING_SELECT_CHEER,
				Strings.STRING_END_ABILITY
			),
		Strings.get_string(Strings.DECISION_INSTRUCTIONS_CHOOSE_CHEER_TARGET_HOLOMEM),
		cancel_callback,
		Strings.STRING_END_ABILITY
	)

func _multi_source_multi_target_send_cheer_continue():
	var can_stop_multi_send = multi_step_decision_info["can_stop_at"] <= len(multi_step_decision_info["placements"].keys())
	var cancel_callback = null
	if can_stop_multi_send:
		cancel_callback = func():
			for cheer_id in multi_step_decision_info["placements"].keys():
				move_card_ids_already_handled.append(cheer_id)
			submit_effect_resolution_move_cheer_between_holomems(multi_step_decision_info["placements"])
			_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)

	var unique_mems = multi_step_decision_info["holomem_to_cheer_list_map"].keys()
	# Because cheer can move around from this original list, figure out which mems have cheer
	# locally and only allow those.
	var mems_with_cheer = []
	for mem in unique_mems:
		var mem_card = find_card_on_board(mem)
		var cheer_on_this_mem = mem_card.get_cheer_ids()
		for cheer_id in cheer_on_this_mem:
			if cheer_id in multi_step_decision_info["remaining_cheer"]:
				mems_with_cheer.append(mem)
				break

	_show_click_cards_action_menu(
		mems_with_cheer,
		func(chosen_source_mem):
			var chosen_mem_card = find_card_on_board(chosen_source_mem)
			var cheer_options = chosen_mem_card.get_cheer_ids()
			var placed_count = len(multi_step_decision_info["placements"].keys())
			var remaining_min = max(0, multi_step_decision_info["can_stop_at"] - placed_count)
			var remaining_max = multi_step_decision_info["remaining_cheer_allowed"] - placed_count
			var instructions = Strings.build_send_cheer_string(
				remaining_min, remaining_max, "holomem"
			)
			_show_popout(instructions, cheer_options, cheer_options, remaining_min, remaining_max, false,
				func():
					var chosen_cheer_ids = []
					for card in selected_cards:
						chosen_cheer_ids.append(card._card_id)

					if multi_step_decision_info["to_zone"] == "archive":
						for cheer_id in chosen_cheer_ids:
							# Go ahead and move the cheer.
							do_move_cards(me, chosen_source_mem, "archive", "", [cheer_id])
							# Update the placement.
							multi_step_decision_info["placements"][cheer_id] = "archive"
						var total_moved_count = len(multi_step_decision_info["placements"].keys())
						if total_moved_count == multi_step_decision_info["remaining_cheer_allowed"]:
							# Done, we have placed the max allowed.
							for cheer_id in multi_step_decision_info["placements"].keys():
								move_card_ids_already_handled.append(cheer_id)
							submit_effect_resolution_move_cheer_between_holomems(multi_step_decision_info["placements"])
							_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
						else:
							_multi_source_multi_target_send_cheer_continue()
					else:
						# Now that cheer is selected, choose the target holomem.
						# It can't be the source holomem.
						var valid_targets = multi_step_decision_info["valid_targets"].duplicate()
						valid_targets.erase(chosen_source_mem)
						_show_click_cards_action_menu(
							valid_targets,
							func(chosen_target_mem):
								# The user has chosen to move chosen_cheer_ids from chosen_source_mem to chosen_target_mem.
								for cheer_id in chosen_cheer_ids:
									# Go ahead and move the cheer.
									do_move_cards(me, chosen_source_mem, "holomem", chosen_target_mem, [cheer_id])
									# Update the placement.
									multi_step_decision_info["placements"][cheer_id] = chosen_target_mem

								var total_moved_count = len(multi_step_decision_info["placements"].keys())
								if total_moved_count == multi_step_decision_info["remaining_cheer_allowed"]:
									# Done, we have placed the max allowed.
									for cheer_id in multi_step_decision_info["placements"].keys():
										move_card_ids_already_handled.append(cheer_id)
									submit_effect_resolution_move_cheer_between_holomems(multi_step_decision_info["placements"])
									_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
								else:
									_multi_source_multi_target_send_cheer_continue()
								pass,
							Strings.DECISION_INSTRUCTIONS_CHOOSE_CHEER_TARGET_HOLOMEM,
							cancel_callback,
							Strings.STRING_END_ABILITY
						)
						_highlight_info_cards([chosen_source_mem])
					pass, # End of func passed to show_popout()
				cancel_callback,
				Strings.STRING_SELECT_CHEER,
				Strings.STRING_END_ABILITY
			)
			_highlight_info_cards([chosen_source_mem])
			,
		Strings.get_string(Strings.DECISION_INSTRUCTIONS_CHOOSE_CHEER_SOURCE_HOLOMEM),
		cancel_callback,
		Strings.STRING_END_ABILITY
	)

func _send_cheer_continue():
	if len(multi_step_decision_info["remaining_cheer_to_send"]) == 0:
		submit_effect_resolution_move_cheer_between_holomems(multi_step_decision_info["placements"])
		_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
	else:
		var next_cheer_id = multi_step_decision_info["remaining_cheer_to_send"].pop_front()
		var color = _get_card_colors(next_cheer_id)[0]
		var no_cancel_callback = null
		_show_click_cards_action_menu(
			multi_step_decision_info["valid_targets"],
			func(chosen_target_mem):
				multi_step_decision_info["placements"][next_cheer_id] = chosen_target_mem
				do_move_cards(me, multi_step_decision_info["source"], "holomem", chosen_target_mem, [next_cheer_id])
				move_card_ids_already_handled.append(next_cheer_id)
				_send_cheer_continue()
				pass,
			Strings.build_place_cheer_string(multi_step_decision_info["source"], color),
			no_cancel_callback
		)

func _send_no_cheer():
	submit_effect_resolution_move_cheer_between_holomems({})
	_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)

func _on_swap_holomem_to_center_event(event_data):
	var active_player = get_player(event_data["effect_player_id"])
	var cards_can_choose = event_data["cards_can_choose"]
	var is_opponent = event_data["swap_opponent_cards"]
	if active_player.is_me() and not observer_mode:
		var player_str = "your"
		if is_opponent:
			player_str = "opponent's"
		game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [DECISION]Choice: Swap %s Holomem with Center[/DECISION]" % [
			active_player.get_name_decorated(), player_str
		])
		_begin_make_choice(cards_can_choose, 1, 1)
		var instructions = Strings.get_string(Strings.DECISION_INSTRUCTIONS_SWAP_CENTER)
		action_menu_choice_info = {
			"strings": [Strings.get_string(Strings.STRING_OK)],
			"enabled": [false],
			"enable_check": [_is_selection_requirement_met],
		}
		action_menu.show_choices(instructions, action_menu_choice_info, func(_choice_index):
			# Submit the choice.
			submit_effect_resolution_choose_cards_for_effect([selected_cards[0]._card_id])
			_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
		)
	else:
		# Nothing for opponent.
		pass

func get_card_logline(card_ids):
	var card_detail_str = ""
	var card_strs = []
	for card_id in card_ids:
		if card_id == "HIDDEN":
			card_strs.append("?")
		else:
			card_strs.append(_get_card_definition_id(card_id))
	if card_strs:
		card_detail_str = " - [CARD]%s" % "[/CARD], [CARD]".join(card_strs)
		card_detail_str += "[/CARD]"
	return card_detail_str

func _on_draw_event(event_data):
	var drawn_card_ids = event_data["drawn_card_ids"]
	var active_player = get_player(event_data["drawing_player_id"])
	var created_cards = []
	for card_id in drawn_card_ids:
		var new_card = create_card(card_id)
		created_cards.append(new_card)
		new_card.begin_move_to(active_player.get_card_spawn_location(), true)
	game_log.add_to_log(GameLog.GameLogLine.Detail, "%s draws %s cards%s" % [
		active_player.get_name_decorated(),
		len(drawn_card_ids),
		get_card_logline(drawn_card_ids)
	])
	if not active_player.is_me() or observer_mode:
		_play_popup_message(tr("{PLAYER} draws {AMOUNT}").format({PLAYER = active_player.get_name(), AMOUNT = len(drawn_card_ids)}), true)

	active_player.draw_cards(len(drawn_card_ids), created_cards)

func _begin_make_choice(selectable_ids : Array, min_selectable : int, max_selectable : int):
	_change_ui_phase(UIPhase.UIPhase_MakeChoiceCanSelectCards)
	selectable_card_ids = selectable_ids
	selection_min = min_selectable
	selection_max = max_selectable

	# For all cards in all zones, update selectable.
	for card in all_cards.get_children():
		var selectable = card._card_id in selectable_card_ids
		card.set_selectable(selectable)

func _begin_place_cheer(remaining_cheer_placements : Array):
	click_cards_actions_remaining = remaining_cheer_placements
	multi_step_decision_info = {}
	_continue_select_destination_cards()

func _continue_select_destination_cards():
	if len(click_cards_actions_remaining) == 0:
		# Selection is finished.
		action_menu.hide_menu()
		move_card_ids_already_handled = []
		for key in multi_step_decision_info:
			move_card_ids_already_handled.append(key)
		submit_place_cheer(multi_step_decision_info)
		_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
	else:
		_change_ui_phase(UIPhase.UIPhase_ClickCardsForAction)

		action_menu_choice_info = {
			"strings": [],
			"enabled": [],
			"enable_check": []
		}
		var next_selection = click_cards_actions_remaining[0]
		var source = next_selection["source"]
		var color = next_selection["color"]
		var allowed_placements = next_selection["allowed_placements"]
		_highlight_selectable_cards(allowed_placements)

		var instructions = Strings.build_place_cheer_string(source, color)
		action_menu.show_choices(instructions, action_menu_choice_info, func(_choice_index):
			# Unexpected, just for instructions.
			assert(false, "This didn't have a button press available")
			pass
		)

func _place_cheer_on_card(selected_card_id):
	var current_selection_info = click_cards_actions_remaining.pop_front()
	var cheer_id = current_selection_info["cheer_id"]
	var source = current_selection_info["source"]
	multi_step_decision_info[cheer_id] = selected_card_id

	do_move_cards(me, source, "holomem", selected_card_id, [cheer_id])
	_continue_select_destination_cards()

func _place_holomem_backstage(card_id):
	do_move_cards(me, "hand", "backstage", "", [card_id])
	move_card_ids_already_handled.append(card_id)
	submit_main_step_place_holomem(card_id)
	_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)

func _bloom_target_selection(bloom_card_id):
	multi_step_decision_info = {
		"bloom_card_id": bloom_card_id
	}
	var actions = _get_main_step_actions_of_type(Enums.GameAction_MainStepBloom)
	var valid_targets = []
	for action in actions:
		if action["card_id"] == bloom_card_id:
			valid_targets.append(action["target_id"])

	# Now select the target.
	_show_click_cards_action_menu(
		valid_targets,
		_bloom_target_completed,
		Strings.get_string(Strings.DECISION_INSTRUCTIONS_CHOOSE_BLOOM),
		_cancel_to_main_step
	)
	_highlight_info_cards([bloom_card_id])

func _baton_pass_target_selection():
	var card_ids = []
	for card in selected_cards:
		card_ids.append(card._card_id)
	multi_step_decision_info = {
		"card_ids": card_ids
	}
	var actions = _get_main_step_actions_of_type(Enums.GameAction_MainStepBatonPass)
	var target_card_ids = actions[0]["backstage_options"]

	# Now select the target.
	_show_click_cards_action_menu(
		target_card_ids,
		_baton_pass_holomem_complete,
		Strings.get_string(Strings.DECISION_INSTRUCTIONS_CHOOSE_BATONPASS),
		_cancel_to_main_step
	)

func _bloom_target_completed(target_card_id):
	# Bloom event will handle the animations/card updates.
	submit_main_step_bloom(multi_step_decision_info["bloom_card_id"], target_card_id)
	_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)

func _collab_holomem(card_id):
	submit_main_step_collab(card_id)
	_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)

func _baton_pass_holomem_complete(card_id):
	var cheer_ids = multi_step_decision_info["card_ids"]
	submit_main_step_baton_pass(card_id, cheer_ids)
	_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)

func _change_ui_phase(new_ui_phase : UIPhase):
	_deselect_cards()
	action_menu.hide_menu()
	card_popout.clear_panel()
	if new_ui_phase != ui_phase:
		# Phase changed.
		if phase_duration_time > PhaseStartTimeBuffer and ui_phase == UIPhase.UIPhase_WaitingOnServer:
			# Switching to active mode.
			if GlobalSettings.get_user_setting(GlobalSettings.GameSound):
				turnstart_audio.play()
		phase_duration_time = 0
	ui_phase = new_ui_phase
	if new_ui_phase != UIPhase.UIPhase_WaitingOnServer:
		thinking_spinner.visible = false
	else:
		# Clear anything based on what we might have just submitted to the server.
		if active_targeted_damage_showing:
			active_targeted_damage_showing.hide_targeted_damage()
			active_targeted_damage_showing = null
	_update_stats_ui()

func _on_generate_holopower(event_data):
	var active_player = get_player(event_data["generating_player_id"])
	var amount = event_data["holopower_generated"]
	active_player.generate_holopower(amount)

func _on_initial_placement_begin(event_data):
	var active_player = get_player(event_data["active_player"])
	if active_player.is_me() and not observer_mode:
		game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [DECISION]Choice: Initial Placement[/DECISION]" % active_player.get_name())
		initial_placement_state = {}
		# First, choose the center member.
		var debut_in_hand  = me.get_card_ids_in_hand(["holomem_debut"])
		_begin_make_choice(debut_in_hand, 1, 1)
		action_menu_choice_info = {
			"strings": [Strings.get_string(Strings.STRING_OK)],
			"enabled": [false],
			"enable_check": [_is_selection_requirement_met]
		}
		action_menu.show_choices(Strings.get_string(Strings.DECISION_INSTRUCTIONS_INITIAL_CHOOSE_CENTER), action_menu_choice_info, func(_choice_index):
			# Pressed ok and a mem is selected.
			# Next select backstagers.
			initial_placement_state["center"] = selected_cards[0]._card_id
			do_move_cards(me, "hand", "center", "", [selected_cards[0]._card_id])
			var backstage_options = me.get_card_ids_in_hand(["holomem_debut", "holomem_spot"])
			backstage_options.erase(initial_placement_state["center"])
			_begin_make_choice(backstage_options, 0, 5)
			action_menu_choice_info = {
				"strings": [Strings.get_string(Strings.STRING_OK)],
				"enabled": [true],
				"enable_check": [_is_selection_requirement_met]
			}
			action_menu.show_choices(Strings.get_string(Strings.DECISION_INSTRUCTIONS_INITIAL_CHOOSE_BACKSTAGE), action_menu_choice_info, func(_choice_index2):
				initial_placement_state["backstage"] = []
				for card in selected_cards:
					initial_placement_state["backstage"].append(card._card_id)
				submit_initial_placement(initial_placement_state)
				do_move_cards(me, "hand", "backstage", "", initial_placement_state["backstage"])
				_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
			)
		)
	else: # Opponent
		# Do nothing.
		pass

func _on_initial_placement_placed(event_data):
	var active_player = get_player(event_data["active_player"])
	var center_id = event_data["center_card_id"]
	var backstage_ids = event_data["backstage_card_ids"]
	var hand_count = event_data["hand_count"]
	if active_player.is_me() and not observer_mode:
		# The initial placement should have probably already moved and updated everything.
		# So there should be nothing to do here.
		pass
	else:
		# The opponent placed their cards.
		# TODO: Animate placeholder cards going from their hand to the right spots.
		active_player.remove_from_hand(center_id)
		for card_id in backstage_ids:
			active_player.remove_from_hand(card_id)
		assert(hand_count == active_player.hand_count)

func _on_initial_placement_revealed(event_data):
	var placement_info = event_data["placement_info"]
	for info in placement_info:
		var active_player = get_player(info["player_id"])
		var oshi_id = info["oshi_id"]
		var center_card_id = info["center_card_id"]
		var backstage_card_ids = info["backstage_card_ids"]
		var hand_count = info["hand_count"]
		var cheer_deck_count = info["cheer_deck_count"]
		var life_count = info["life_count"]

		if observer_mode:
			game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [PHASE]*Initial Placement*[/PHASE]" % active_player.get_name())
			do_move_cards(active_player, "hand", "center", "", [center_card_id])
			do_move_cards(active_player, "hand", "backstage", "", backstage_card_ids)
			active_player.hand_count = hand_count
			_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
		elif not active_player.is_me():
			game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [PHASE]*Initial Placement*[/PHASE]" % active_player.get_name())
			# Local player is done on initial placement
			do_move_cards(active_player, "hand", "center", "", [center_card_id])
			do_move_cards(active_player, "hand", "backstage", "", backstage_card_ids)
			# TODO: Fix later, but hand count was updated in placement
			active_player.hand_count += (1 + len(backstage_card_ids))
		active_player.set_oshi(oshi_id)
		active_player.set_starting_cheer(cheer_deck_count)
		active_player.set_starting_life(life_count)
		assert(active_player.hand_count == hand_count)
	me_stats.visible = true
	opponent_stats.visible = true

func _on_main_step_start(event_data):
	var active_player = get_player(event_data["active_player"])
	game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [PHASE]*Main Step*[/PHASE]" % active_player.get_name())
	if not active_player.is_me() or observer_mode:
		_play_popup_message("Main Step", true)

func _on_modify_hp_event(event_data):
	var active_player = get_player(event_data["target_player_id"])
	var card_id = event_data["card_id"]
	var damage_done = event_data["damage_done"]
	var new_damage = event_data["new_damage"]

	var card = find_card_on_board(card_id)
	card.set_damage(new_damage)

	_play_transient_icon_message(str(damage_done), card.get_center_position(), PopupMessage.IconMessageType.Damage, true)
	game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [CARD]%s[/CARD] takes %s damage" % [
		active_player.get_name_decorated(),
		_get_card_definition_id(card_id),
		damage_done
	])


func _on_move_card_event(event_data):
	var active_player = get_player(event_data["moving_player_id"])
	var from_zone = event_data["from_zone"]
	var to_zone = event_data["to_zone"]
	var zone_card_id = ""
	if "zone_card_id" in event_data:
		zone_card_id = event_data["zone_card_id"]
	var card_id = event_data["card_id"]

	var already_handled = false
	if card_id in move_card_ids_already_handled:
		move_card_ids_already_handled.erase(card_id)
		already_handled = true

	if (observer_mode or not active_player.is_me()) and from_zone == "hand" and to_zone == "backstage":
		# Play a popup message informing what opponent is doing.
		_play_popup_message("Place Holomem", true)

	if not already_handled:
		do_move_cards(active_player, from_zone, to_zone, zone_card_id, [card_id])

func do_move_cards(player, from, to, zone_card_id, card_ids):
	for card_id in card_ids:
		var spawn_location = player.get_card_spawn_location()
		var ignore_log = (from == "floating" or to == "floating" or from == to)
		var from_zone = from
		match from:
			"archive":
				player.remove_from_archive(card_id)
			"backstage":
				player.remove_backstage(card_id)
			"center":
				player.remove_center(card_id)
			"cheer_deck":
				player.remove_card_from_cheer_deck(card_id)
				spawn_location = player.get_cheer_deck_spawn_location()
			"collab":
				player.remove_collab(card_id)
			"deck":
				player.remove_card_from_deck(card_id)
			"life":
				player.life_count -= 1
				spawn_location = player.get_life_spawn_location()
			"floating":
				player.remove_floating(card_id)
			"hand":
				player.remove_from_hand(card_id)
				if not player.is_me() or observer_mode:
					spawn_location = player.get_hand_placeholder_location()
			"holopower":
				player.remove_holopower(1)
				spawn_location = player.get_holopower_spawn_location()
			"stage":
				# This is a holomem card on stage, but we're not sure where.
				# Just try to remove it, it can only be in one place anyway.
				player.remove_center(card_id)
				player.remove_backstage(card_id)
				player.remove_collab(card_id)
			_:
				# Assume this is a holomem card.
				from_zone = "[CARD]%s[/CARD]" % _get_card_definition_id(from)
				var holomem_from_card = find_card_on_board(from)
				if holomem_from_card:
					holomem_from_card.remove_attached(card_id)
					spawn_location = holomem_from_card.get_center_position()
				else:
					assert(false, "Unexpected from zone")

		if not ignore_log:
			var to_zone = to
			if zone_card_id:
				to_zone = "[CARD]%s[/CARD]" % _get_card_definition_id(zone_card_id)
			game_log.add_to_log(GameLog.GameLogLine.Detail, "%s moves [CARD]%s[/CARD] from %s to %s" % [
				player.get_name_decorated(),
				_get_card_definition_id(card_id),
				from_zone,
				to_zone
			])
		var card = find_card_on_board(card_id)
		if card_id == "HIDDEN" or not card:
			card = create_card(card_id)
			card.scale = Vector2(CardBase.DefaultCardScale, CardBase.DefaultCardScale)
			card.begin_move_to(spawn_location, true)

		match to:
			"archive":
				player.add_card_to_archive(card)
			"backstage":
				player.add_backstage(card)
			"center":
				player.add_center(card)
			"cheer_deck":
				player.add_card_to_cheer_deck(card)
			"collab":
				player.add_collab(card)
			"deck":
				player.add_card_to_deck(card)
			"floating":
				player.add_floating(card)
			"holopower":
				player.generate_holopower(1)
				card.begin_move_to(player.get_holopower_spawn_location(), false, true)
			"hand":
				player.add_card_to_hand(card)
				card.clear_stats_back_to_hand()
			_:
				var holomem_card = find_card_on_board(zone_card_id)
				if holomem_card:
					card.begin_move_to(holomem_card.get_center_position(), false, true)
					if _is_cheer_card(card_id):
						var cheer_colors = _get_card_colors(card_id)
						holomem_card.attach_cheer(card_id, cheer_colors)
					else:
						holomem_card.attach_card(card._card_id)
				else:
					Logger.log_game("Unimplemented MoveCard from zone")
					assert(false)

func _on_move_attached_card_event(event_data):
	var active_player= get_player(event_data["owning_player_id"])
	var from_holomem_id = event_data["from_holomem_id"]
	var to_holomem_id = event_data["to_holomem_id"]
	var attached_id = event_data["attached_id"]

	var already_handled = false
	if attached_id in move_card_ids_already_handled:
		move_card_ids_already_handled.erase(attached_id)
		already_handled = true

	if not already_handled:
		do_move_cards(active_player, from_holomem_id, to_holomem_id, to_holomem_id, [attached_id])

func _on_mulligan_decision_event(event_data):
	var active_player = get_player(event_data["active_player"])
	var first_player = event_data.get("first_player", "")
	if active_player.is_me() and not observer_mode:
		game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [DECISION]Choice: Mulligan[/DECISION]" % [
			active_player.get_name_decorated(),
		])
		action_menu_choice_info = {
			"strings": [
				Strings.get_string(Strings.STRING_YES),
				Strings.get_string(Strings.STRING_NO),
			],
			"enabled": [true, true],
			"enable_check": [_allowed, _allowed]
		}
		_begin_make_choice([], 0, 0)
		var mulligan_instructions = Strings.get_string(Strings.DECISION_INSTRUCTIONS_MULLIGAN)
		if first_player:
			var first_player_is_me = first_player == me._player_id
			mulligan_instructions = Strings.build_mulligan_instructions(first_player_is_me)
		action_menu.show_choices(mulligan_instructions, action_menu_choice_info, func(choice_index : int):
			if choice_index == 0:
				submit_mulligan_choice(true)
			else:
				submit_mulligan_choice(false)
			_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
		)
	else: # Opponent
		# Do nothing.
		pass

func _on_mulligan_reveal_event(event_data):
	var active_player = get_player(event_data["active_player"])
	var revealed_card_ids = event_data["revealed_card_ids"]
	if not active_player.is_me() or observer_mode:
		var card_def_list = []
		for card_id in revealed_card_ids:
			card_def_list.append(_get_card_definition_id(card_id))
		game_log.add_to_log(GameLog.GameLogLine.Detail, "%s mulligans revealing [%s]" % [
			active_player.get_name_decorated(),
			", ".join(card_def_list)
		])
		# The opponent is revealing us cards they mulliganed from a forced mulligan.
		# TODO: Show the cards somehow.
		pass

func _on_perform_art_event(event_data):
	#notify_performance_step(event_data["active_player"])
	var active_player = get_player(event_data["active_player"])
	var performer_id = event_data["performer_id"]
	var art_id = event_data["art_id"]
	var target_id = event_data["target_id"]
	var power = event_data["power"]
	game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [CARD]%s[/CARD] performs art [SKILL]%s[/SKILL] %s" % [
		active_player.get_name_decorated(),
		_get_card_definition_id(performer_id),
		Strings.get_skill_string(art_id),
		power,
	])

	var art_str = tr("Art: %s") % [Strings.get_skill_string(art_id)]
	var base_power_str = tr("Base Power: %s") % [power]
	_play_popup_message(art_str + "\n" + base_power_str)
	var performer = find_card_on_board(performer_id)
	var target = find_card_on_board(target_id)
	performer.show_active_skill(Strings.get_skill_string(art_id))
	target.show_target_reticle(power)
	current_performance_target_card = target

func clear_performance_indicators():
	current_performance_target_card  = null
	for card in all_cards.get_children():
		card.hide_performance_skill_indicators()

func _on_damage_dealt_event(event_data):
	var target_player = get_player(event_data["target_player"])
	var target_id = event_data["target_id"]
	var damage = event_data["damage"]
	var _special = event_data["special"]

	var card = find_card_on_board(target_id)
	card.add_damage(damage, false)
	game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [CARD]%s[/CARD] takes %s damage" % [
		target_player.get_name_decorated(),
		_get_card_definition_id(target_id),
		damage,
	])

	_play_transient_icon_message(str(damage), card.get_center_position(), PopupMessage.IconMessageType.Damage, true)

func _process_downed_holomem(target_player, card, hand_ids, is_game_over, life_lost):
	game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [CARD]%s[/CARD] is downed" % [
		target_player.get_name_decorated(),
		card._definition_id,
	])

	_play_transient_icon_message("DOWN", card.get_center_position(), PopupMessage.IconMessageType.Damage,true)

	# Put the card and all attached cards in the archive or hand as approrpiate.
	var attached_card_ids = card.get_attached()
	var attached_cheer = card.remove_all_attached_cheer()
	for attached_id in attached_card_ids:
		var attached_dest = "archive"
		if attached_id in hand_ids:
			attached_dest = "hand"
		do_move_cards(target_player, card._card_id, attached_dest, "", [attached_id])
	card.clear_attached()
	for cheer_id in attached_cheer:
		do_move_cards(target_player, card._card_id, "archive", "", [cheer_id])

	var dest = "archive"
	if card._card_id in hand_ids:
		dest = "hand"
	do_move_cards(target_player, "stage", dest, "", [card._card_id])

	if is_game_over:
		# The event to lower the life won't occur, so do that now.
		target_player.life_count -= life_lost

func _on_downed_holomem_event(event_data):
	var target_player = get_player(event_data["target_player"])
	var target_id = event_data["target_id"]
	var is_game_over = event_data["game_over"]
	var life_lost = event_data["life_lost"]
	var _life_loss_prevented = event_data["life_loss_prevented"]
	var _archived_ids = event_data["archived_ids"]
	var hand_ids = event_data["hand_ids"]

	var card = find_card_on_board(target_id)
	card.hide_targeted_down()
	_process_downed_holomem(target_player, card, hand_ids, is_game_over, life_lost)

func _on_downed_holomem_before_event(event_data):
	#var target_player = get_player(event_data["target_player"])
	var target_id = event_data["target_id"]
	var card = find_card_on_board(target_id)
	card.show_targeted_down()

func _on_play_support_card_event(event_data):
	var active_player = get_player(event_data["player_id"])
	var card_id = event_data["card_id"]
	var _limited = event_data["limited"]
	var limited_str = ""
	if _limited:
		limited_str = " (LIMITED)"
		active_player.played_limited_this_turn = true
	game_log.add_to_log(GameLog.GameLogLine.Detail, "%s plays Support - [CARD]%s[/CARD]%s" % [
		active_player.get_name_decorated(),
		_get_card_definition_id(card_id),
		limited_str,
	])
	do_move_cards(active_player, "hand", "floating", "", [card_id])
	# TODO: Mark limited use somewhere
	if not active_player.is_me() or observer_mode:
		_play_popup_message("Playing Support Card", true)
	pass

func _on_reset_step_activate_event(event_data):
	var active_player = get_player(event_data["active_player"])
	var activated_cards = event_data["activated_card_ids"]
	# These cards are no longer resting.
	for card_id in activated_cards:
		var card = find_card_on_board(card_id)
		if card:
			game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [CARD]%s[/CARD] no longer resting" % [
				active_player.get_name_decorated(),
				_get_card_definition_id(card_id)
			])
			card.set_resting(false)
		else:
			assert(false, "Missing card")

func _on_reset_step_choose_new_center_event(event_data):
	var active_player = get_player(event_data["active_player"])
	var center_options = event_data["center_options"]
	if active_player.is_me() and not observer_mode:
		game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [DECISION]Choice: Choose new Center[/DECISION]" % [
			active_player.get_name_decorated(),
		])
		_begin_make_choice(center_options, 1, 1)
		action_menu_choice_info = {
			"strings": [Strings.get_string(Strings.STRING_OK)],
			"enabled": [false],
			"enable_check": [_is_selection_requirement_met]
		}
		action_menu.show_choices(Strings.get_string(Strings.DECISION_INSTRUCTIONS_CHOOSE_NEW_CENTER), action_menu_choice_info, func(_choice_index):
			# Pressed ok and a mem is selected.
			submit_choose_new_center(selected_cards[0]._card_id)
			_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
		)
	else:
		_play_popup_message("Reset Step - Choose Center", true)
		pass


func _on_reset_step_collab_event(event_data):
	var active_player = get_player(event_data["active_player"])
	var activated_cards = event_data["rested_card_ids"]
	var moved_backstage_ids = event_data["moved_backstage_ids"]
	# These cards are no longer resting.
	for card_id in activated_cards:
		var card = find_card_on_board(card_id)
		if card:
			card.set_resting(true)
			game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [CARD]%s[/CARD] resting from Collab" % [
				active_player.get_name_decorated(),
				_get_card_definition_id(card_id)
			])
			if card_id not in moved_backstage_ids:
				game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [CARD]%s[/CARD] blocked from moving back" % [
					active_player.get_name_decorated(),
					_get_card_definition_id(card_id)
				])
		else:
			assert(false, "Missing card")
	for card_id in moved_backstage_ids:
		do_move_cards(active_player, "collab", "backstage", "", [card_id])

func _on_restore_hp_event(event_data):
	var active_player = get_player(event_data["target_player_id"])
	var card_id = event_data["card_id"]
	var healed_amount = event_data["healed_amount"]
	var new_damage = event_data["new_damage"]
	var card = find_card_on_board(card_id)
	card.set_damage(new_damage)

	_play_transient_icon_message(str(healed_amount), card.get_center_position(), PopupMessage.IconMessageType.Heart, true)
	game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [CARD]%s[/CARD] heals %s damage" % [
		active_player.get_name_decorated(),
		_get_card_definition_id(card_id),
		healed_amount
	])

func _on_reveal_cards_event(event_data):
	var active_player = get_player(event_data["effect_player_id"])
	var card_ids = event_data["card_ids"]
	var source = event_data["source"]
	var source_str = ""
	match source:
		"topdeck":
			source_str = "top of deck"
	for card_id in card_ids:
		game_log.add_to_log(GameLog.GameLogLine.Detail, "%s reveals [CARD]%s[/CARD] from %s" % [
			active_player.get_name_decorated(),
			_get_card_definition_id(card_id),
			source_str
		])
	# TODO: Find a way to add revealed cards somewhere.

func _on_roll_die_event(event_data):
	var active_player = get_player(event_data["effect_player_id"])
	var die_result = event_data["die_result"]
	var rigged = event_data["rigged"]
	var rigged_str = ""
	if rigged:
		rigged_str = " " + tr("(RIGGED)")
	game_log.add_to_log(GameLog.GameLogLine.Detail, "%s die roll = %s%s" % [
		active_player.get_name_decorated(),
		die_result,
		rigged_str,
	])
	_play_popup_message(tr("Rolled die:") + " %s%s" % [die_result, rigged_str])
	# TODO: Animation of die roll.
	pass

func _on_shuffle_deck_event(event_data):
	var active_player = get_player(event_data["shuffling_player_id"])
	game_log.add_to_log(GameLog.GameLogLine.Detail, "%s shuffles deck" % [
		active_player.get_name()
	])
	# TODO: Animation - Shuffle the deck
	_play_popup_message("Shuffling Deck", true)
	pass

func _on_oshi_skill_activation(event_data):
	var active_player = get_player(event_data["oshi_player_id"])
	var skill_id = event_data["skill_id"]
	var logline = "%s Oshi Skill [SKILL][%s][/SKILL] activated" % [
		active_player.get_name_decorated(),
		Strings.get_skill_string(skill_id)
	]
	match event_data["limit"]:
		"once_per_turn":
			active_player.used_oshi_turn_skill = true
		"once_per_game":
			active_player.used_oshi_game_skill = true
	game_log.add_to_log(GameLog.GameLogLine.Detail, logline)
	# TODO: Animation - show oshi skill activate and mark once per game/turn somehow.
	if not active_player.is_me() or observer_mode:
		_play_popup_message(tr("Oshi Skill:") + " %s" % Strings.get_skill_string(skill_id))
	pass

func on_performance_step_start(_event_data):
	# Do nothing, because of how players can cancel only
	# notify the start when the first art occurs.
	pass

func notify_performance_step(player_id):
	if not sent_performance_step_notification_this_turn:
		sent_performance_step_notification_this_turn = true
		var active_player = get_player(player_id)
		game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [PHASE]*Performance Step*[/PHASE]" % active_player.get_name())
		# TODO: Animation - performance start
		if not active_player.is_me() or observer_mode:
			_play_popup_message("Performance Step", true)

func _on_turn_start(event_data):
	sent_performance_step_notification_this_turn = false
	var active_player = get_player(event_data["active_player"])
	game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [PHASE]**Turn Start**[/PHASE]" % active_player.get_name())
	# TODO: Animation - show turn phase change
	_play_popup_message("Turn Start", true)
	pass

func _on_end_turn_event(event_data):
	clear_performance_indicators()
	me.clear_played_this_turn()
	opponent.clear_played_this_turn()
	var ending_player = get_player(event_data["ending_player_id"])
	var _next_player_id = get_player(event_data["next_player_id"])
	game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [PHASE]**Turn End**[/PHASE]" % ending_player.get_name())
	# TODO: Animation - show turn phase change
	if not ending_player.is_me() or observer_mode:
		_play_popup_message("Turn End", true)

func _on_force_die_result_event(event_data):
	var active_player = get_player(event_data["effect_player_id"])
	if active_player.is_me() and not observer_mode:
		game_log.add_to_log(GameLog.GameLogLine.Detail, "%s [DECISION]Choice: Choose die result[/DECISION]" % active_player.get_name())
		_begin_make_choice([], 0, 0)
		var instructions = Strings.build_choose_die_result_string()
		action_menu_choice_info = {
			"strings": [
				"1",
				"2",
				"3",
				"4",
				"5",
				"6",
				],
			"enabled": [true, true, true, true, true, true],
			"enable_check": [_allowed, _allowed, _allowed, _allowed, _allowed, _allowed],
		}
		action_menu.show_choices(instructions, action_menu_choice_info, func(choice_index):
			# Submit the choice.
			submit_effect_resolution_make_choice(choice_index)
			_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
		)
	else:
		# Nothing for opponent.
		pass

#
# Submit to server funcs
#

func submit_mulligan_choice(do_it : bool):
	var action = {
		"do_mulligan": do_it
	}
	NetworkManager.send_game_message(Enums.GameAction_Mulligan, action)

func submit_initial_placement(placement_state):
	var action = {
		"center_holomem_card_id": placement_state["center"],
		"backstage_holomem_card_ids": placement_state["backstage"]
	}
	NetworkManager.send_game_message(Enums.GameAction_InitialPlacement, action)

func submit_place_cheer(placements):
	var action = {
		"placements": placements
	}
	NetworkManager.send_game_message(Enums.GameAction_PlaceCheer, action)

func submit_main_step_place_holomem(card_id):
	var action = {
		"card_id": card_id
	}
	NetworkManager.send_game_message(Enums.GameAction_MainStepPlaceHolomem, action)

func submit_main_step_bloom(bloom_card_id, target_card_id):
	var action = {
		"card_id": bloom_card_id,
		"target_id": target_card_id
	}
	NetworkManager.send_game_message(Enums.GameAction_MainStepBloom, action)

func submit_main_step_collab(card_id):
	var action = {
		"card_id": card_id
	}
	NetworkManager.send_game_message(Enums.GameAction_MainStepCollab, action)

func submit_main_step_oshi_skill(skill_id):
	var action = {
		"skill_id": skill_id
	}
	NetworkManager.send_game_message(Enums.GameAction_MainStepOshiSkill, action)

func submit_main_step_play_support(card_id, additional_fields):
	var action = {
		"card_id": card_id
	}
	for key in additional_fields:
		action[key] = additional_fields[key]
	NetworkManager.send_game_message(Enums.GameAction_MainStepPlaySupport, action)

func submit_main_step_baton_pass(card_id, cheer_ids):
	var action = {
		"card_id": card_id,
		"cheer_ids": cheer_ids,
	}
	NetworkManager.send_game_message(Enums.GameAction_MainStepBatonPass, action)

func submit_main_step_begin_performance():
	NetworkManager.send_game_message(Enums.GameAction_MainStepBeginPerformance, {})

func submit_main_step_end_turn():
	NetworkManager.send_game_message(Enums.GameAction_MainStepEndTurn, {})

func submit_performance_step_use_art(performer_id, art_id, target_id):
	var action = {
		"performer_id": performer_id,
		"art_id": art_id,
		"target_id": target_id,
	}
	NetworkManager.send_game_message(Enums.GameAction_PerformanceStepUseArt, action)

func submit_performance_step_end_turn():
	NetworkManager.send_game_message(Enums.GameAction_PerformanceStepEndTurn, {})

func submit_performance_step_cancel():
	NetworkManager.send_game_message(Enums.GameAction_PerformanceStepCancel, {})

func submit_effect_resolution_make_choice(choice_index):
	var action = {
		"choice_index": choice_index
	}
	NetworkManager.send_game_message(Enums.GameAction_EffectResolution_MakeChoice, action)

func submit_choose_new_center(card_id):
	var action = {
		"new_center_card_id": card_id
	}
	NetworkManager.send_game_message(Enums.GameAction_ChooseNewCenter, action)

func submit_effect_resolution_choose_cards_for_effect(card_ids):
	var action = {
		"card_ids": card_ids
	}
	NetworkManager.send_game_message(Enums.GameAction_EffectResolution_ChooseCardsForEffect, action)

func submit_effect_resolution_move_cheer_between_holomems(placements):
	var action = {
		"placements": placements
	}
	NetworkManager.send_game_message(Enums.GameAction_EffectResolution_MoveCheerBetweenHolomems, action)

func submit_effect_resolution_order_cards(card_ids):
	var action = {
		"card_ids": card_ids
	}
	NetworkManager.send_game_message(Enums.GameAction_EffectResolution_OrderCards, action)

#
# Signal callbacks
#
func _on_card_pressed(card_id: String, card : CardBase):
	if can_select_card(card_id):
		select_card(card)

func _on_card_hovered(_card_id : String, card : CardBase, is_hover : bool):
	big_card.visible = is_hover
	if is_hover:
		big_card.copy_graphics(card)

func _on_view_attachments(card_ids : Array):
	var popout_info = {
		"strings": [],
		"enabled": [],
		"enable_check": [],
		"callback": [],
		"order_cards_mode": false,
		"ignore_chooseable_checkbox": true,
	}

	var instructions = Strings.get_string(Strings.ATTACHED_CARDS)
	instructions += " (%s)" % len(card_ids)
	var card_copies = []
	for card_id in card_ids:
		var new_card = create_card(card_id, "", true)
		card_copies.append(new_card)
	archive_card_popout.show_panel(instructions, popout_info, card_copies, [])


func _on_exit_game_button_pressed() -> void:
	NetworkManager.leave_game()
	returning_from_game.emit()

func _on_log_button_pressed() -> void:
	game_log.visible = true

func _on_me_archive_zone_pressed() -> void:
	_show_archive(me)

func _on_opponent_archive_zone_pressed() -> void:
	_show_archive(opponent)

func _show_archive(player : PlayerState):
	var cards = player._archive_zone.get_cards_in_zone()
	var archive_popout_info = {
		"strings": [],
		"enabled": [],
		"enable_check": [],
		"callback": [],
		"order_cards_mode": false,
		"ignore_chooseable_checkbox": true,
	}

	var instructions = Strings.get_string(Strings.OPPONENT_ARCHIVE)
	if player.is_me():
		instructions = Strings.get_string(Strings.YOUR_ARCHIVE)
	instructions += " (%s)" % len(cards)
	var card_copies = []
	for card in cards:
		var card_id = card._card_id
		var new_card = create_card(card_id, "", true)
		card_copies.append(new_card)
		new_card.copy_stats(card)
	archive_card_popout.show_panel(instructions, archive_popout_info, card_copies, [])

func _on_debug_play_last_event_pressed() -> void:
	process_game_event(last_network_event["event_type"], last_network_event)

func _get_game_log_data():
	var log_data = {
		"version": GlobalSettings.get_client_version(),
		"all_events": full_event_log,
		"game_log": game_log.get_text(),
	}
	return log_data

func _on_game_log_save_log_pressed() -> void:
	if OS.has_feature("web"):
		window = JavaScriptBridge.get_interface("window")
		var file_name = "gamelog.json"
		var file_content = JSON.stringify(_get_game_log_data())
		window.saveTextToFile(file_name, file_content)
	else:
		save_file_dialog.visible = true

func _on_save_file_dialog_file_selected(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	var content = JSON.stringify(_get_game_log_data())
	file.store_string(content)

func _on_settings_button_pressed() -> void:
	settings_window.show_settings(true)


func _on_observer_next_event_pressed() -> void:
	_process_next_event()
