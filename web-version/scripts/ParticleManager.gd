class_name ParticleManager
extends Node2D

# Particle and Visual Effects Manager for Menschenmon
# Handles all particle effects, screen shakes, and visual feedback

# Singleton instance
static var instance: ParticleManager

# Screen shake properties
var screen_shake_intensity: float = 0.0
var screen_shake_duration: float = 0.0
var screen_shake_timer: float = 0.0
var original_camera_position: Vector2

# Effects cache
var cached_effects: Dictionary = {}

# Damage number scene
var damage_number_scene: PackedScene

func _ready():
	instance = self
	_setup_damage_number_scene()

func _setup_damage_number_scene():
	# Create damage number scene programmatically since we don't have a scene file
	damage_number_scene = PackedScene.new()

func _process(delta):
	_update_screen_shake(delta)

# =============================================================================
# PARTICLE EFFECTS
# =============================================================================

func create_hit_effect(position: Vector2, is_critical: bool = false, element_type: String = "normal"):
	var particles = _create_hit_particles(position, is_critical, element_type)
	add_child(particles)
	
	# Auto-remove after animation
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.timeout.connect(func(): particles.queue_free())
	add_child(timer)
	timer.start()

func _create_hit_particles(position: Vector2, is_critical: bool, element_type: String) -> CPUParticles2D:
	var particles = CPUParticles2D.new()
	particles.global_position = position
	
	# Basic particle properties
	particles.emitting = true
	particles.amount = 30 if is_critical else 15
	particles.lifetime = 1.0
	particles.one_shot = true
	particles.explosiveness = 1.0
	
	# Shape
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 10.0
	
	# Movement
	particles.direction = Vector2(0, -1)
	particles.initial_velocity_min = 50.0
	particles.initial_velocity_max = 100.0
	particles.angular_velocity_min = -180.0
	particles.angular_velocity_max = 180.0
	
	# Physics
	particles.gravity = Vector2(0, 98)
	particles.linear_accel_min = -20.0
	particles.linear_accel_max = 20.0
	
	# Appearance
	particles.scale_amount_min = 0.5
	particles.scale_amount_max = 1.5
	# particles.scale_amount_curve = _create_scale_curve() # Commented out due to API issues
	
	# Color based on element type and criticality
	var color = _get_particle_color(element_type, is_critical)
	particles.color = color
	particles.color_ramp = _create_color_ramp(color)
	
	return particles

func _create_scale_curve() -> Curve:
	var curve = Curve.new()
	# Just return a basic curve for now
	return curve

func _create_color_ramp(base_color: Color) -> Gradient:
	var gradient = Gradient.new()
	gradient.add_point(0.0, base_color)
	gradient.add_point(0.7, base_color.lightened(0.3))
	gradient.add_point(1.0, Color(base_color.r, base_color.g, base_color.b, 0.0))
	return gradient

func _get_particle_color(element_type: String, is_critical: bool) -> Color:
	var base_color: Color
	
	match element_type.to_lower():
		"alkohol":
			base_color = Color("#8B4513") # Brown
		"normal":
			base_color = Color("#A8A878") # Beige
		"party":
			base_color = Color("#FF1493") # Pink
		"gemutlich":
			base_color = Color("#87CEEB") # Sky blue
		"chaos":
			base_color = Color("#FF4500") # Orange red
		_:
			base_color = Color.WHITE
	
	# Make critical hits more vibrant
	if is_critical:
		base_color = base_color.lightened(0.3)
	
	return base_color

# =============================================================================
# SCREEN SHAKE
# =============================================================================

func shake_screen(intensity: float, duration: float):
	screen_shake_intensity = intensity
	screen_shake_duration = duration
	screen_shake_timer = 0.0
	
	# Store original camera position if we have one
	var camera = get_viewport().get_camera_2d()
	if camera:
		original_camera_position = camera.global_position

func _update_screen_shake(delta: float):
	if screen_shake_timer < screen_shake_duration:
		screen_shake_timer += delta
		
		# Calculate shake offset using noise for more natural movement
		var shake_strength = screen_shake_intensity * (1.0 - screen_shake_timer / screen_shake_duration)
		var shake_offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		
		# Apply shake to camera if available
		var camera = get_viewport().get_camera_2d()
		if camera:
			camera.global_position = original_camera_position + shake_offset
	else:
		# Reset camera position
		var camera = get_viewport().get_camera_2d()
		if camera:
			camera.global_position = original_camera_position

# =============================================================================
# DAMAGE NUMBERS
# =============================================================================

func show_damage_number(damage: int, position: Vector2, is_critical: bool = false, is_heal: bool = false):
	var label = Label.new()
	label.text = str(damage)
	label.global_position = position
	label.z_index = 100
	
	# Style the damage number
	if is_critical:
		label.add_theme_font_size_override("font_size", 24)
		label.add_theme_color_override("font_color", Color.RED)
		label.text = "CRITICAL! " + label.text
	elif is_heal:
		label.add_theme_font_size_override("font_size", 18)
		label.add_theme_color_override("font_color", Color.GREEN)
		label.text = "+" + label.text
	else:
		label.add_theme_font_size_override("font_size", 18)
		label.add_theme_color_override("font_color", Color.WHITE)
	
	# Add outline for better visibility
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 2)
	
	get_tree().current_scene.add_child(label)
	
	# Animate the damage number
	_animate_damage_number(label, is_critical)

func _animate_damage_number(label: Label, is_critical: bool):
	var tween = label.create_tween()
	tween.set_parallel(true)
	
	# Movement animation
	var end_position = label.global_position + Vector2(0, -50)
	if is_critical:
		end_position += Vector2(randf_range(-20, 20), -20)
	
	tween.tween_property(label, "global_position", end_position, 1.5)
	
	# Scale animation for critical hits
	if is_critical:
		tween.tween_property(label, "scale", Vector2(1.5, 1.5), 0.2)
		tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.3)
	
	# Fade out
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	
	# Remove after animation
	tween.tween_callback(label.queue_free)

# =============================================================================
# STATUS EFFECT VISUALS
# =============================================================================

func show_status_effect(position: Vector2, effect_type: String):
	var particles = _create_status_particles(position, effect_type)
	add_child(particles)
	
	# Auto-remove after animation
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.timeout.connect(func(): particles.queue_free())
	add_child(timer)
	timer.start()

func _create_status_particles(position: Vector2, effect_type: String) -> CPUParticles2D:
	var particles = CPUParticles2D.new()
	particles.global_position = position
	
	# Basic properties
	particles.emitting = true
	particles.amount = 20
	particles.lifetime = 2.0
	particles.one_shot = true
	particles.explosiveness = 0.3
	
	# Shape - ring for status effects
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 15.0
	
	# Movement pattern based on effect type
	match effect_type.to_lower():
		"poison":
			particles.direction = Vector2(0, -1)
			particles.initial_velocity_min = 20.0
			particles.initial_velocity_max = 40.0
			particles.color = Color.PURPLE
		"burn":
			particles.direction = Vector2(0, -1)
			particles.initial_velocity_min = 30.0
			particles.initial_velocity_max = 60.0
			particles.color = Color.ORANGE
		"freeze":
			particles.direction = Vector2(0, 0)
			particles.initial_velocity_min = 5.0
			particles.initial_velocity_max = 15.0
			particles.color = Color.CYAN
		"confusion":
			particles.direction = Vector2(0, 0)
			particles.initial_velocity_min = 10.0
			particles.initial_velocity_max = 30.0
			particles.angular_velocity_min = -360.0
			particles.angular_velocity_max = 360.0
			particles.color = Color.YELLOW
		_:
			particles.color = Color.WHITE
	
	# Physics
	particles.gravity = Vector2(0, 20)
	particles.scale_amount_min = 0.3
	particles.scale_amount_max = 0.8
	
	return particles

# =============================================================================
# LEVEL UP EFFECTS
# =============================================================================

func show_level_up_effect(position: Vector2):
	var particles = _create_level_up_particles(position)
	add_child(particles)
	
	# Screen flash
	_flash_screen(Color.YELLOW, 0.3)
	
	# Auto-remove after animation
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.timeout.connect(func(): particles.queue_free())
	add_child(timer)
	timer.start()

func _create_level_up_particles(position: Vector2) -> CPUParticles2D:
	var particles = CPUParticles2D.new()
	particles.global_position = position
	
	# Spectacular level up effect
	particles.emitting = true
	particles.amount = 50
	particles.lifetime = 2.0
	particles.one_shot = true
	particles.explosiveness = 1.0
	
	# Radial burst
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 5.0
	
	particles.direction = Vector2(0, -1)
	particles.initial_velocity_min = 100.0
	particles.initial_velocity_max = 200.0
	particles.angular_velocity_min = -360.0
	particles.angular_velocity_max = 360.0
	
	# Golden color
	particles.color = Color.GOLD
	particles.color_ramp = _create_color_ramp(Color.GOLD)
	
	# Physics
	particles.gravity = Vector2(0, 50)
	particles.scale_amount_min = 0.5
	particles.scale_amount_max = 1.5
	# particles.scale_amount_curve = _create_scale_curve() # Commented out due to API issues
	
	return particles

# =============================================================================
# SCREEN EFFECTS
# =============================================================================

func flash_screen(color: Color, duration: float):
	_flash_screen(color, duration)

func _flash_screen(color: Color, duration: float):
	var flash_rect = ColorRect.new()
	flash_rect.color = color
	flash_rect.size = get_viewport().get_visible_rect().size
	flash_rect.position = Vector2.ZERO
	flash_rect.z_index = 1000
	
	get_tree().current_scene.add_child(flash_rect)
	
	# Animate flash
	var tween = flash_rect.create_tween()
	tween.tween_property(flash_rect, "modulate:a", 0.0, duration)
	tween.tween_callback(flash_rect.queue_free)

# =============================================================================
# HEALING EFFECTS
# =============================================================================

func show_healing_effect(position: Vector2, heal_amount: int):
	# Green healing particles
	var particles = _create_healing_particles(position)
	add_child(particles)
	
	# Healing number
	show_damage_number(heal_amount, position, false, true)
	
	# Auto-remove particles
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.timeout.connect(func(): particles.queue_free())
	add_child(timer)
	timer.start()

func _create_healing_particles(position: Vector2) -> CPUParticles2D:
	var particles = CPUParticles2D.new()
	particles.global_position = position
	
	# Gentle healing effect
	particles.emitting = true
	particles.amount = 25
	particles.lifetime = 1.5
	particles.one_shot = true
	particles.explosiveness = 0.5
	
	# Upward floating motion
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 10.0
	
	particles.direction = Vector2(0, -1)
	particles.initial_velocity_min = 20.0
	particles.initial_velocity_max = 40.0
	particles.angular_velocity_min = -90.0
	particles.angular_velocity_max = 90.0
	
	# Green healing color
	particles.color = Color.GREEN
	particles.color_ramp = _create_color_ramp(Color.GREEN)
	
	# Gentle physics
	particles.gravity = Vector2(0, -20) # Negative gravity for floating effect
	particles.scale_amount_min = 0.3
	particles.scale_amount_max = 0.7
	
	return particles

# =============================================================================
# UTILITY METHODS
# =============================================================================

# Static access methods
static func shake(intensity: float, duration: float):
	if instance:
		instance.shake_screen(intensity, duration)

static func damage_number(damage: int, position: Vector2, is_critical: bool = false, is_heal: bool = false):
	if instance:
		instance.show_damage_number(damage, position, is_critical, is_heal)

static func hit_effect(position: Vector2, is_critical: bool = false, element_type: String = "normal"):
	if instance:
		instance.create_hit_effect(position, is_critical, element_type)

static func status_effect(position: Vector2, effect_type: String):
	if instance:
		instance.show_status_effect(position, effect_type)

static func level_up(position: Vector2):
	if instance:
		instance.show_level_up_effect(position)

static func healing(position: Vector2, heal_amount: int):
	if instance:
		instance.show_healing_effect(position, heal_amount)

static func screen_flash(color: Color, duration: float):
	if instance:
		instance.flash_screen(color, duration)