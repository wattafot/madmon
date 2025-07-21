class_name StatusEffectIndicator
extends Control

# StatusEffectIndicator - Visual indicators for battle status effects
# Displays status effects with animations and timers

# =============================================================================
# SIGNALS
# =============================================================================

signal status_effect_clicked(effect_name: String)
signal status_effect_expired(effect_name: String)

# =============================================================================
# ENUMS
# =============================================================================

enum StatusEffectType {
	POISON,
	PARALYSIS,
	BURN,
	FREEZE,
	SLEEP,
	CONFUSION,
	ATTACK_BOOST,
	DEFENSE_BOOST,
	SPEED_BOOST,
	ATTACK_DEBUFF,
	DEFENSE_DEBUFF,
	SPEED_DEBUFF,
	REGENERATION,
	SHIELD,
	CRITICAL_BOOST
}

# =============================================================================
# PROPERTIES
# =============================================================================

@export var effect_type: StatusEffectType = StatusEffectType.POISON
@export var duration: float = 0.0
@export var show_duration: bool = true
@export var animate_pulse: bool = true
@export var tooltip_enabled: bool = true

# =============================================================================
# UI NODES
# =============================================================================

@onready var background: Panel
@onready var icon: TextureRect
@onready var duration_label: Label
@onready var tooltip: Control
@onready var tooltip_label: Label

# =============================================================================
# PRIVATE VARIABLES
# =============================================================================

var _effect_data: Dictionary = {}
var _remaining_duration: float = 0.0
var _is_permanent: bool = false
var _pulse_tween: Tween

# =============================================================================
# INITIALIZATION
# =============================================================================

func _ready():
	_setup_ui()
	_load_effect_data()
	_update_display()
	_setup_animations()

func _setup_ui():
	"""Setup the UI structure."""
	# Create background
	background = Panel.new()
	background.name = "Background"
	background.custom_minimum_size = Vector2(32, 32)
	add_child(background)
	
	# Create icon
	icon = TextureRect.new()
	icon.name = "Icon"
	icon.custom_minimum_size = Vector2(24, 24)
	icon.position = Vector2(4, 4)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(icon)
	
	# Create duration label
	duration_label = Label.new()
	duration_label.name = "DurationLabel"
	duration_label.position = Vector2(0, 22)
	duration_label.size = Vector2(32, 12)
	duration_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	duration_label.add_theme_font_size_override("font_size", 8)
	duration_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(duration_label)
	
	# Create tooltip
	tooltip = Control.new()
	tooltip.name = "Tooltip"
	tooltip.visible = false
	tooltip.z_index = 100
	add_child(tooltip)
	
	var tooltip_bg = Panel.new()
	tooltip_bg.name = "TooltipBackground"
	tooltip_bg.size = Vector2(200, 60)
	tooltip_bg.position = Vector2(35, -30)
	tooltip.add_child(tooltip_bg)
	
	tooltip_label = Label.new()
	tooltip_label.name = "TooltipLabel"
	tooltip_label.size = Vector2(190, 50)
	tooltip_label.position = Vector2(5, 5)
	tooltip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tooltip_label.add_theme_font_size_override("font_size", 10)
	tooltip_label.add_theme_color_override("font_color", Color.WHITE)
	tooltip_bg.add_child(tooltip_label)
	
	# Style tooltip
	var tooltip_style = StyleBoxFlat.new()
	tooltip_style.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	tooltip_style.border_color = Color(0.4, 0.4, 0.4)
	tooltip_style.border_width_left = 1
	tooltip_style.border_width_right = 1
	tooltip_style.border_width_top = 1
	tooltip_style.border_width_bottom = 1
	tooltip_style.corner_radius_top_left = 4
	tooltip_style.corner_radius_top_right = 4
	tooltip_style.corner_radius_bottom_left = 4
	tooltip_style.corner_radius_bottom_right = 4
	tooltip_bg.add_theme_stylebox_override("panel", tooltip_style)
	
	# Connect interactions
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)

func _load_effect_data():
	"""Load effect data and styling."""
	var effect_config = _get_effect_config()
	_effect_data = effect_config[effect_type]
	
	# Apply styling
	var style = StyleBoxFlat.new()
	style.bg_color = _effect_data.background_color
	style.border_color = _effect_data.border_color
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	
	if background:
		background.add_theme_stylebox_override("panel", style)
	
	# Set icon
	if icon:
		icon.texture = _create_effect_icon()

func _get_effect_config() -> Dictionary:
	"""Get configuration for all status effects."""
	return {
		StatusEffectType.POISON: {
			"name": "Vergiftung",
			"description": "Verliert jede Runde Lebenspunkte",
			"background_color": Color(0.4, 0.2, 0.6, 0.8),
			"border_color": Color(0.6, 0.3, 0.8),
			"icon_color": Color(0.8, 0.4, 1.0),
			"symbol": "☠"
		},
		StatusEffectType.PARALYSIS: {
			"name": "Paralyse",
			"description": "Kann manchmal nicht angreifen",
			"background_color": Color(0.6, 0.6, 0.2, 0.8),
			"border_color": Color(0.8, 0.8, 0.3),
			"icon_color": Color(1.0, 1.0, 0.4),
			"symbol": "⚡"
		},
		StatusEffectType.BURN: {
			"name": "Verbrennung",
			"description": "Erleidet Brandschaden und reduzierte Angriffskraft",
			"background_color": Color(0.8, 0.3, 0.2, 0.8),
			"border_color": Color(1.0, 0.4, 0.3),
			"icon_color": Color(1.0, 0.5, 0.3),
			"symbol": "🔥"
		},
		StatusEffectType.FREEZE: {
			"name": "Eingefroren",
			"description": "Kann nicht angreifen",
			"background_color": Color(0.2, 0.5, 0.8, 0.8),
			"border_color": Color(0.3, 0.7, 1.0),
			"icon_color": Color(0.4, 0.8, 1.0),
			"symbol": "❄"
		},
		StatusEffectType.SLEEP: {
			"name": "Schlaf",
			"description": "Kann nicht angreifen",
			"background_color": Color(0.3, 0.3, 0.6, 0.8),
			"border_color": Color(0.4, 0.4, 0.8),
			"icon_color": Color(0.5, 0.5, 1.0),
			"symbol": "💤"
		},
		StatusEffectType.CONFUSION: {
			"name": "Verwirrung",
			"description": "Kann sich selbst verletzen",
			"background_color": Color(0.6, 0.4, 0.8, 0.8),
			"border_color": Color(0.8, 0.6, 1.0),
			"icon_color": Color(1.0, 0.7, 1.0),
			"symbol": "😵"
		},
		StatusEffectType.ATTACK_BOOST: {
			"name": "Angriff +",
			"description": "Erhöhte Angriffskraft",
			"background_color": Color(0.8, 0.2, 0.2, 0.8),
			"border_color": Color(1.0, 0.3, 0.3),
			"icon_color": Color(1.0, 0.4, 0.4),
			"symbol": "⚔"
		},
		StatusEffectType.DEFENSE_BOOST: {
			"name": "Verteidigung +",
			"description": "Erhöhte Verteidigung",
			"background_color": Color(0.2, 0.2, 0.8, 0.8),
			"border_color": Color(0.3, 0.3, 1.0),
			"icon_color": Color(0.4, 0.4, 1.0),
			"symbol": "🛡"
		},
		StatusEffectType.SPEED_BOOST: {
			"name": "Geschwindigkeit +",
			"description": "Erhöhte Geschwindigkeit",
			"background_color": Color(0.2, 0.8, 0.2, 0.8),
			"border_color": Color(0.3, 1.0, 0.3),
			"icon_color": Color(0.4, 1.0, 0.4),
			"symbol": "💨"
		},
		StatusEffectType.ATTACK_DEBUFF: {
			"name": "Angriff -",
			"description": "Reduzierte Angriffskraft",
			"background_color": Color(0.6, 0.3, 0.3, 0.8),
			"border_color": Color(0.8, 0.4, 0.4),
			"icon_color": Color(0.8, 0.5, 0.5),
			"symbol": "⚔"
		},
		StatusEffectType.DEFENSE_DEBUFF: {
			"name": "Verteidigung -",
			"description": "Reduzierte Verteidigung",
			"background_color": Color(0.3, 0.3, 0.6, 0.8),
			"border_color": Color(0.4, 0.4, 0.8),
			"icon_color": Color(0.5, 0.5, 0.8),
			"symbol": "🛡"
		},
		StatusEffectType.SPEED_DEBUFF: {
			"name": "Geschwindigkeit -",
			"description": "Reduzierte Geschwindigkeit",
			"background_color": Color(0.3, 0.6, 0.3, 0.8),
			"border_color": Color(0.4, 0.8, 0.4),
			"icon_color": Color(0.5, 0.8, 0.5),
			"symbol": "🐌"
		},
		StatusEffectType.REGENERATION: {
			"name": "Regeneration",
			"description": "Heilt jede Runde Lebenspunkte",
			"background_color": Color(0.2, 0.8, 0.4, 0.8),
			"border_color": Color(0.3, 1.0, 0.5),
			"icon_color": Color(0.4, 1.0, 0.6),
			"symbol": "❤"
		},
		StatusEffectType.SHIELD: {
			"name": "Schild",
			"description": "Blockiert den nächsten Angriff",
			"background_color": Color(0.8, 0.8, 0.2, 0.8),
			"border_color": Color(1.0, 1.0, 0.3),
			"icon_color": Color(1.0, 1.0, 0.4),
			"symbol": "🛡"
		},
		StatusEffectType.CRITICAL_BOOST: {
			"name": "Kritischer Treffer +",
			"description": "Erhöhte Chance auf kritische Treffer",
			"background_color": Color(0.8, 0.6, 0.2, 0.8),
			"border_color": Color(1.0, 0.8, 0.3),
			"icon_color": Color(1.0, 0.9, 0.4),
			"symbol": "⭐"
		}
	}

func _create_effect_icon() -> ImageTexture:
	"""Create a simple text-based icon for the effect."""
	var image = Image.create(24, 24, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	# Create a simple colored circle with symbol
	var center = Vector2(12, 12)
	var radius = 10
	var color = _effect_data.icon_color
	
	# Draw circle
	for x in range(24):
		for y in range(24):
			var pos = Vector2(x, y)
			var distance = center.distance_to(pos)
			if distance <= radius:
				var alpha = 1.0 - (distance / radius) * 0.3
				image.set_pixel(x, y, Color(color.r, color.g, color.b, alpha))
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	return texture

func _setup_animations():
	"""Setup pulsing animation for active effects."""
	if animate_pulse:
		_pulse_tween = create_tween()
		_pulse_tween.set_loops()
		_pulse_tween.tween_property(self, "modulate", Color(1.2, 1.2, 1.2, 1.0), 0.8)
		_pulse_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.8)

# =============================================================================
# DISPLAY MANAGEMENT
# =============================================================================

func _update_display():
	"""Update the visual display."""
	if not _effect_data:
		return
	
	# Update duration display
	if duration_label and show_duration:
		if _is_permanent:
			duration_label.text = "∞"
		elif _remaining_duration > 0:
			duration_label.text = str(int(_remaining_duration))
		else:
			duration_label.text = ""
		duration_label.visible = show_duration
	
	# Update tooltip
	if tooltip_label and tooltip_enabled:
		var tooltip_text = _effect_data.name
		if _effect_data.description:
			tooltip_text += "\n" + _effect_data.description
		if show_duration and _remaining_duration > 0:
			tooltip_text += "\nDauer: " + str(int(_remaining_duration)) + " Runden"
		tooltip_label.text = tooltip_text

# =============================================================================
# EFFECT MANAGEMENT
# =============================================================================

func set_effect(new_effect_type: StatusEffectType, new_duration: float = 0.0):
	"""Set the status effect type and duration."""
	effect_type = new_effect_type
	duration = new_duration
	_remaining_duration = duration
	_is_permanent = duration <= 0
	
	_load_effect_data()
	_update_display()

func update_duration(new_duration: float):
	"""Update the remaining duration."""
	_remaining_duration = new_duration
	_update_display()
	
	if _remaining_duration <= 0 and not _is_permanent:
		expire()

func expire():
	"""Expire the status effect."""
	status_effect_expired.emit(StatusEffectType.keys()[effect_type])
	_animate_expiration()

func _animate_expiration():
	"""Animate the effect expiring."""
	var expire_tween = create_tween()
	expire_tween.set_parallel(true)
	expire_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5)
	expire_tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.5)
	expire_tween.tween_callback(queue_free).set_delay(0.5)

func reduce_duration():
	"""Reduce duration by 1 (called each turn)."""
	if not _is_permanent:
		_remaining_duration = max(0, _remaining_duration - 1)
		_update_display()
		
		if _remaining_duration <= 0:
			expire()

# =============================================================================
# INTERACTION HANDLING
# =============================================================================

func _on_mouse_entered():
	"""Handle mouse entering the indicator."""
	if tooltip_enabled and tooltip:
		tooltip.visible = true
		
		# Animate tooltip in
		tooltip.modulate = Color(1.0, 1.0, 1.0, 0.0)
		var tooltip_tween = create_tween()
		tooltip_tween.tween_property(tooltip, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)

func _on_mouse_exited():
	"""Handle mouse exiting the indicator."""
	if tooltip:
		tooltip.visible = false

func _on_gui_input(event: InputEvent):
	"""Handle GUI input events."""
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			status_effect_clicked.emit(StatusEffectType.keys()[effect_type])

# =============================================================================
# PUBLIC API
# =============================================================================

func get_effect_name() -> String:
	"""Get the localized effect name."""
	return _effect_data.get("name", "Unknown Effect")

func get_effect_description() -> String:
	"""Get the effect description."""
	return _effect_data.get("description", "")

func get_remaining_duration() -> float:
	"""Get the remaining duration."""
	return _remaining_duration

func is_permanent() -> bool:
	"""Check if the effect is permanent."""
	return _is_permanent

func get_effect_type() -> StatusEffectType:
	"""Get the effect type."""
	return effect_type

func set_pulse_animation(enabled: bool):
	"""Enable or disable pulse animation."""
	animate_pulse = enabled
	if animate_pulse:
		_setup_animations()
	elif _pulse_tween:
		_pulse_tween.kill()
		modulate = Color.WHITE

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

func _process(delta):
	"""Process frame updates."""
	# Update any time-based animations here if needed
	pass

func _to_string() -> String:
	"""String representation for debugging."""
	return "StatusEffectIndicator(type=%s, duration=%.1f)" % [
		StatusEffectType.keys()[effect_type],
		_remaining_duration
	]