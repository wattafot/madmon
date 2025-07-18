extends Control

# StatusEffectManager - Manages multiple status effect indicators
# Handles display, timing, and interaction of status effects

# =============================================================================
# SIGNALS
# =============================================================================

signal status_effect_applied(effect_type: StatusEffectIndicator.StatusEffectType, duration: float)
signal status_effect_removed(effect_type: StatusEffectIndicator.StatusEffectType)
signal status_effect_triggered(effect_type: StatusEffectIndicator.StatusEffectType, damage: int)

# =============================================================================
# PROPERTIES
# =============================================================================

@export var max_effects: int = 8
@export var effect_spacing: float = 36.0
@export var show_tooltips: bool = true
@export var auto_process_effects: bool = true
@export var layout_direction: HBoxContainer.AlignmentMode = HBoxContainer.ALIGNMENT_BEGIN

# =============================================================================
# UI NODES
# =============================================================================

@onready var effect_container: HBoxContainer
@onready var background: Panel

# =============================================================================
# PRIVATE VARIABLES
# =============================================================================

var _active_effects: Dictionary = {}
var _effect_indicators: Dictionary = {}
var _effect_timers: Dictionary = {}
var _owner_name: String = ""

# =============================================================================
# INITIALIZATION
# =============================================================================

func _ready():
	_setup_ui()
	_connect_events()
	
	# Register with ServiceLocator if needed
	if not ServiceLocator.has_service("StatusEffectManager"):
		ServiceLocator.register_service("StatusEffectManager", self, "ui")

func _setup_ui():
	"""Setup the UI structure."""
	name = "StatusEffectManager"
	
	# Create background
	background = Panel.new()
	background.name = "Background"
	background.visible = false  # Only show when effects are active
	add_child(background)
	
	# Create effect container
	effect_container = HBoxContainer.new()
	effect_container.name = "EffectContainer"
	effect_container.alignment = layout_direction
	effect_container.add_theme_constant_override("separation", int(effect_spacing - 32))
	add_child(effect_container)
	
	# Style background
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.7)
	style.border_color = Color(0.3, 0.3, 0.3, 0.8)
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	background.add_theme_stylebox_override("panel", style)

func _connect_events():
	"""Connect to relevant events."""
	# Connect to battle events
	EventBus.connect_safe("battle_turn_started", _on_battle_turn_started)
	EventBus.connect_safe("battle_ended", _on_battle_ended)
	EventBus.connect_safe("status_effect_applied", _on_status_effect_applied)
	EventBus.connect_safe("status_effect_removed", _on_status_effect_removed)

# =============================================================================
# EFFECT MANAGEMENT
# =============================================================================

func apply_effect(effect_type: StatusEffectIndicator.StatusEffectType, duration: float = 3.0, source: String = ""):
	"""Apply a status effect."""
	var effect_key = StatusEffectIndicator.StatusEffectType.keys()[effect_type]
	
	# Check if effect already exists
	if effect_key in _active_effects:
		# Update existing effect duration if new duration is longer
		if duration > _active_effects[effect_key].duration:
			_active_effects[effect_key].duration = duration
			_effect_indicators[effect_key].update_duration(duration)
		
		if GameConstants.DEBUG_MODE:
			print("StatusEffectManager: Updated %s duration to %.1f" % [effect_key, duration])
		return
	
	# Add new effect
	_active_effects[effect_key] = {
		"type": effect_type,
		"duration": duration,
		"source": source,
		"applied_at": Time.get_time_dict_from_system()
	}
	
	# Create indicator
	var indicator = preload("res://scripts/StatusEffectIndicator.gd").new()
	indicator.set_effect(effect_type, duration)
	indicator.tooltip_enabled = show_tooltips
	
	# Connect signals
	indicator.status_effect_clicked.connect(_on_effect_clicked)
	indicator.status_effect_expired.connect(_on_effect_expired)
	
	# Add to container
	effect_container.add_child(indicator)
	_effect_indicators[effect_key] = indicator
	
	# Update display
	_update_display()
	
	# Emit signal
	status_effect_applied.emit(effect_type, duration)
	
	if GameConstants.DEBUG_MODE:
		print("StatusEffectManager: Applied %s for %.1f turns" % [effect_key, duration])

func remove_effect(effect_type: StatusEffectIndicator.StatusEffectType):
	"""Remove a status effect."""
	var effect_key = StatusEffectIndicator.StatusEffectType.keys()[effect_type]
	
	if effect_key in _active_effects:
		# Remove from tracking
		_active_effects.erase(effect_key)
		
		# Remove indicator
		if effect_key in _effect_indicators:
			_effect_indicators[effect_key].queue_free()
			_effect_indicators.erase(effect_key)
		
		# Remove timer
		if effect_key in _effect_timers:
			_effect_timers[effect_key].queue_free()
			_effect_timers.erase(effect_key)
		
		# Update display
		_update_display()
		
		# Emit signal
		status_effect_removed.emit(effect_type)
		
		if GameConstants.DEBUG_MODE:
			print("StatusEffectManager: Removed %s" % effect_key)

func clear_all_effects():
	"""Clear all active status effects."""
	var effects_to_remove = _active_effects.keys()
	for effect_key in effects_to_remove:
		var effect_type = StatusEffectIndicator.StatusEffectType[effect_key]
		remove_effect(effect_type)

func has_effect(effect_type: StatusEffectIndicator.StatusEffectType) -> bool:
	"""Check if a specific effect is active."""
	var effect_key = StatusEffectIndicator.StatusEffectType.keys()[effect_type]
	return effect_key in _active_effects

func get_effect_duration(effect_type: StatusEffectIndicator.StatusEffectType) -> float:
	"""Get the remaining duration of an effect."""
	var effect_key = StatusEffectIndicator.StatusEffectType.keys()[effect_type]
	if effect_key in _active_effects:
		return _active_effects[effect_key].duration
	return 0.0

func get_all_effects() -> Array[Dictionary]:
	"""Get all active effects."""
	var effects: Array[Dictionary] = []
	for effect_key in _active_effects:
		effects.append(_active_effects[effect_key])
	return effects

# =============================================================================
# TURN PROCESSING
# =============================================================================

func process_turn_effects() -> Dictionary:
	"""Process all effects for the current turn."""
	var effects_result = {
		"damage": 0,
		"healing": 0,
		"messages": [],
		"expired_effects": []
	}
	
	for effect_key in _active_effects.keys():
		var effect_data = _active_effects[effect_key]
		var effect_type = effect_data.type
		
		# Process effect
		var effect_result = _process_single_effect(effect_type, effect_data)
		
		# Accumulate results
		effects_result.damage += effect_result.damage
		effects_result.healing += effect_result.healing
		effects_result.messages.append_array(effect_result.messages)
		
		# Reduce duration
		effect_data.duration = max(0, effect_data.duration - 1)
		
		# Update indicator
		if effect_key in _effect_indicators:
			_effect_indicators[effect_key].update_duration(effect_data.duration)
		
		# Check if effect expired
		if effect_data.duration <= 0:
			effects_result.expired_effects.append(effect_type)
	
	# Remove expired effects
	for effect_type in effects_result.expired_effects:
		remove_effect(effect_type)
	
	return effects_result

func _process_single_effect(effect_type: StatusEffectIndicator.StatusEffectType, effect_data: Dictionary) -> Dictionary:
	"""Process a single effect and return its result."""
	var result = {
		"damage": 0,
		"healing": 0,
		"messages": []
	}
	
	match effect_type:
		StatusEffectIndicator.StatusEffectType.POISON:
			result.damage = 20  # Fixed poison damage
			result.messages.append(_owner_name + " erleidet Giftschaden!")
			status_effect_triggered.emit(effect_type, result.damage)
		
		StatusEffectIndicator.StatusEffectType.BURN:
			result.damage = 15  # Fixed burn damage
			result.messages.append(_owner_name + " erleidet Brandschaden!")
			status_effect_triggered.emit(effect_type, result.damage)
		
		StatusEffectIndicator.StatusEffectType.REGENERATION:
			result.healing = 25  # Fixed regeneration healing
			result.messages.append(_owner_name + " regeneriert Lebenspunkte!")
			status_effect_triggered.emit(effect_type, -result.healing)
		
		StatusEffectIndicator.StatusEffectType.PARALYSIS:
			# 25% chance to be unable to move
			if randf() < 0.25:
				result.messages.append(_owner_name + " ist paralysiert und kann nicht angreifen!")
				status_effect_triggered.emit(effect_type, 0)
		
		StatusEffectIndicator.StatusEffectType.SLEEP:
			result.messages.append(_owner_name + " schläft und kann nicht angreifen!")
			status_effect_triggered.emit(effect_type, 0)
		
		StatusEffectIndicator.StatusEffectType.FREEZE:
			result.messages.append(_owner_name + " ist eingefroren und kann nicht angreifen!")
			status_effect_triggered.emit(effect_type, 0)
		
		StatusEffectIndicator.StatusEffectType.CONFUSION:
			# 33% chance to hurt self
			if randf() < 0.33:
				result.damage = 10
				result.messages.append(_owner_name + " ist verwirrt und verletzt sich selbst!")
				status_effect_triggered.emit(effect_type, result.damage)
		
		_:
			# Stat effects don't have turn-based effects
			pass
	
	return result

# =============================================================================
# DISPLAY MANAGEMENT
# =============================================================================

func _update_display():
	"""Update the overall display."""
	var has_effects = _active_effects.size() > 0
	
	# Show/hide background
	if background:
		background.visible = has_effects
	
	# Update container size
	if effect_container:
		var container_size = Vector2(
			min(_active_effects.size() * effect_spacing, max_effects * effect_spacing),
			36
		)
		effect_container.custom_minimum_size = container_size
		
		# Update background size
		if background:
			background.custom_minimum_size = container_size + Vector2(8, 8)
			background.position = Vector2(-4, -4)

func set_owner_name(owner: String):
	"""Set the owner name for effect messages."""
	_owner_name = owner

# =============================================================================
# EVENT HANDLERS
# =============================================================================

func _on_battle_turn_started():
	"""Handle battle turn started."""
	if auto_process_effects:
		var effects_result = process_turn_effects()
		
		# Emit events for battle manager to handle
		if effects_result.damage > 0:
			EventBus.emit_signal("status_damage_dealt", _owner_name, effects_result.damage)
		
		if effects_result.healing > 0:
			EventBus.emit_signal("status_healing_applied", _owner_name, effects_result.healing)
		
		# Display messages
		for message in effects_result.messages:
			EventBus.emit_signal("battle_message", message)

func _on_battle_ended(victory: bool):
	"""Handle battle ended."""
	# Clear all effects when battle ends
	clear_all_effects()

func _on_status_effect_applied(effect_type: StatusEffectIndicator.StatusEffectType, duration: float):
	"""Handle status effect applied externally."""
	apply_effect(effect_type, duration)

func _on_status_effect_removed(effect_type: StatusEffectIndicator.StatusEffectType):
	"""Handle status effect removed externally."""
	remove_effect(effect_type)

func _on_effect_clicked(effect_name: String):
	"""Handle effect indicator clicked."""
	if GameConstants.DEBUG_MODE:
		print("StatusEffectManager: Effect clicked: %s" % effect_name)
	
	# Could show detailed effect info or allow removal
	EventBus.emit_signal("status_effect_info_requested", effect_name)

func _on_effect_expired(effect_name: String):
	"""Handle effect indicator expired."""
	var effect_type = StatusEffectIndicator.StatusEffectType[effect_name]
	remove_effect(effect_type)

# =============================================================================
# STAT MODIFIERS
# =============================================================================

func get_attack_modifier() -> float:
	"""Get the total attack modifier from status effects."""
	var modifier = 1.0
	
	if has_effect(StatusEffectIndicator.StatusEffectType.ATTACK_BOOST):
		modifier *= 1.5
	
	if has_effect(StatusEffectIndicator.StatusEffectType.ATTACK_DEBUFF):
		modifier *= 0.67
	
	if has_effect(StatusEffectIndicator.StatusEffectType.BURN):
		modifier *= 0.5  # Burn reduces attack
	
	return modifier

func get_defense_modifier() -> float:
	"""Get the total defense modifier from status effects."""
	var modifier = 1.0
	
	if has_effect(StatusEffectIndicator.StatusEffectType.DEFENSE_BOOST):
		modifier *= 1.5
	
	if has_effect(StatusEffectIndicator.StatusEffectType.DEFENSE_DEBUFF):
		modifier *= 0.67
	
	return modifier

func get_speed_modifier() -> float:
	"""Get the total speed modifier from status effects."""
	var modifier = 1.0
	
	if has_effect(StatusEffectIndicator.StatusEffectType.SPEED_BOOST):
		modifier *= 1.5
	
	if has_effect(StatusEffectIndicator.StatusEffectType.SPEED_DEBUFF):
		modifier *= 0.67
	
	if has_effect(StatusEffectIndicator.StatusEffectType.PARALYSIS):
		modifier *= 0.25  # Paralysis greatly reduces speed
	
	return modifier

func get_critical_modifier() -> float:
	"""Get the critical hit chance modifier."""
	var modifier = 1.0
	
	if has_effect(StatusEffectIndicator.StatusEffectType.CRITICAL_BOOST):
		modifier *= 2.0
	
	return modifier

func can_act() -> bool:
	"""Check if the owner can act this turn."""
	# Check for incapacitating effects
	if has_effect(StatusEffectIndicator.StatusEffectType.SLEEP):
		return false
	
	if has_effect(StatusEffectIndicator.StatusEffectType.FREEZE):
		return false
	
	if has_effect(StatusEffectIndicator.StatusEffectType.PARALYSIS):
		return randf() >= 0.25  # 25% chance to be unable to act
	
	return true

func should_hurt_self() -> bool:
	"""Check if confusion causes self-damage."""
	if has_effect(StatusEffectIndicator.StatusEffectType.CONFUSION):
		return randf() < 0.33  # 33% chance
	
	return false

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

func get_effects_summary() -> String:
	"""Get a summary of all active effects."""
	if _active_effects.is_empty():
		return "Keine aktiven Effekte"
	
	var summary_parts: Array[String] = []
	for effect_key in _active_effects:
		var effect_data = _active_effects[effect_key]
		var duration_text = "∞" if effect_data.duration <= 0 else str(int(effect_data.duration))
		summary_parts.append("%s (%s)" % [effect_key, duration_text])
	
	return "Aktive Effekte: " + ", ".join(summary_parts)

func debug_print_effects():
	"""Debug print all active effects."""
	if GameConstants.DEBUG_MODE:
		print("=== StatusEffectManager Debug ===")
		print("Owner: %s" % _owner_name)
		print("Active effects: %d" % _active_effects.size())
		
		for effect_key in _active_effects:
			var effect_data = _active_effects[effect_key]
			print("  %s: %.1f turns remaining" % [effect_key, effect_data.duration])
		
		print("=== End Debug ===")

func _to_string() -> String:
	"""String representation for debugging."""
	return "StatusEffectManager(owner=%s, effects=%d)" % [_owner_name, _active_effects.size()]