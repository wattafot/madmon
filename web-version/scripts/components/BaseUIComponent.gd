class_name BaseUIComponent
extends Control

# Base class for reusable UI components
# Provides common functionality and consistent styling

# =============================================================================
# SIGNALS
# =============================================================================

signal component_ready
signal component_destroyed
signal state_changed(old_state: String, new_state: String)

# =============================================================================
# PROPERTIES
# =============================================================================

@export var component_name: String = ""
@export var auto_register_events: bool = true
@export var use_default_styling: bool = true
@export var animation_duration: float = GameConstants.UI_ANIMATION_DURATION

# =============================================================================
# PRIVATE VARIABLES
# =============================================================================

var _component_state: String = "uninitialized"
var _initialization_complete: bool = false
var _event_connections: Array[Dictionary] = []

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready():
	# Set component name if not provided
	if component_name.is_empty():
		component_name = get_script().get_global_name()
		if component_name.is_empty():
			component_name = name
	
	# Initialize component
	_initialize()
	
	# Apply default styling if enabled
	if use_default_styling:
		_apply_default_styling()
	
	# Register events if enabled
	if auto_register_events:
		_register_events()
	
	# Mark as initialized
	_initialization_complete = true
	_change_state("ready")
	
	# Emit ready signal
	component_ready.emit()

func _exit_tree():
	# Cleanup
	_cleanup()
	component_destroyed.emit()

# =============================================================================
# INITIALIZATION
# =============================================================================

func _initialize():
	"""Override this method to provide custom initialization."""
	pass

func _apply_default_styling():
	"""Apply default styling to the component."""
	# Override in subclasses to apply specific styling
	pass

func _register_events():
	"""Register component-specific events."""
	pass

func _cleanup():
	"""Cleanup resources and disconnect events."""
	# Disconnect all registered events
	for connection in _event_connections:
		var signal_object = connection.get("signal_object")
		var signal_name = connection.get("signal_name")
		var callable = connection.get("callable")
		
		if signal_object and signal_object.has_signal(signal_name):
			if signal_object.get(signal_name).is_connected(callable):
				signal_object.get(signal_name).disconnect(callable)
	
	_event_connections.clear()

# =============================================================================
# STATE MANAGEMENT
# =============================================================================

func _change_state(new_state: String):
	"""Change component state and emit signal."""
	if _component_state != new_state:
		var old_state = _component_state
		_component_state = new_state
		state_changed.emit(old_state, new_state)
		
		if GameConstants.DEBUG_MODE:
			print("%s: State changed from %s to %s" % [component_name, old_state, new_state])

func get_state() -> String:
	"""Get current component state."""
	return _component_state

func is_initialized() -> bool:
	"""Check if component is initialized."""
	return _initialization_complete

# =============================================================================
# EVENT MANAGEMENT
# =============================================================================

func connect_event(signal_object: Object, signal_name: String, callable: Callable, flags: int = 0):
	"""Connect an event and track it for cleanup."""
	if signal_object.has_signal(signal_name):
		signal_object.get(signal_name).connect(callable, flags)
		
		# Track connection for cleanup
		_event_connections.append({
			"signal_object": signal_object,
			"signal_name": signal_name,
			"callable": callable
		})

func disconnect_event(signal_object: Object, signal_name: String, callable: Callable):
	"""Disconnect a tracked event."""
	if signal_object.has_signal(signal_name):
		if signal_object.get(signal_name).is_connected(callable):
			signal_object.get(signal_name).disconnect(callable)
	
	# Remove from tracking
	_event_connections = _event_connections.filter(func(conn): 
		return not (conn.signal_object == signal_object and 
					conn.signal_name == signal_name and 
					conn.callable == callable)
	)

# =============================================================================
# ANIMATION HELPERS
# =============================================================================

func animate_in(delay: float = 0.0):
	"""Animate component in with standard animation."""
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	
	# Start invisible and small
	modulate.a = 0.0
	scale = Vector2(0.8, 0.8)
	
	# Animate in
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, animation_duration)
	tween.tween_property(self, "scale", Vector2.ONE, animation_duration)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	
	await tween.finished

func animate_out():
	"""Animate component out with standard animation."""
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, animation_duration)
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), animation_duration)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)
	
	await tween.finished

func animate_highlight(intensity: float = 1.2, duration: float = 0.3):
	"""Animate component highlight effect."""
	var tween = create_tween()
	tween.set_loops(2)
	tween.tween_property(self, "scale", Vector2(intensity, intensity), duration / 2)
	tween.tween_property(self, "scale", Vector2.ONE, duration / 2)
	tween.set_ease(Tween.EASE_OUT)

func animate_shake(intensity: float = 5.0, duration: float = 0.5):
	"""Animate component shake effect."""
	var original_position = position
	var tween = create_tween()
	tween.set_loops(int(duration / 0.05))
	
	for i in range(int(duration / 0.05)):
		var random_offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		tween.tween_property(self, "position", original_position + random_offset, 0.05)
	
	tween.tween_property(self, "position", original_position, 0.05)

# =============================================================================
# UTILITY METHODS
# =============================================================================

func set_enabled(enabled: bool):
	"""Enable or disable the component."""
	visible = enabled
	mouse_filter = Control.MOUSE_FILTER_IGNORE if not enabled else Control.MOUSE_FILTER_PASS
	
	if enabled:
		_change_state("enabled")
	else:
		_change_state("disabled")

func is_enabled() -> bool:
	"""Check if component is enabled."""
	return visible and mouse_filter != Control.MOUSE_FILTER_IGNORE

func get_component_info() -> Dictionary:
	"""Get component information for debugging."""
	return {
		"name": component_name,
		"state": _component_state,
		"enabled": is_enabled(),
		"initialized": _initialization_complete,
		"event_connections": _event_connections.size()
	}

func validate_component() -> bool:
	"""Validate component state."""
	if not is_initialized():
		ErrorHandler.log_warning("Component %s is not initialized" % component_name)
		return false
	
	if not is_instance_valid(self):
		ErrorHandler.log_error("Component %s is not valid" % component_name, ErrorHandler.ErrorType.GENERIC)
		return false
	
	return true

# =============================================================================
# VIRTUAL METHODS (OVERRIDE IN SUBCLASSES)
# =============================================================================

func configure(config: Dictionary):
	"""Configure the component with a dictionary of settings."""
	pass

func refresh():
	"""Refresh the component's display."""
	pass

func reset():
	"""Reset the component to its initial state."""
	pass

func serialize() -> Dictionary:
	"""Serialize component state for saving."""
	return {
		"component_name": component_name,
		"state": _component_state,
		"enabled": is_enabled()
	}

func deserialize(data: Dictionary):
	"""Deserialize component state from saved data."""
	if data.has("enabled"):
		set_enabled(data.enabled)
	
	if data.has("state"):
		_change_state(data.state)

# =============================================================================
# DEBUGGING
# =============================================================================

func _to_string() -> String:
	return "%s(name=%s, state=%s, enabled=%s)" % [
		get_script().get_global_name(),
		component_name,
		_component_state,
		is_enabled()
	]

func print_component_info():
	"""Print component information for debugging."""
	var info = get_component_info()
	print("Component Info:")
	for key in info:
		print("  %s: %s" % [key, info[key]])

func get_children_info() -> Array[Dictionary]:
	"""Get information about child components."""
	var children_info: Array[Dictionary] = []
	
	for child in get_children():
		if child is BaseUIComponent:
			children_info.append(child.get_component_info())
	
	return children_info