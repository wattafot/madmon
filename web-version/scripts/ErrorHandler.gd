extends Node

# ErrorHandler - Comprehensive Error Management for Menschenmon
# Provides fallback systems, error logging, and graceful error handling

# =============================================================================
# ERROR TYPES
# =============================================================================

enum ErrorType {
	GENERIC,
	FILE_IO,
	RESOURCE_LOADING,
	SCENE_LOADING,
	SAVE_LOAD,
	NETWORK,
	AUDIO,
	RENDERING,
	SCRIPT,
	MEMORY
}

# =============================================================================
# ERROR SEVERITY
# =============================================================================

enum ErrorSeverity {
	INFO,
	WARNING,
	ERROR,
	CRITICAL
}

# =============================================================================
# PRIVATE VARIABLES
# =============================================================================

var _error_log: Array[Dictionary] = []
var _max_log_entries: int = 1000
var _fallback_systems: Dictionary = {}
var _error_handlers: Dictionary = {}
var _recovery_strategies: Dictionary = {}

# =============================================================================
# ERROR LOGGING
# =============================================================================

func log_error(message: String, error_type: ErrorType = ErrorType.GENERIC, severity: ErrorSeverity = ErrorSeverity.ERROR, context: Dictionary = {}):
	"""Log an error with context information."""
	var error_entry = {
		"timestamp": Time.get_datetime_string_from_system(),
		"message": message,
		"type": error_type,
		"severity": severity,
		"context": context,
		"stack_trace": get_stack()
	}
	
	_error_log.append(error_entry)
	
	# Limit log size
	if _error_log.size() > _max_log_entries:
		_error_log.pop_front()
	
	# Handle the error based on severity
	_handle_error_by_severity(error_entry)
	
	# Emit event for external handlers
	EventBus.notify_error(message, ErrorType.keys()[error_type])

func log_warning(message: String, context: Dictionary = {}):
	"""Log a warning."""
	log_error(message, ErrorType.GENERIC, ErrorSeverity.WARNING, context)

func log_info(message: String, context: Dictionary = {}):
	"""Log an info message."""
	log_error(message, ErrorType.GENERIC, ErrorSeverity.INFO, context)

func log_critical(message: String, error_type: ErrorType = ErrorType.GENERIC, context: Dictionary = {}):
	"""Log a critical error."""
	log_error(message, error_type, ErrorSeverity.CRITICAL, context)

# =============================================================================
# ERROR HANDLING
# =============================================================================

func _handle_error_by_severity(error_entry: Dictionary):
	"""Handle errors based on their severity."""
	match error_entry.severity:
		ErrorSeverity.INFO:
			if GameConstants.DEBUG_MODE:
				print("INFO: %s" % error_entry.message)
		
		ErrorSeverity.WARNING:
			push_warning("WARNING: %s" % error_entry.message)
			if GameConstants.DEBUG_MODE:
				print("WARNING: %s" % error_entry.message)
		
		ErrorSeverity.ERROR:
			push_error("ERROR: %s" % error_entry.message)
			_try_recovery(error_entry)
		
		ErrorSeverity.CRITICAL:
			push_error("CRITICAL: %s" % error_entry.message)
			_handle_critical_error(error_entry)

func _try_recovery(error_entry: Dictionary):
	"""Try to recover from an error."""
	var error_type = error_entry.type
	
	if error_type in _recovery_strategies:
		var strategy = _recovery_strategies[error_type]
		if strategy.has_method("recover"):
			var success = strategy.recover(error_entry)
			if success:
				log_info("Recovery successful for error: %s" % error_entry.message)
				return
	
	# Try fallback system
	if error_type in _fallback_systems:
		var fallback = _fallback_systems[error_type]
		if fallback.has_method("fallback"):
			fallback.fallback(error_entry)
			log_info("Fallback activated for error: %s" % error_entry.message)

func _handle_critical_error(error_entry: Dictionary):
	"""Handle critical errors that may require immediate attention."""
	# Save error log
	save_error_log()
	
	# Try to save game state
	_emergency_save()
	
	# Show error dialog to user
	_show_error_dialog(error_entry)

# =============================================================================
# FALLBACK SYSTEMS
# =============================================================================

func register_fallback_system(error_type: ErrorType, fallback_system: Node):
	"""Register a fallback system for specific error types."""
	_fallback_systems[error_type] = fallback_system
	
	if GameConstants.DEBUG_MODE:
		print("ErrorHandler: Registered fallback system for %s" % ErrorType.keys()[error_type])

func register_recovery_strategy(error_type: ErrorType, recovery_strategy: Node):
	"""Register a recovery strategy for specific error types."""
	_recovery_strategies[error_type] = recovery_strategy
	
	if GameConstants.DEBUG_MODE:
		print("ErrorHandler: Registered recovery strategy for %s" % ErrorType.keys()[error_type])

# =============================================================================
# SPECIFIC ERROR HANDLERS
# =============================================================================

func handle_file_load_error(file_path: String, fallback_data = null):
	"""Handle file loading errors with fallback data."""
	var context = {"file_path": file_path}
	
	if fallback_data != null:
		log_warning("Could not load file '%s', using fallback data" % file_path, context)
		return fallback_data
	else:
		log_error("Could not load file '%s' and no fallback data provided" % file_path, ErrorType.FILE_IO, ErrorSeverity.ERROR, context)
		return null

func handle_scene_load_error(scene_path: String, fallback_scene_path: String = ""):
	"""Handle scene loading errors with fallback scene."""
	var context = {"scene_path": scene_path, "fallback_scene_path": fallback_scene_path}
	
	if fallback_scene_path != "":
		log_warning("Could not load scene '%s', loading fallback scene '%s'" % [scene_path, fallback_scene_path], context)
		return load(fallback_scene_path)
	else:
		log_error("Could not load scene '%s' and no fallback scene provided" % scene_path, ErrorType.SCENE_LOADING, ErrorSeverity.ERROR, context)
		return null

func handle_resource_load_error(resource_path: String, resource_type: String = ""):
	"""Handle resource loading errors."""
	var context = {"resource_path": resource_path, "resource_type": resource_type}
	log_error("Could not load resource '%s' of type '%s'" % [resource_path, resource_type], ErrorType.RESOURCE_LOADING, ErrorSeverity.ERROR, context)

func handle_save_error(save_path: String, error_code: int):
	"""Handle save operation errors."""
	var context = {"save_path": save_path, "error_code": error_code}
	log_error("Could not save to '%s', error code: %d" % [save_path, error_code], ErrorType.SAVE_LOAD, ErrorSeverity.ERROR, context)

func handle_audio_error(audio_path: String, error_message: String):
	"""Handle audio loading/playing errors."""
	var context = {"audio_path": audio_path, "error_message": error_message}
	log_error("Audio error with '%s': %s" % [audio_path, error_message], ErrorType.AUDIO, ErrorSeverity.WARNING, context)

# =============================================================================
# EMERGENCY PROCEDURES
# =============================================================================

func _emergency_save():
	"""Perform emergency save in case of critical errors."""
	var save_data = _gather_emergency_save_data()
	var save_file = FileAccess.open("user://emergency_save.dat", FileAccess.WRITE)
	if save_file:
		save_file.store_string(JSON.stringify(save_data))
		save_file.close()
		log_info("Emergency save completed")
	else:
		log_error("Emergency save failed", ErrorType.SAVE_LOAD, ErrorSeverity.CRITICAL)

func _gather_emergency_save_data() -> Dictionary:
	"""Gather minimal save data for emergency save."""
	var save_data = {}
	
	# Try to get basic game state
	var game_state_manager = ServiceLocator.get_service_safe("GameStateManager")
	if game_state_manager:
		save_data["game_state"] = game_state_manager.get_current_state()
	
	# Try to get inventory data
	var inventory_manager = ServiceLocator.get_service_safe("InventoryManager")
	if inventory_manager:
		save_data["inventory"] = inventory_manager.get_emergency_save_data()
	
	save_data["timestamp"] = Time.get_datetime_string_from_system()
	return save_data

# =============================================================================
# ERROR DIALOG
# =============================================================================

func _show_error_dialog(error_entry: Dictionary):
	"""Show an error dialog to the user."""
	var dialog = AcceptDialog.new()
	dialog.title = "Error Occurred"
	dialog.dialog_text = "An error occurred: %s\n\nThe game will attempt to continue, but you may want to save your progress." % error_entry.message
	dialog.add_button("View Details", false, "details")
	dialog.add_button("Save Game", false, "save")
	
	get_tree().current_scene.add_child(dialog)
	dialog.popup_centered()
	
	dialog.custom_action.connect(_on_error_dialog_action.bind(error_entry))
	dialog.confirmed.connect(dialog.queue_free)

func _on_error_dialog_action(action: String, error_entry: Dictionary):
	"""Handle error dialog actions."""
	match action:
		"details":
			_show_error_details(error_entry)
		"save":
			_trigger_emergency_save()

func _show_error_details(error_entry: Dictionary):
	"""Show detailed error information."""
	var details_dialog = AcceptDialog.new()
	details_dialog.title = "Error Details"
	details_dialog.dialog_text = "Error: %s\nType: %s\nSeverity: %s\nTime: %s\nContext: %s" % [
		error_entry.message,
		ErrorType.keys()[error_entry.type],
		ErrorSeverity.keys()[error_entry.severity],
		error_entry.timestamp,
		str(error_entry.context)
	]
	
	get_tree().current_scene.add_child(details_dialog)
	details_dialog.popup_centered()
	details_dialog.confirmed.connect(details_dialog.queue_free)

func _trigger_emergency_save():
	"""Trigger emergency save from error dialog."""
	_emergency_save()

# =============================================================================
# ERROR LOG MANAGEMENT
# =============================================================================

func save_error_log():
	"""Save error log to file."""
	var log_file = FileAccess.open("user://error_log.json", FileAccess.WRITE)
	if log_file:
		var log_data = {
			"errors": _error_log,
			"saved_at": Time.get_datetime_string_from_system()
		}
		log_file.store_string(JSON.stringify(log_data))
		log_file.close()

func load_error_log():
	"""Load error log from file."""
	var log_file = FileAccess.open("user://error_log.json", FileAccess.READ)
	if log_file:
		var json_string = log_file.get_as_text()
		log_file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var log_data = json.data
			_error_log = log_data.get("errors", [])

func clear_error_log():
	"""Clear the error log."""
	_error_log.clear()

func get_error_log() -> Array[Dictionary]:
	"""Get the current error log."""
	return _error_log.duplicate()

func get_errors_by_type(error_type: ErrorType) -> Array[Dictionary]:
	"""Get errors of a specific type."""
	var filtered_errors: Array[Dictionary] = []
	for error in _error_log:
		if error.type == error_type:
			filtered_errors.append(error)
	return filtered_errors

func get_errors_by_severity(severity: ErrorSeverity) -> Array[Dictionary]:
	"""Get errors of a specific severity."""
	var filtered_errors: Array[Dictionary] = []
	for error in _error_log:
		if error.severity == severity:
			filtered_errors.append(error)
	return filtered_errors

# =============================================================================
# SYSTEM MONITORING
# =============================================================================

func monitor_system_health():
	"""Monitor system health and report issues."""
	var health_report = {
		"memory_usage": OS.get_static_memory_peak_usage(),
		"fps": Engine.get_frames_per_second(),
		"time_scale": Engine.time_scale
	}
	
	# Check for performance issues
	if health_report.fps < 30:
		log_warning("Low FPS detected: %d" % health_report.fps, {"health_report": health_report})
	
	# Check for memory issues
	var memory_mb = health_report.memory_usage / (1024 * 1024)
	if memory_mb > 500:  # 500MB threshold
		log_warning("High memory usage detected: %d MB" % memory_mb, {"health_report": health_report})

# =============================================================================
# INITIALIZATION
# =============================================================================

func _ready():
	# Load existing error log
	load_error_log()
	
	# Register with service locator
	ServiceLocator.register_service("ErrorHandler", self, "core")
	
	# Start system monitoring
	var monitor_timer = Timer.new()
	monitor_timer.wait_time = 10.0  # Monitor every 10 seconds
	monitor_timer.timeout.connect(monitor_system_health)
	monitor_timer.autostart = true
	add_child(monitor_timer)
	
	if GameConstants.DEBUG_MODE:
		print("ErrorHandler: Initialized with %d previous errors" % _error_log.size())

func _exit_tree():
	# Save error log on exit
	save_error_log()
	
	if GameConstants.DEBUG_MODE:
		print("ErrorHandler: Saved error log with %d entries" % _error_log.size())

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

func try_call(callable: Callable, fallback_value = null):
	"""Try to execute a callable with error handling."""
	# GDScript doesn't have try/catch, so we'll use a different approach
	if callable.is_valid():
		return callable.call()
	else:
		var error_info = "Invalid callable: %s" % callable
		log_error(error_info, ErrorType.SCRIPT, ErrorSeverity.ERROR)
		return fallback_value

func safe_call(object: Object, method_name: String, args: Array = [], fallback_value = null):
	"""Safely call a method on an object."""
	if not is_instance_valid(object):
		log_error("Object is not valid for method call: %s" % method_name, ErrorType.SCRIPT, ErrorSeverity.ERROR)
		return fallback_value
	
	if not object.has_method(method_name):
		log_error("Object does not have method: %s" % method_name, ErrorType.SCRIPT, ErrorSeverity.ERROR)
		return fallback_value
	
	return object.callv(method_name, args)