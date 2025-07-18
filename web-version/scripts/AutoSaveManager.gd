extends Node

# AutoSaveManager - Automatic save system for Menschenmon
# Handles automatic saving at intervals and important game events

# =============================================================================
# SIGNALS
# =============================================================================

signal auto_save_started
signal auto_save_completed(success: bool)
signal save_data_collected(data: Dictionary)

# =============================================================================
# PROPERTIES
# =============================================================================

@export var auto_save_enabled: bool = true
@export var auto_save_interval: float = 300.0  # 5 minutes
@export var save_on_state_change: bool = true
@export var save_on_inventory_change: bool = true
@export var save_on_battle_end: bool = true
@export var max_auto_save_slots: int = 5

# =============================================================================
# PRIVATE VARIABLES
# =============================================================================

var _auto_save_timer: Timer
var _save_queue: Array[Dictionary] = []
var _is_saving: bool = false
var _last_save_time: float = 0.0
var _save_counter: int = 0

# =============================================================================
# INITIALIZATION
# =============================================================================

func _ready():
	# Create auto-save timer
	_setup_auto_save_timer()
	
	# Connect to game events
	_connect_game_events()
	
	# Register with service locator
	ServiceLocator.register_service("AutoSaveManager", self, "system")
	
	# Load auto-save settings
	_load_auto_save_settings()
	
	if GameConstants.DEBUG_MODE:
		print("AutoSaveManager: Initialized with %d second intervals" % auto_save_interval)

func _setup_auto_save_timer():
	"""Setup the auto-save timer."""
	_auto_save_timer = Timer.new()
	_auto_save_timer.wait_time = auto_save_interval
	_auto_save_timer.timeout.connect(_on_auto_save_timer_timeout)
	_auto_save_timer.autostart = auto_save_enabled
	add_child(_auto_save_timer)

func _connect_game_events():
	"""Connect to relevant game events for auto-saving."""
	# Game state changes
	if save_on_state_change:
		EventBus.connect_safe("game_state_changed", _on_game_state_changed)
	
	# Inventory changes
	if save_on_inventory_change:
		EventBus.connect_safe("item_added", _on_inventory_changed)
		EventBus.connect_safe("item_removed", _on_inventory_changed)
		EventBus.connect_safe("item_used", _on_inventory_changed)
	
	# Battle events
	if save_on_battle_end:
		EventBus.connect_safe("battle_ended", _on_battle_ended)
	
	# Manual save requests
	EventBus.connect_safe("save_requested", _on_manual_save_requested)

# =============================================================================
# AUTO-SAVE LOGIC
# =============================================================================

func _on_auto_save_timer_timeout():
	"""Handle auto-save timer timeout."""
	if auto_save_enabled and not _is_saving:
		perform_auto_save()

func _on_game_state_changed(old_state: GameConstants.GameState, new_state: GameConstants.GameState):
	"""Handle game state changes."""
	if save_on_state_change:
		queue_auto_save("state_change", {"old_state": old_state, "new_state": new_state})

func _on_inventory_changed(item_id: String = "", quantity: int = 0):
	"""Handle inventory changes."""
	if save_on_inventory_change:
		queue_auto_save("inventory_change", {"item_id": item_id, "quantity": quantity})

func _on_battle_ended(victory: bool):
	"""Handle battle end."""
	if save_on_battle_end:
		queue_auto_save("battle_end", {"victory": victory})

func _on_manual_save_requested():
	"""Handle manual save requests."""
	perform_auto_save("manual")

# =============================================================================
# SAVE QUEUE MANAGEMENT
# =============================================================================

func queue_auto_save(reason: String, context: Dictionary = {}):
	"""Queue an auto-save operation."""
	if not auto_save_enabled:
		return
	
	# Check if we should throttle saves
	var current_time = Time.get_time_dict_from_system()
	var time_since_last = _get_time_diff(current_time)
	
	if time_since_last < 30.0:  # Don't save more than once per 30 seconds
		return
	
	var save_entry = {
		"reason": reason,
		"context": context,
		"timestamp": current_time
	}
	
	_save_queue.append(save_entry)
	
	# Process queue if not already saving
	if not _is_saving:
		_process_save_queue()

func _process_save_queue():
	"""Process the save queue."""
	if _save_queue.is_empty() or _is_saving:
		return
	
	# Get the most recent save request
	var save_entry = _save_queue.pop_back()
	_save_queue.clear()  # Clear queue to avoid spam
	
	# Perform the save
	perform_auto_save(save_entry.reason, save_entry.context)

# =============================================================================
# SAVE OPERATIONS
# =============================================================================

func perform_auto_save(reason: String = "auto", context: Dictionary = {}):
	"""Perform an auto-save operation."""
	if _is_saving:
		return
	
	_is_saving = true
	auto_save_started.emit()
	
	if GameConstants.DEBUG_MODE:
		print("AutoSaveManager: Starting auto-save (reason: %s)" % reason)
	
	# Collect save data
	var save_data = await _collect_save_data(reason, context)
	
	# Save to file
	var success = await _save_to_file(save_data)
	
	_is_saving = false
	_last_save_time = Time.get_time_dict_from_system()["second"]
	_save_counter += 1
	
	auto_save_completed.emit(success)
	
	if GameConstants.DEBUG_MODE:
		if success:
			print("AutoSaveManager: Auto-save completed successfully (#%d)" % _save_counter)
		else:
			print("AutoSaveManager: Auto-save failed")

func _collect_save_data(reason: String, context: Dictionary) -> Dictionary:
	"""Collect save data from all relevant systems."""
	var save_data = {
		"version": "1.0",
		"save_type": "auto",
		"reason": reason,
		"context": context,
		"timestamp": Time.get_datetime_string_from_system(),
		"save_counter": _save_counter
	}
	
	# Collect data from game state manager
	var game_state_manager = ServiceLocator.get_service_safe("GameStateManager")
	if game_state_manager:
		if game_state_manager.has_method("get_save_data"):
			save_data["game_state"] = game_state_manager.get_save_data()
		else:
			save_data["game_state"] = {"current_state": game_state_manager.get_current_state()}
	
	# Collect data from inventory manager
	var inventory_manager = ServiceLocator.get_service_safe("InventoryManager")
	if inventory_manager:
		if inventory_manager.has_method("get_save_data"):
			save_data["inventory"] = inventory_manager.get_save_data()
		else:
			save_data["inventory"] = {
				"items": inventory_manager.get_all_items(),
				"money": inventory_manager.get_money()
			}
	
	# Collect data from battle manager if in battle
	var battle_manager = ServiceLocator.get_service_safe("BattleManager")
	if battle_manager:
		if battle_manager.has_method("get_save_data"):
			save_data["battle"] = battle_manager.get_save_data()
	
	# Emit event for other systems to add data
	save_data_collected.emit(save_data)
	
	return save_data

func _save_to_file(save_data: Dictionary) -> bool:
	"""Save data to file with rotation."""
	var file_path = _get_auto_save_file_path()
	
	# Create backup of existing save
	_rotate_save_files()
	
	# Save new data
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		
		EventBus.notify_info("Auto-save completed")
		return true
	else:
		ErrorHandler.handle_save_error(file_path, FileAccess.get_open_error())
		return false

func _get_auto_save_file_path() -> String:
	"""Get the auto-save file path."""
	return "user://auto_save_%d.dat" % (_save_counter % max_auto_save_slots)

func _rotate_save_files():
	"""Rotate auto-save files to maintain history."""
	# Keep multiple auto-save files for safety
	for i in range(max_auto_save_slots - 1, 0, -1):
		var source_path = "user://auto_save_%d.dat" % (i - 1)
		var dest_path = "user://auto_save_%d.dat" % i
		
		if FileAccess.file_exists(source_path):
			DirAccess.copy_absolute(source_path, dest_path)

# =============================================================================
# SETTINGS MANAGEMENT
# =============================================================================

func _load_auto_save_settings():
	"""Load auto-save settings from file."""
	var settings_file = FileAccess.open("user://auto_save_settings.cfg", FileAccess.READ)
	if settings_file:
		var settings_text = settings_file.get_as_text()
		settings_file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(settings_text)
		
		if parse_result == OK:
			var settings = json.data
			auto_save_enabled = settings.get("enabled", auto_save_enabled)
			auto_save_interval = settings.get("interval", auto_save_interval)
			save_on_state_change = settings.get("save_on_state_change", save_on_state_change)
			save_on_inventory_change = settings.get("save_on_inventory_change", save_on_inventory_change)
			save_on_battle_end = settings.get("save_on_battle_end", save_on_battle_end)
			max_auto_save_slots = settings.get("max_slots", max_auto_save_slots)
			
			# Update timer
			if _auto_save_timer:
				_auto_save_timer.wait_time = auto_save_interval

func save_auto_save_settings():
	"""Save auto-save settings to file."""
	var settings = {
		"enabled": auto_save_enabled,
		"interval": auto_save_interval,
		"save_on_state_change": save_on_state_change,
		"save_on_inventory_change": save_on_inventory_change,
		"save_on_battle_end": save_on_battle_end,
		"max_slots": max_auto_save_slots
	}
	
	var settings_file = FileAccess.open("user://auto_save_settings.cfg", FileAccess.WRITE)
	if settings_file:
		settings_file.store_string(JSON.stringify(settings))
		settings_file.close()

# =============================================================================
# PUBLIC API
# =============================================================================

func set_auto_save_enabled(enabled: bool):
	"""Enable or disable auto-save."""
	auto_save_enabled = enabled
	if _auto_save_timer:
		if enabled:
			_auto_save_timer.start()
		else:
			_auto_save_timer.stop()
	
	save_auto_save_settings()

func set_auto_save_interval(interval: float):
	"""Set auto-save interval in seconds."""
	auto_save_interval = max(30.0, interval)  # Minimum 30 seconds
	if _auto_save_timer:
		_auto_save_timer.wait_time = auto_save_interval
	
	save_auto_save_settings()

func force_auto_save():
	"""Force an immediate auto-save."""
	perform_auto_save("manual_force")

func get_auto_save_info() -> Dictionary:
	"""Get auto-save system information."""
	return {
		"enabled": auto_save_enabled,
		"interval": auto_save_interval,
		"last_save_time": _last_save_time,
		"save_counter": _save_counter,
		"is_saving": _is_saving,
		"queue_size": _save_queue.size()
	}

func get_auto_save_files() -> Array[String]:
	"""Get list of auto-save files."""
	var files: Array[String] = []
	
	for i in range(max_auto_save_slots):
		var file_path = "user://auto_save_%d.dat" % i
		if FileAccess.file_exists(file_path):
			files.append(file_path)
	
	return files

func load_auto_save(slot: int = 0) -> Dictionary:
	"""Load auto-save data from specific slot."""
	var file_path = "user://auto_save_%d.dat" % slot
	
	if not FileAccess.file_exists(file_path):
		ErrorHandler.log_error("Auto-save file does not exist: %s" % file_path, ErrorHandler.ErrorType.FILE_IO)
		return {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		ErrorHandler.handle_file_load_error(file_path)
		return {}
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result == OK:
		return json.data
	else:
		ErrorHandler.log_error("Failed to parse auto-save file: %s" % file_path, ErrorHandler.ErrorType.FILE_IO)
		return {}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

func _get_time_diff(current_time: Dictionary) -> float:
	"""Get time difference from last save in seconds."""
	if typeof(_last_save_time) == TYPE_FLOAT:
		var current_seconds = current_time.get("hour", 0) * 3600 + current_time.get("minute", 0) * 60 + current_time.get("second", 0)
		return current_seconds - _last_save_time
	else:
		return 999.0  # Force save if no previous time

func _exit_tree():
	"""Cleanup on exit."""
	# Save settings
	save_auto_save_settings()
	
	# Perform final save if needed
	if auto_save_enabled and not _is_saving:
		perform_auto_save("shutdown")
	
	if GameConstants.DEBUG_MODE:
		print("AutoSaveManager: Shutdown with %d saves performed" % _save_counter)