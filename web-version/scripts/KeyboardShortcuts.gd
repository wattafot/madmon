extends Node

# KeyboardShortcuts - Global keyboard shortcut system for Menschenmon
# Provides configurable keyboard shortcuts for improved user experience

# =============================================================================
# SHORTCUT DEFINITIONS
# =============================================================================

var shortcuts: Dictionary = {
	# Inventory shortcuts
	"inventory_open": {
		"keys": [KEY_I, KEY_B],
		"description": "Open inventory",
		"action": "open_inventory"
	},
	
	# Battle shortcuts
	"battle_attack_1": {
		"keys": [KEY_1],
		"description": "Select first attack",
		"action": "select_attack_1"
	},
	"battle_attack_2": {
		"keys": [KEY_2],
		"description": "Select second attack",
		"action": "select_attack_2"
	},
	"battle_attack_3": {
		"keys": [KEY_3],
		"description": "Select third attack",
		"action": "select_attack_3"
	},
	"battle_attack_4": {
		"keys": [KEY_4],
		"description": "Select fourth attack",
		"action": "select_attack_4"
	},
	
	# Navigation shortcuts
	"escape": {
		"keys": [KEY_ESCAPE],
		"description": "Cancel/Back",
		"action": "escape"
	},
	"confirm": {
		"keys": [KEY_ENTER, KEY_SPACE],
		"description": "Confirm action",
		"action": "confirm"
	},
	
	# Quick save shortcuts
	"quick_save": {
		"keys": [KEY_F5],
		"description": "Quick save",
		"action": "quick_save"
	},
	"quick_load": {
		"keys": [KEY_F9],
		"description": "Quick load",
		"action": "quick_load"
	},
	
	# Debug shortcuts (only in debug mode)
	"debug_console": {
		"keys": [KEY_QUOTELEFT],  # Backtick key
		"description": "Toggle debug console",
		"action": "toggle_debug_console",
		"debug_only": true
	}
}

# =============================================================================
# PRIVATE VARIABLES
# =============================================================================

var _active_shortcuts: Dictionary = {}
var _shortcut_enabled: bool = true
var _current_context: String = "global"
var _context_stack: Array[String] = []

# =============================================================================
# INITIALIZATION
# =============================================================================

func _ready():
	# Load custom shortcuts
	_load_shortcuts()
	
	# Setup active shortcuts
	_setup_active_shortcuts()
	
	# Register with service locator
	ServiceLocator.register_service("KeyboardShortcuts", self, "system")
	
	# Connect to game state changes
	EventBus.connect_safe("game_state_changed", _on_game_state_changed)
	
	if GameConstants.DEBUG_MODE:
		print("KeyboardShortcuts: Initialized with %d shortcuts" % shortcuts.size())

func _setup_active_shortcuts():
	"""Setup active shortcuts based on context and debug mode."""
	_active_shortcuts.clear()
	
	for shortcut_name in shortcuts:
		var shortcut_data = shortcuts[shortcut_name]
		
		# Skip debug shortcuts if not in debug mode
		if shortcut_data.get("debug_only", false) and not GameConstants.DEBUG_MODE:
			continue
		
		# Check context restriction
		var context = shortcut_data.get("context", "global")
		if context != "global" and context != _current_context:
			continue
		
		_active_shortcuts[shortcut_name] = shortcut_data

# =============================================================================
# INPUT HANDLING
# =============================================================================

func _input(event: InputEvent):
	if not _shortcut_enabled:
		return
	
	# Completely disable shortcuts during dialogue
	if _current_context == "dialogue":
		return
	
	if event is InputEventKey and event.pressed:
		_handle_key_press(event.keycode, event)

func _handle_key_press(keycode: Key, event: InputEventKey):
	"""Handle key press events."""
	for shortcut_name in _active_shortcuts:
		var shortcut_data = _active_shortcuts[shortcut_name]
		var keys = shortcut_data.get("keys", [])
		
		if keycode in keys:
			# Check modifiers if specified
			if _check_modifiers(shortcut_data, event):
				# Special handling for dialog context - don't consume confirm/escape inputs
				if _current_context == "dialogue" and shortcut_data.get("action") in ["confirm", "escape"]:
					return
				
				_execute_shortcut(shortcut_name, shortcut_data)
				get_viewport().set_input_as_handled()
				return

func _check_modifiers(shortcut_data: Dictionary, event: InputEventKey) -> bool:
	"""Check if modifier keys match shortcut requirements."""
	var required_ctrl = shortcut_data.get("ctrl", false)
	var required_shift = shortcut_data.get("shift", false)
	var required_alt = shortcut_data.get("alt", false)
	
	return (event.ctrl_pressed == required_ctrl and 
			event.shift_pressed == required_shift and 
			event.alt_pressed == required_alt)

func _execute_shortcut(shortcut_name: String, shortcut_data: Dictionary):
	"""Execute a keyboard shortcut."""
	var action = shortcut_data.get("action", "")
	
	if GameConstants.DEBUG_MODE:
		print("KeyboardShortcuts: Executing shortcut '%s' -> '%s'" % [shortcut_name, action])
	
	# Execute the action
	match action:
		"open_inventory":
			_open_inventory()
		"select_attack_1":
			_select_attack(1)
		"select_attack_2":
			_select_attack(2)
		"select_attack_3":
			_select_attack(3)
		"select_attack_4":
			_select_attack(4)
		"escape":
			_handle_escape()
		"confirm":
			_handle_confirm()
		"quick_save":
			_quick_save()
		"quick_load":
			_quick_load()
		"toggle_debug_console":
			_toggle_debug_console()
		_:
			# Try to find custom action handler
			_execute_custom_action(action)
	
	# Emit event
	EventBus.emit_safe("shortcut_executed", [shortcut_name, action])

# =============================================================================
# SHORTCUT ACTIONS
# =============================================================================

func _open_inventory():
	"""Open inventory shortcut."""
	var game_state_manager = ServiceLocator.get_service_safe("GameStateManager")
	if game_state_manager:
		if game_state_manager.get_current_state() == GameConstants.GameState.EXPLORING:
			EventBus.notify_ui_action("menu_opened", {"menu_name": "inventory"})
			# Call actual inventory opening logic
			if game_state_manager.has_method("open_inventory"):
				game_state_manager.open_inventory()

func _select_attack(attack_number: int):
	"""Select attack shortcut."""
	if _current_context == "battle":
		var battle_manager = ServiceLocator.get_service_safe("BattleManager")
		if battle_manager and battle_manager.has_method("select_attack_by_number"):
			battle_manager.select_attack_by_number(attack_number - 1)

func _handle_escape():
	"""Handle escape key."""
	match _current_context:
		"battle":
			# Try to flee or cancel action
			EventBus.emit_safe("battle_escape_requested")
		"inventory":
			# Close inventory
			EventBus.emit_safe("inventory_closed")
		"dialogue":
			# Skip dialogue or close
			EventBus.emit_safe("dialogue_skip_requested")
		_:
			# General escape/pause
			EventBus.emit_safe("game_paused")

func _handle_confirm():
	"""Handle confirm key."""
	# In dialog context, don't handle the input - let GameStateManager handle it
	if _current_context == "dialogue":
		return
	
	# This would typically be handled by the UI system
	EventBus.emit_safe("ui_confirm_pressed")

func _quick_save():
	"""Quick save shortcut."""
	var auto_save_manager = ServiceLocator.get_service_safe("AutoSaveManager")
	if auto_save_manager:
		auto_save_manager.force_auto_save()
		EventBus.emit_safe("ui_notification_shown", ["Quick save completed", "info"])

func _quick_load():
	"""Quick load shortcut."""
	var auto_save_manager = ServiceLocator.get_service_safe("AutoSaveManager")
	if auto_save_manager:
		var save_data = auto_save_manager.load_auto_save(0)
		if not save_data.is_empty():
			EventBus.emit_safe("load_requested")
			EventBus.emit_safe("ui_notification_shown", ["Quick load completed", "info"])
		else:
			EventBus.emit_safe("ui_notification_shown", ["No save file found", "warning"])

func _toggle_debug_console():
	"""Toggle debug console."""
	if GameConstants.DEBUG_MODE:
		EventBus.emit_safe("debug_console_toggled")

func _execute_custom_action(action: String):
	"""Execute custom action through event system."""
	EventBus.emit_safe("custom_action_requested", [action])

# =============================================================================
# CONTEXT MANAGEMENT
# =============================================================================

func _on_game_state_changed(old_state, new_state):
	"""Handle game state changes."""
	# Convert state to string for matching (works with any enum)
	var state_name = ""
	if typeof(new_state) == TYPE_INT:
		# Get the GameStateManager enum keys
		var game_state_manager = ServiceLocator.get_service_safe("GameStateManager")
		if game_state_manager:
			# GameStateManager has its own enum, get the key name
			var state_keys = ["EXPLORING", "DIALOGUE", "BATTLE_MENU", "BATTLE", "INVENTORY", "PAUSED"]
			if new_state < state_keys.size():
				state_name = state_keys[new_state]
	
	match state_name:
		"EXPLORING":
			set_context("exploring")
		"BATTLE", "BATTLE_MENU":
			set_context("battle")
		"INVENTORY":
			set_context("inventory")
		"DIALOGUE":
			set_context("dialogue")
		"PAUSED":
			set_context("menu")
		_:
			set_context("global")

func set_context(context: String):
	"""Set the current shortcut context."""
	if _current_context != context:
		_current_context = context
		_setup_active_shortcuts()
		
		# Debug: print("KeyboardShortcuts: Context changed to '%s'" % context)

func push_context(context: String):
	"""Push a new context onto the stack."""
	_context_stack.append(_current_context)
	set_context(context)

func pop_context():
	"""Pop the previous context from the stack."""
	if not _context_stack.is_empty():
		var previous_context = _context_stack.pop_back()
		set_context(previous_context)

func get_context() -> String:
	"""Get the current context."""
	return _current_context

# =============================================================================
# SHORTCUT MANAGEMENT
# =============================================================================

func add_shortcut(name: String, keys: Array, action: String, description: String = "", context: String = "global"):
	"""Add a custom shortcut."""
	shortcuts[name] = {
		"keys": keys,
		"action": action,
		"description": description,
		"context": context
	}
	_setup_active_shortcuts()

func remove_shortcut(name: String):
	"""Remove a shortcut."""
	if name in shortcuts:
		shortcuts.erase(name)
		_setup_active_shortcuts()

func modify_shortcut(name: String, keys: Array):
	"""Modify an existing shortcut's keys."""
	if name in shortcuts:
		shortcuts[name]["keys"] = keys
		_setup_active_shortcuts()

func get_shortcut_info(name: String) -> Dictionary:
	"""Get information about a shortcut."""
	return shortcuts.get(name, {})

func get_all_shortcuts() -> Dictionary:
	"""Get all shortcuts."""
	return shortcuts.duplicate()

func get_active_shortcuts() -> Dictionary:
	"""Get currently active shortcuts."""
	return _active_shortcuts.duplicate()

# =============================================================================
# SETTINGS
# =============================================================================

func set_shortcuts_enabled(enabled: bool):
	"""Enable or disable shortcuts."""
	_shortcut_enabled = enabled
	
	if GameConstants.DEBUG_MODE:
		print("KeyboardShortcuts: %s" % ("Enabled" if enabled else "Disabled"))

func is_shortcuts_enabled() -> bool:
	"""Check if shortcuts are enabled."""
	return _shortcut_enabled

func _load_shortcuts():
	"""Load custom shortcuts from file."""
	var shortcuts_file = FileAccess.open("user://shortcuts.json", FileAccess.READ)
	if shortcuts_file:
		var json_text = shortcuts_file.get_as_text()
		shortcuts_file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_text)
		
		if parse_result == OK:
			var custom_shortcuts = json.data
			
			# Merge custom shortcuts with defaults
			for shortcut_name in custom_shortcuts:
				shortcuts[shortcut_name] = custom_shortcuts[shortcut_name]
			
			if GameConstants.DEBUG_MODE:
				print("KeyboardShortcuts: Loaded custom shortcuts")

func save_shortcuts():
	"""Save current shortcuts to file."""
	var shortcuts_file = FileAccess.open("user://shortcuts.json", FileAccess.WRITE)
	if shortcuts_file:
		shortcuts_file.store_string(JSON.stringify(shortcuts))
		shortcuts_file.close()

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

func key_to_string(keycode: Key) -> String:
	"""Convert keycode to readable string."""
	match keycode:
		KEY_ESCAPE: return "Escape"
		KEY_ENTER: return "Enter"
		KEY_SPACE: return "Space"
		KEY_F1: return "F1"
		KEY_F2: return "F2"
		KEY_F3: return "F3"
		KEY_F4: return "F4"
		KEY_F5: return "F5"
		KEY_F6: return "F6"
		KEY_F7: return "F7"
		KEY_F8: return "F8"
		KEY_F9: return "F9"
		KEY_F10: return "F10"
		KEY_F11: return "F11"
		KEY_F12: return "F12"
		KEY_QUOTELEFT: return "`"
		_: return OS.get_keycode_string(keycode)

func get_shortcut_display_string(shortcut_name: String) -> String:
	"""Get display string for a shortcut."""
	if shortcut_name not in shortcuts:
		return ""
	
	var shortcut_data = shortcuts[shortcut_name]
	var keys = shortcut_data.get("keys", [])
	var description = shortcut_data.get("description", "")
	
	var key_strings: Array[String] = []
	for key in keys:
		key_strings.append(key_to_string(key))
	
	return "%s (%s)" % [description, "/".join(key_strings)]

func print_shortcuts():
	"""Print all shortcuts for debugging."""
	print("Keyboard Shortcuts:")
	for shortcut_name in shortcuts:
		var shortcut_data = shortcuts[shortcut_name]
		var keys = shortcut_data.get("keys", [])
		var description = shortcut_data.get("description", "")
		var context = shortcut_data.get("context", "global")
		
		var key_strings: Array[String] = []
		for key in keys:
			key_strings.append(key_to_string(key))
		
		print("  %s: %s [%s] (%s)" % [shortcut_name, description, "/".join(key_strings), context])

# =============================================================================
# CLEANUP
# =============================================================================

func _exit_tree():
	"""Cleanup on exit."""
	save_shortcuts()
	
	if GameConstants.DEBUG_MODE:
		print("KeyboardShortcuts: Saved shortcuts and shutdown")