extends Node

# EventBus - Global Event System for Menschenmon
# Provides decoupled communication between game components

# =============================================================================
# GAME STATE EVENTS
# =============================================================================

signal game_state_changed(old_state: GameConstants.GameState, new_state: GameConstants.GameState)
signal game_paused
signal game_resumed
signal game_saved
signal game_loaded

# =============================================================================
# PLAYER EVENTS
# =============================================================================

signal player_moved(new_position: Vector2)
signal player_health_changed(new_health: int, max_health: int)
signal player_level_changed(new_level: int)
signal player_money_changed(new_amount: int)

# =============================================================================
# INVENTORY EVENTS
# =============================================================================

signal inventory_opened
signal inventory_closed
signal item_added(item_id: String, quantity: int)
signal item_removed(item_id: String, quantity: int)
signal item_used(item_id: String, target: Node)
signal item_selected(item_id: String)
signal category_changed(category: String)

# =============================================================================
# BATTLE EVENTS
# =============================================================================

signal battle_started(enemy_id: String)
signal battle_ended(victory: bool)
signal battle_escaped
signal turn_started(is_player_turn: bool)
signal turn_ended(is_player_turn: bool)
signal attack_selected(attack_name: String)
signal damage_dealt(damage: int, is_critical: bool, target: Node)
signal healing_done(heal_amount: int, target: Node)
signal status_effect_applied(effect_name: String, target: Node)
signal status_effect_removed(effect_name: String, target: Node)

# =============================================================================
# UI EVENTS
# =============================================================================

signal ui_button_pressed(button_name: String)
signal ui_menu_opened(menu_name: String)
signal ui_menu_closed(menu_name: String)
signal ui_selection_changed(selection: String)
signal ui_confirmation_requested(message: String)
signal ui_notification_shown(message: String, type: String)

# =============================================================================
# DIALOGUE EVENTS
# =============================================================================

signal dialogue_started(npc_name: String)
signal dialogue_ended
signal dialogue_line_changed(line: String)
signal dialogue_choice_selected(choice_index: int)

# =============================================================================
# AUDIO EVENTS
# =============================================================================

signal music_requested(track_name: String)
signal sfx_requested(sound_name: String)
signal volume_changed(bus_name: String, volume: float)

# =============================================================================
# ANIMATION EVENTS
# =============================================================================

signal animation_started(animation_name: String, target: Node)
signal animation_finished(animation_name: String, target: Node)
signal screen_shake_requested(intensity: float, duration: float)
signal screen_flash_requested(color: Color, duration: float)

# =============================================================================
# SAVE/LOAD EVENTS
# =============================================================================

signal save_requested
signal load_requested
signal save_completed(success: bool)
signal load_completed(success: bool)

# =============================================================================
# ERROR EVENTS
# =============================================================================

signal error_occurred(error_message: String, error_type: String)
signal warning_occurred(warning_message: String)

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

func emit_safe(signal_name: String, args: Array = []):
	"""Safely emit a signal with error handling."""
	if not has_signal(signal_name):
		push_error("EventBus: Signal '%s' does not exist" % signal_name)
		return
	
	match args.size():
		0: get(signal_name).emit()
		1: get(signal_name).emit(args[0])
		2: get(signal_name).emit(args[0], args[1])
		3: get(signal_name).emit(args[0], args[1], args[2])
		4: get(signal_name).emit(args[0], args[1], args[2], args[3])
		_: push_error("EventBus: Too many arguments for signal '%s'" % signal_name)

func connect_safe(signal_name: String, callable: Callable, flags: int = 0):
	"""Safely connect a signal with error handling."""
	if not has_signal(signal_name):
		push_error("EventBus: Signal '%s' does not exist" % signal_name)
		return false
	
	if get(signal_name).is_connected(callable):
		push_warning("EventBus: Signal '%s' is already connected to callable" % signal_name)
		return false
	
	get(signal_name).connect(callable, flags)
	return true

func disconnect_safe(signal_name: String, callable: Callable):
	"""Safely disconnect a signal with error handling."""
	if not has_signal(signal_name):
		push_error("EventBus: Signal '%s' does not exist" % signal_name)
		return false
	
	if not get(signal_name).is_connected(callable):
		push_warning("EventBus: Signal '%s' is not connected to callable" % signal_name)
		return false
	
	get(signal_name).disconnect(callable)
	return true

func get_signal_connections(signal_name: String) -> Array:
	"""Get all connections for a signal."""
	if not has_signal(signal_name):
		push_error("EventBus: Signal '%s' does not exist" % signal_name)
		return []
	
	return get(signal_name).get_connections()

func disconnect_all_from_signal(signal_name: String):
	"""Disconnect all connections from a signal."""
	if not has_signal(signal_name):
		push_error("EventBus: Signal '%s' does not exist" % signal_name)
		return
	
	var connections = get_signal_connections(signal_name)
	for connection in connections:
		get(signal_name).disconnect(connection.callable)

func log_event(event_name: String, data: Dictionary = {}):
	"""Log an event for debugging purposes."""
	if GameConstants.DEBUG_MODE:
		var log_message = "EventBus: %s" % event_name
		if not data.is_empty():
			log_message += " - %s" % data
		print(log_message)

# =============================================================================
# CONVENIENCE FUNCTIONS
# =============================================================================

func notify_game_state_change(old_state: GameConstants.GameState, new_state: GameConstants.GameState):
	log_event("game_state_changed", {"old": old_state, "new": new_state})
	game_state_changed.emit(old_state, new_state)

func notify_item_action(action: String, item_id: String, quantity: int = 1):
	log_event("item_action", {"action": action, "item": item_id, "quantity": quantity})
	match action:
		"added":
			item_added.emit(item_id, quantity)
		"removed":
			item_removed.emit(item_id, quantity)
		"used":
			item_used.emit(item_id, null)

func notify_battle_action(action: String, data: Dictionary = {}):
	log_event("battle_action", {"action": action, "data": data})
	match action:
		"started":
			battle_started.emit(data.get("enemy_id", ""))
		"ended":
			battle_ended.emit(data.get("victory", false))
		"escaped":
			battle_escaped.emit()
		"damage":
			damage_dealt.emit(data.get("damage", 0), data.get("critical", false), data.get("target"))
		"healing":
			healing_done.emit(data.get("amount", 0), data.get("target"))

func notify_ui_action(action: String, data: Dictionary = {}):
	log_event("ui_action", {"action": action, "data": data})
	match action:
		"button_pressed":
			ui_button_pressed.emit(data.get("button_name", ""))
		"menu_opened":
			ui_menu_opened.emit(data.get("menu_name", ""))
		"menu_closed":
			ui_menu_closed.emit(data.get("menu_name", ""))
		"selection_changed":
			ui_selection_changed.emit(data.get("selection", ""))

func notify_audio_request(type: String, name: String):
	log_event("audio_request", {"type": type, "name": name})
	match type:
		"music":
			music_requested.emit(name)
		"sfx":
			sfx_requested.emit(name)

func notify_animation_request(type: String, data: Dictionary = {}):
	log_event("animation_request", {"type": type, "data": data})
	match type:
		"screen_shake":
			screen_shake_requested.emit(data.get("intensity", 5.0), data.get("duration", 0.5))
		"screen_flash":
			screen_flash_requested.emit(data.get("color", Color.WHITE), data.get("duration", 0.3))

func notify_error(message: String, error_type: String = "generic"):
	log_event("error", {"message": message, "type": error_type})
	error_occurred.emit(message, error_type)

func notify_warning(message: String):
	log_event("warning", {"message": message})
	warning_occurred.emit(message)

# =============================================================================
# INITIALIZATION
# =============================================================================

func _ready():
	# Connect to system signals for debugging
	if GameConstants.DEBUG_MODE:
		# Connect error events to console output
		error_occurred.connect(_on_error_occurred)
		warning_occurred.connect(_on_warning_occurred)
		
		print("EventBus: Initialized with debug mode enabled")

func _on_error_occurred(message: String, error_type: String):
	push_error("EventBus Error [%s]: %s" % [error_type, message])

func _on_warning_occurred(message: String):
	push_warning("EventBus Warning: %s" % message)