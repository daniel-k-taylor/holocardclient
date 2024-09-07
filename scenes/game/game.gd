class_name Game
extends Node2D

signal returning_from_game

const CardBaseScene = preload("res://scenes/game/card_base.tscn")

@onready var message_box : RichTextLabel = $MessageHistory
@onready var action_menu : ActionMenu = $ActionMenu
@onready var all_cards : Node2D = $AllCards

@onready var thinking_spinner : TextureProgressBar = $ThinkingSpinner

@onready var opponent_stats : StatsGroup = $OpponentStatsGroup
@onready var me_stats : StatsGroup = $MeStatsGroup

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

@onready var floating_zone : CardZone = $FloatingCardZone

@onready var me_archive: CardZone = $MeArchive
@onready var me_center : CardZone = $MeCenter
@onready var me_collab : CardZone = $MeCollab
@onready var me_backstage : CardZone = $MeBackstage
@onready var me_oshi : CardZone = $MeOshi
@onready var me_hand : CardZone = $MeHand

@onready var card_popout : CardPopout = $CardPopout

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

	var hand_count = 0
	var deck_count = Enums.DECK_SIZE
	var life_count = 0
	var cheer_count = Enums.CHEER_SIZE
	var holopower_count = 0

	var _archive_zone : CardZone
	var _backstage_zone : CardZone
	var _center_zone : CardZone
	var _collab_zone : CardZone
	var _hand_zone : CardZone
	var _oshi_zone : CardZone
	var _floating_zone : CardZone

	var stage_zones = []

	func _init(game, player_id:String, is_local_player : bool,
		archive_zone, backstage_zone, collab_zone,
		center_zone, oshi_zone, hand_zone,
		floating_zone
	):
		_game = game
		_player_id = player_id
		_is_me = is_local_player

		_archive_zone = archive_zone
		_archive_zone.set_layout_style(CardZone.LayoutStyle.Archive)
		_hand_zone = hand_zone
		if _hand_zone:
			_hand_zone.set_layout_style(CardZone.LayoutStyle.Hand)
		_center_zone = center_zone
		_collab_zone = collab_zone
		_backstage_zone = backstage_zone
		_backstage_zone.set_layout_style(CardZone.LayoutStyle.Backstage)
		_oshi_zone = oshi_zone
		_floating_zone = floating_zone

		stage_zones = [center_zone, collab_zone, oshi_zone]

	func is_me() -> bool:
		return _is_me

	func draw_cards(count, cards : Array):
		hand_count += count
		deck_count -= count

		for card in cards:
			if _hand_zone:
				_hand_zone.add_card(card)

	func get_archive_count() -> int:
		return len(_archive_zone.get_cards_in_zone())

	func get_hand_count() -> int:
		return hand_count

	func remove_from_archive(card_id : String):
		_archive_zone.remove_card(card_id)

	func add_card_to_archive(card:CardBase):
		_archive_zone.add_card(card)

	func add_card_to_hand(card : CardBase):
		hand_count += 1
		if _hand_zone:
			_hand_zone.add_card(card)
		else:
			# TODO: Animation then
			_game.destroy_card(card)

	func remove_from_hand(card_id : String):
		hand_count -= 1
		if _hand_zone:
			_hand_zone.remove_card(card_id)

	func get_card_ids_in_hand(card_types: Array):
		var matched_ids = []
		for card in _hand_zone.get_cards_in_zone():
			var card_data = CardDatabase.get_card(card._definition_id)
			if card_data["card_type"] in card_types:
				matched_ids.append(card._card_id)
		return matched_ids

	func add_card_to_deck(card : CardBase):
		deck_count += 1
		if card:
			# TODO: Animation to something then destroy card.
			_game.destroy_card(card)

	func remove_card_from_deck(_card_id : String):
		deck_count -= 1

	func add_card_to_cheer_deck(card : CardBase):
		cheer_count += 1
		if card:
			#TODO: Animation
			_game.destroy(card)

	func remove_card_from_cheer_deck(_card_id : String):
		cheer_count -= 1

	func is_zone_visible(to_zone : String):
		if to_zone in ["archive", "backstage", "center", "collab", "oshi"]:
			return true
		if to_zone == "hand" and _hand_zone:
			return true
		return false

	func add_backstage(card : CardBase):
		_backstage_zone.add_card(card)

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
			if zone.remove_card(target_card_id):
				zone.add_card(new_card)
				break

	func bloom(bloom_card_id, target_card_id, from_zone):
		if from_zone == "hand":
			remove_from_hand(bloom_card_id)
		else:
			assert(false, "Unimplemented")

		# The bloom card will always show up, so find/create it.
		var bloom_card = _game.find_card_on_board(bloom_card_id)
		if not bloom_card:
			bloom_card = _game.create_card(bloom_card_id)

		# Figure out where the target card is and replace it.
		replace_card_on_stage(target_card_id, bloom_card)

		# TODO: Somehow attach the target card to the bloom card.
		# The target card is no longer need so delete it.
		var target_card = _game.find_card_on_board(target_card_id)
		if target_card:
			_game.destroy_card(target_card)

	func generate_holopower(holopower_generated):
		holopower_count += holopower_generated

	func remove_holopower(removed_count):
		holopower_count -= removed_count

	func set_oshi(oshi_id : String):
		var oshi_card_id = _player_id + "_oshi"
		var card = _game.create_card(oshi_card_id, oshi_id)
		_oshi_zone.add_card(card)

	func set_starting_life(starting_life_count):
		life_count = starting_life_count

	func set_starting_cheer(starting_cheer_count):
		cheer_count = starting_cheer_count

var me : PlayerState
var opponent : PlayerState

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NetworkManager.connect("disconnected_from_server", _on_disconnected)

	action_menu.visible = false
	thinking_spinner.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	thinking_spinner.radial_initial_angle += delta * 360

func begin_remote_game(event_type, event_data):
	Logger.log_game("Starting game!")
	handle_game_event(event_type, event_data)

func handle_game_event(event_type, event_data):
	Logger.log_game("Received game event: %s\n%s" % [event_type, event_data])
	_append_to_messages(event_type)

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
		Enums.EventType_Decision_ChooseCards:
			pass
		Enums.EventType_Decision_MainStep:
			_on_main_step_decision(event_data)
		Enums.EventType_Decision_MoveCheerChoice:
			pass
		Enums.EventType_Decision_OrderCards:
			pass
		Enums.EventType_Decision_PerformanceStep:
			_on_performance_step_decision(event_data)
		Enums.EventType_Decision_SendCheer:
			pass
		Enums.EventType_Decision_SwapHolomemToCenter:
			_on_swap_holomem_to_center_event(event_data)
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
		Enums.EventType_InitialPlacementBegin:
			_on_initial_placement_begin(event_data)
		Enums.EventType_InitialPlacementPlaced:
			_on_initial_placement_placed(event_data)
		Enums.EventType_InitialPlacementReveal:
			_on_initial_placement_revealed(event_data)
		Enums.EventType_MainStepStart:
			_on_main_step_start(event_data)
		Enums.EventType_MoveCard:
			_on_move_card_event(event_data)
		Enums.EventType_MoveCheer:
			_on_move_cheer_event(event_data)
		Enums.EventType_MulliganDecision:
			_on_mulligan_decision_event(event_data)
		Enums.EventType_MulliganReveal:
			_on_mulligan_reveal_event(event_data)
		Enums.EventType_OshiSkillActivation:
			_on_oshi_skill_activation(event_data)
		Enums.EventType_PerformanceStepStart:
			_on_turn_phase_update(event_data)
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
		Enums.EventType_RollDie:
			_on_roll_die_event(event_data)
		Enums.EventType_ShuffleDeck:
			_on_shuffle_deck_event(event_data)
		Enums.EventType_TurnStart:
			_on_turn_phase_update(event_data)
		_:
			Logger.log_game("Unknown event type: %s" % event_type)
			assert(false)

	_update_ui()

func _on_disconnected():
	_append_to_messages("disconnected")

func _append_to_messages(message):
	message_box.text += "\n" + message


func _get_card_definition_id(card_id):
	for key in game_card_map:
		if key == card_id:
			return game_card_map[key]
	return null

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
	}
	stats_group.update_stats(stats_info)

func _update_ui():
	_update_player_stats(me, me_stats)
	_update_player_stats(opponent, opponent_stats)

func _on_game_error(event_data):
	var _error_id = event_data["error_id"]
	var _error_message = event_data["error_message"]
	# TODO: Show a message box.
	pass

func _on_game_over(event_data):
	var _winner_id = event_data["winner_id"]
	var _loser_id = event_data["loser_id"]
	var _reason_id = event_data["reason_id"]
	# TODO: Indicate game over.
	pass

func _begin_game(event_data):
	starting_player_id = event_data["starting_player"]
	var my_id = event_data["your_id"]
	var opponent_id = event_data["opponent_id"]
	game_card_map = event_data["game_card_map"]

	me = PlayerState.new(self, my_id, true,
		me_archive, me_backstage, me_collab,
		me_center, me_oshi, me_hand,
		floating_zone
	)
	opponent = PlayerState.new(self, opponent_id, false,
		opponent_archive, opponent_backstage, opponent_collab,
		opponent_center, opponent_oshi, null,
		floating_zone
	)

func create_card(card_id : String, definition_id_for_oshi : String = "", skip_add_to_all : bool = false) -> CardBase:
	assert(card_id != "HIDDEN")
	var definition_id = definition_id_for_oshi
	var card_type = "oshi"
	if definition_id_for_oshi:
		definition_id = definition_id_for_oshi
	else:
		definition_id = _get_card_definition_id(card_id)
		var definition = CardDatabase.get_card(definition_id)
		card_type = definition["card_type"]
	var new_card : CardBase = CardBaseScene.instantiate()
	new_card.create_card(definition_id, card_id, card_type)
	new_card.connect("clicked_card", _on_card_pressed)
	if not skip_add_to_all:
		all_cards.add_child(new_card)
		new_card.initialize_graphics()
	return new_card

func destroy_card(card : CardBase) -> void:
	if card:
		all_cards.remove_child(card)

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
	for card_graphic in selected_cards:
		card_graphic.set_selected(false)
		card_graphic.set_info_highlight(false)
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

#
# Game Event Handlers
#

func _on_add_turn_effect(event_data):
	var _active_player = get_player(event_data["effect_player_id"])
	var _turn_effect = event_data["turn_effect"]
	# TODO: Animation for turn effect being added / permanent indicator somewhere?
	pass

func _on_bloom_event(event_data):
	var active_player = get_player(event_data["bloom_player_id"])
	var bloom_card_id = event_data["bloom_card_id"]
	var target_card_id = event_data["target_card_id"]
	var bloom_from_zone = event_data["bloom_from_zone"]
	active_player.bloom(bloom_card_id, target_card_id, bloom_from_zone)

func _on_boost_stat_event(event_data):
	var _card_id = event_data["card_id"]
	var _stat = event_data["stat"]
	var _amount = event_data["amount"]
	# TODO: Animation - show stat boost.
	pass

func _on_cheer_step(event_data):
	var active_player = get_player(event_data["active_player"])
	# TODO: Animation for Cheer Step
	if active_player.is_me():
		var cheer_to_place = event_data["cheer_to_place"]
		var source = event_data["source"]
		var options = event_data["options"]

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
	var active_player = event_data["effect_player_id"]
	if active_player.is_me():
		_begin_make_choice([], 0, 0)
		var instructions = Strings.get_string(Strings.DECISION_INSTRUCTIONS_SEND_COLLAB_BACK)
		action_menu_choice_info = {
			"strings": [Strings.get_string(Strings.STRING_YES), Strings.get_string(Strings.STRING_NO)],
			"enabled": [true, true],
			"enable_check": [_allowed, _allowed],
		}
		action_menu.show_choices(instructions, action_menu_choice_info, func(choice_index):
			# 0 is Yes, 1 is No
			submit_effect_resolution_make_choice(choice_index)
			_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
		)


func _on_collab_event(event_data):
	var active_player = get_player(event_data["collab_player_id"])
	var collab_card_id = event_data["collab_card_id"]
	var holopower_generated = event_data["holopower_generated"]
	do_move_cards(active_player, "backstage", "collab", "", [collab_card_id])
	active_player.generate_holopower(holopower_generated)

func _on_main_step_decision(event_data):
	var active_player = get_player(event_data["active_player"])
	if active_player.is_me():
		var available_actions = event_data["available_actions"]
		action_menu_choice_info = {
			"strings": [],
			"enabled": [],
			"enable_check": [],
			"action_type": [],
			"valid_actions": [],
		}
		var current_action_type_index = -1
		for action in available_actions:
			if action["action_type"] not in action_menu_choice_info["action_type"]:
				action_menu_choice_info["strings"].append(Strings.get_action_name(action["action_type"]))
				action_menu_choice_info["enabled"].append(true)
				action_menu_choice_info["enable_check"].append(_allowed)
				action_menu_choice_info["action_type"].append(action["action_type"])
				current_action_type_index += 1
				action_menu_choice_info["valid_actions"].append([action])
			else:
				# For actions with multiple instances, keep them all for validation later.
				action_menu_choice_info["valid_actions"][current_action_type_index].append(action)

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
	var active_player = get_player(event_data["active_player"])
	if active_player.is_me():
		var available_actions = event_data["available_actions"]
		action_menu_choice_info = {
			"strings": [],
			"enabled": [],
			"enable_check": [],
			"action_type": [],
			"valid_actions": [],
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

		_begin_make_choice([], 0, 0)
		var instructions = Strings.get_string(Strings.DECISION_INSTRUCTIONS_PERFORMANCE_STEP)
		action_menu.show_choices(instructions, action_menu_choice_info, func(choice_index):
			var chosen_action = available_actions[choice_index]
			var valid_targets = chosen_action["valid_targets"]
			if len(valid_targets) == 1:
				var target_id = valid_targets[0]
				submit_performance_step_use_art(chosen_action["performer_id"], chosen_action["art_id"], target_id)
				_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
			else:
				# Need to select between the targets.
				# TODO: Save off the chosen action for later.
				# Choose between targets
				# Cancel goes back to here.
		)
	else:
		# Nothing for opponent.
		pass

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

func _show_click_cards_cancelable_action_menu(card_ids, callback, instructions_id):
	_change_ui_phase(UIPhase.UIPhase_ClickCardsForAction)
	_highlight_selectable_cards(card_ids)

	click_cards_actions_remaining = [{
		"callback": callback
	}]

	action_menu_choice_info = {
		"strings": [Strings.get_string(Strings.STRING_CANCEL)],
		"enabled": [true],
		"enable_check": [_allowed]
	}
	var instructions = Strings.get_string(instructions_id)
	action_menu.show_choices(instructions, action_menu_choice_info, func(_choice_index):
		# Must be a cancel.
		_cancel_to_main_step()
	)

func _cancel_to_main_step():
	action_menu_choice_info = main_step_action_data
	_start_main_step_decision()

func _show_popout(instructions : String, card_ids : Array, required_count : int, callback : Callable):
	# Also show the action menu with two buttons: Show Choice and Cancel
	_change_ui_phase(UIPhase.UIPhase_MakeChoiceCanSelectCards)

	action_menu_choice_info = {
			"strings": [
				Strings.get_string(Strings.STRING_SHOW_CHOICE),
				Strings.get_string(Strings.STRING_CANCEL),
			],
			"enabled": [true, true],
			"enable_check": [_allowed, _allowed]
	}

	selection_max = required_count
	selection_min = required_count
	card_popout_choice_info = {
		"strings": [
			Strings.get_string(Strings.STRING_OK),
			Strings.get_string(Strings.STRING_CANCEL),
		],
		"enabled": [required_count == 0, true],
		"enable_check": [_is_selection_requirement_met, _allowed],
		"callback": [callback, _cancel_to_main_step],
	}

	action_menu.show_choices(instructions, action_menu_choice_info, func(choice_index):
		if choice_index == 0:
			# Re-show the popout.
			card_popout.visible = true
			action_menu.visible = true
		else:
			# Cancel
			_cancel_to_main_step()
	)

	var card_copies = []
	selectable_card_ids = []
	for card_id in card_ids:
		var new_card = create_card(card_id, "", true)
		card_copies.append(new_card)
		selectable_card_ids.append(card_id)
	card_popout.show_panel(instructions, card_popout_choice_info, card_copies)

func _get_main_step_actions(action_type):
	for i in range(len(main_step_action_data["action_type"])):
		if main_step_action_data["action_type"][i] == action_type:
			return main_step_action_data["valid_actions"][i]
	assert(false, "Action type expected but not found.")

func _on_main_step_action_chosen(choice_index):
	# Save action data in case the user cancels.
	main_step_action_data = action_menu_choice_info
	var chosen_action_type = action_menu_choice_info["action_type"][choice_index]
	var valid_actions = _get_main_step_actions(chosen_action_type)
	match chosen_action_type:
		Enums.GameAction_MainStepPlaceHolomem:
			# The valid actions have all holomems that are selectable to place.
			var valid_card_ids = []
			for action in valid_actions:
				valid_card_ids.append(action["card_id"])
			_show_click_cards_cancelable_action_menu(
				valid_card_ids,
				_place_holomem_backstage,
				Strings.DECISION_INSTRUCTIONS_PLACE_HOLOMEM
			)
		Enums.GameAction_MainStepBloom:
			# The valid actions have all combinations of bloom and target.
			# First, select a card to bloom from hand.
			# After that, you can select amongst the valid targets.
			var valid_card_ids = []
			for action in valid_actions:
				valid_card_ids.append(action["card_id"])
			_show_click_cards_cancelable_action_menu(
				valid_card_ids,
				_bloom_target_selection,
				Strings.DECISION_INSTRUCTIONS_CHOOSE_BLOOM
			)
		Enums.GameAction_MainStepCollab:
			# The valid actions have all holomems that are selectable to collab.
			var valid_card_ids = []
			for action in valid_actions:
				valid_card_ids.append(action["card_id"])
			_show_click_cards_cancelable_action_menu(
				valid_card_ids,
				_collab_holomem,
				Strings.DECISION_INSTRUCTIONS_COLLAB
			)
		# Enums.GameAction_MainStepOshiSkill:
		# 	_on_main_step_oshi_skill()
		# Enums.GameAction_MainStepPlaySupport:
		# 	_on_main_step_play_support()
		Enums.GameAction_MainStepBatonPass:
			# There is only one possible action for baton pass and
			# it has the backstage options and cheer options in it.
			# First, present the user a card popout with the cheer to select.
			# Once they've selected the required cheer, then they'll pick the backstage to swap.
			var cost = valid_actions[0]["cost"]
			var available_cheer = valid_actions[0]["available_cheer"]
			var instructions = Strings.build_archive_cheer_string(cost)
			_show_popout(instructions, available_cheer, cost, _baton_pass_target_selection)
		Enums.GameAction_MainStepBeginPerformance:
			submit_main_step_begin_performance()
			_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
		Enums.GameAction_MainStepEndTurn:
			submit_main_step_end_turn()
			_change_ui_phase(UIPhase.UIPhase_WaitingOnServer)
		_:
			assert(false, "Unknown action type")

func _on_swap_holomem_to_center_event(event_data):
	var active_player = get_player(event_data["effect_player_id"])
	var cards_can_choose = event_data["cards_can_choose"]
	#var is_opponent = event_data["swap_opponent_cards"]
	if active_player.is_me():
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

func _on_draw_event(event_data):
	var drawn_card_ids = event_data["drawn_card_ids"]
	var active_player = get_player(event_data["drawing_player_id"])
	var created_cards = []
	if active_player.is_zone_visible("hand"):
		for card_id in drawn_card_ids:
			created_cards.append(create_card(card_id))
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
			move_card_ids_already_handled.append(multi_step_decision_info)
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
	var actions = _get_main_step_actions(Enums.GameAction_MainStepBloom)
	var valid_targets = []
	for action in actions:
		if action["card_id"] == bloom_card_id:
			valid_targets.append(action["target_id"])

	# Now select the target.
	_show_click_cards_cancelable_action_menu(
		valid_targets,
		_bloom_target_completed,
		Strings.DECISION_INSTRUCTIONS_CHOOSE_BLOOM
	)
	_highlight_info_cards([bloom_card_id])

func _baton_pass_target_selection():
	var card_ids = []
	for card in selected_cards:
		card_ids.append(card._card_id)
	multi_step_decision_info = {
		"card_ids": card_ids
	}
	var actions = _get_main_step_actions(Enums.GameAction_MainStepBatonPass)
	var target_card_ids = actions[0]["backstage_options"]

	# Now select the target.
	_show_click_cards_cancelable_action_menu(
		target_card_ids,
		_baton_pass_holomem_complete,
		Strings.DECISION_INSTRUCTIONS_CHOOSE_BLOOM
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
	ui_phase = new_ui_phase
	if new_ui_phase == UIPhase.UIPhase_WaitingOnServer:
		thinking_spinner.visible = true
	else:
		thinking_spinner.visible = false
	_update_ui()

func _on_initial_placement_begin(event_data):
	var active_player = get_player(event_data["active_player"])
	if active_player.is_me():
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
	if active_player.is_me():
		# The initial placemetn should have probably already moved and updated everything.
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

		if not active_player.is_me():
			# Local player is done on initial placement
			do_move_cards(active_player, "hand", "center", "", [center_card_id])
			do_move_cards(active_player, "hand", "backstage", "", backstage_card_ids)
			# TODO: Fix later, but hand count was updated in placement
			active_player.hand_count += (1 + len(backstage_card_ids))
		active_player.set_oshi(oshi_id)
		active_player.set_starting_cheer(cheer_deck_count)
		active_player.set_starting_life(life_count)
		print("Mine: %s  Info: %s" % [active_player.hand_count, hand_count])
		assert(active_player.hand_count == hand_count)

func _on_main_step_start(_event_data):
	# TODO: Play an animation for main step starting.
	pass

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

	if not already_handled:
		do_move_cards(active_player, from_zone, to_zone, zone_card_id, [card_id])

func do_move_cards(player, from, to, zone_card_id, card_ids):
	var visible_to_zone = player.is_zone_visible(to)
	for card_id in card_ids:
		match from:
			"archive":
				player.remove_from_archive(card_id)
			"backstage":
				player.remove_backstage(card_id)
			"center":
				player.remove_center(card_id)
			"cheer_deck":
				player.remove_card_from_cheer_deck(card_id)
			"collab":
				player.remove_collab(card_id)
			"deck":
				player.remove_card_from_deck(card_id)
			"floating":
				player.remove_floating(card_id)
			"hand":
				player.remove_from_hand(card_id)
			"holopower":
				player.remove_holopower(1)
			_:
				# Assume this is a holomem card.
				var holomem_from_card = find_card_on_board(from)
				if holomem_from_card:
					holomem_from_card.remove_cheer(card_id)
				else:
					assert(false, "Unexpected from zone")

		var card = find_card_on_board(card_id)
		if not card and visible_to_zone:
			card = create_card(card_id)

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
				# TODO: Animation card to holopower
				destroy_card(card)
			"hand":
				player.add_card_to_hand(card)
			_:
				var holomem_card = find_card_on_board(zone_card_id)
				if holomem_card:
					var cheer_colors = _get_card_colors(card_id)
					holomem_card.attach_cheer(card_id, cheer_colors)
					destroy_card(card)
				else:
					Logger.log_game("Unimplemented MoveCard from zone")
					assert(false)

func _on_move_cheer_event(event_data):
	var active_player= get_player(event_data["owning_player_id"])
	var from_holomem_id = event_data["from_holomem_id"]
	var to_holomem_id = event_data["to_holomem_id"]
	var cheer_id = event_data["cheer_id"]
	do_move_cards(active_player, from_holomem_id, to_holomem_id, to_holomem_id, [cheer_id])

func _on_mulligan_decision_event(event_data):
	var active_player = get_player(event_data["active_player"])
	if active_player.is_me():
		action_menu_choice_info = {
			"strings": [
				Strings.get_string(Strings.STRING_YES),
				Strings.get_string(Strings.STRING_NO),
			],
			"enabled": [true, true],
			"enable_check": [_allowed, _allowed]
		}
		_begin_make_choice([], 0, 0)
		action_menu.show_choices(Strings.get_string(Strings.DECISION_INSTRUCTIONS_MULLIGAN), action_menu_choice_info, func(choice_index : int):
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
	var _revealed_card_ids = event_data["revealed_card_ids"]
	if not active_player.is_me():
		# The opponent is revealing us cards they mulliganed from a forced mulligan.
		# TODO: Show the cards somehow.
		pass

func _on_perform_art_event(event_data):
	var _active_player = get_player(event_data["active_player"])
	var _performer_id = event_data["performer_id"]
	var _art_id = event_data["art_id"]
	var target_id = event_data["target_id"]
	var power = event_data["power"]
	var died = event_data["died"]
	var _game_over = event_data["game_over"]

	# TODO: Mark performer as used an art, icon?
	# TODO: Mark target dead with an icon?

	var card = find_card_on_board(target_id)
	card.add_damage(power, died)

func _on_play_support_card_event(event_data):
	var active_player = get_player(event_data["player_id"])
	var card_id = event_data["card_id"]
	var _limited = event_data["limited"]
	do_move_cards(active_player, "hand", "floating", "", [card_id])
	# TODO: Mark limited use somewhere
	pass

func _on_reset_step_activate_event(event_data):
	#var active_player = get_player(event_data["active_player"])
	var activated_cards = event_data["rested_card_ids"]
	# These cards are no longer resting.
	for card_id in activated_cards:
		var card = find_card_on_board(card_id)
		if card:
			card.set_resting(false)
		else:
			assert(false, "Missing card")

func _on_reset_step_choose_new_center_event(event_data):
	var active_player = get_player(event_data["active_player"])
	var center_options = event_data["center_options"]
	if active_player.is_me():
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
		# Do nothing.
		pass


func _on_reset_step_collab_event(event_data):
	var active_player = get_player(event_data["active_player"])
	var activated_cards = event_data["activated_card_ids"]
	# These cards are no longer resting.
	for card_id in activated_cards:
		var card = find_card_on_board(card_id)
		if card:
			card.set_resting(true)
			do_move_cards(active_player, "collab", "backstage", "", [card_id])
		else:
			assert(false, "Missing card")

func _on_roll_die_event(event_data):
	var _active_player = get_player(event_data["effect_player_id"])
	var _die_result = event_data["die_result"]
	var _rigged = event_data["rigged"]
	# TODO: Animation of die roll.
	pass

func _on_shuffle_deck_event(event_data):
	var _active_player = get_player(event_data["shuffling_player_id"])
	# TODO: Animation - Shuffle the deck
	pass

func _on_oshi_skill_activation(event_data):
	var _active_player = get_player(event_data["effect_player_id"])
	var _skill_id = event_data["skill_id"]
	# TODO: Animation - show oshi skill activate and mark once per game/turn somehow.
	pass

func _on_turn_phase_update(event_data):
	var _active_player = get_player(event_data["active_player"])
	# TODO: Animation - show turn phase change
	pass

func _on_end_turn_event(event_data):
	var _ending_player_id = get_player(event_data["ending_player_id"])
	var _next_player_id = get_player(event_data["next_player_id"])
	# TODO: Animation - show turn phase change
	pass

func _on_force_die_result_event(event_data):
	var active_player = get_player(event_data["effect_player_id"])
	var is_oshi_effect = event_data["is_oshi_effect"]
	var oshi_skill_id = event_data["oshi_skill_id"]
	var cost = event_data["cost"]
	if active_player.is_me():
		_begin_make_choice([], 0, 0)
		var skill_name = ""
		if is_oshi_effect:
			skill_name = Strings.get_skill_string(oshi_skill_id)
		var instructions = Strings.build_choose_die_result_string(skill_name, cost)
		action_menu_choice_info = {
			"strings": [
				Strings.get_string(Strings.STRING_PASS),
				"1",
				"2",
				"3",
				"4",
				"5",
				"6",
				],
			"enabled": [true, true, true, true, true, true, true],
			"enable_check": [_allowed, _allowed, _allowed, _allowed, _allowed, _allowed, _allowed],
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

#
# Signal callbacks
#
func _on_card_pressed(card_id: String, card : CardBase):
	if can_select_card(card_id):
		select_card(card)

func _on_exit_game_button_pressed() -> void:
	NetworkManager.leave_game()
	returning_from_game.emit()
