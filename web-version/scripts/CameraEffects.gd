class_name CameraEffects
extends Node

# Camera Effects System for Menschenmon
# Handles screen shake, camera transitions, and visual effects

# Singleton instance
static var instance: CameraEffects

# Camera reference
var camera: Camera2D

# Screen shake properties
var shake_intensity: float = 0.0
var shake_duration: float = 0.0
var shake_timer: float = 0.0
var shake_frequency: float = 30.0 # Shakes per second
var shake_noise: FastNoiseLite

# Original camera properties
var original_position: Vector2
var original_zoom: Vector2
var original_rotation: float

# Trauma system (for more realistic shake)
var trauma: float = 0.0
var trauma_power: float = 2.0
var trauma_decay: float = 1.0

# Zoom effects
var zoom_tween: Tween
var position_tween: Tween
var rotation_tween: Tween

# Flash effects
var flash_overlay: ColorRect

func _ready():
	instance = self
	_setup_noise()
	_setup_flash_overlay()

func _setup_noise():
	shake_noise = FastNoiseLite.new()
	shake_noise.seed = randi()
	shake_noise.frequency = shake_frequency

func _setup_flash_overlay():
	flash_overlay = ColorRect.new()
	flash_overlay.color = Color.WHITE
	flash_overlay.size = Vector2(1920, 1080) # Large enough for most screens
	flash_overlay.position = Vector2(-960, -540) # Centered
	flash_overlay.z_index = 1000
	flash_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_overlay.visible = false

func initialize_camera(camera_ref: Camera2D):
	camera = camera_ref
	if camera:
		original_position = camera.global_position
		original_zoom = camera.zoom
		original_rotation = camera.rotation
		
		# Add flash overlay to camera
		camera.add_child(flash_overlay)

func _process(delta):
	_update_trauma_shake(delta)
	_update_traditional_shake(delta)

# =============================================================================
# TRAUMA-BASED SCREEN SHAKE (More Realistic)
# =============================================================================

func add_trauma(amount: float):
	trauma = min(trauma + amount, 1.0)

func _update_trauma_shake(delta: float):
	if trauma <= 0.0 or not camera:
		return
	
	# Calculate shake intensity based on trauma
	var shake_amount = pow(trauma, trauma_power) * 100.0
	
	# Generate smooth noise-based shake
	var current_time = Time.get_time_dict_from_system()["second"] * 1000 + Time.get_time_dict_from_system()["millisecond"]
	var noise_x = shake_noise.get_noise_1d(current_time * shake_frequency / 1000.0)
	var noise_y = shake_noise.get_noise_1d(current_time * shake_frequency / 1000.0 + 100.0)
	var noise_rotation = shake_noise.get_noise_1d(current_time * shake_frequency / 1000.0 + 200.0)
	
	# Apply shake
	var shake_offset = Vector2(noise_x, noise_y) * shake_amount
	camera.global_position = original_position + shake_offset
	camera.rotation = original_rotation + noise_rotation * deg_to_rad(5.0) * trauma
	
	# Decay trauma
	trauma = max(trauma - trauma_decay * delta, 0.0)
	
	# Reset camera when trauma reaches zero
	if trauma <= 0.0:
		camera.global_position = original_position
		camera.rotation = original_rotation

# =============================================================================
# TRADITIONAL SCREEN SHAKE (Simple but Effective)
# =============================================================================

func shake_screen(intensity: float, duration: float):
	shake_intensity = intensity
	shake_duration = duration
	shake_timer = 0.0
	
	if camera:
		original_position = camera.global_position

func _update_traditional_shake(delta: float):
	if shake_timer >= shake_duration or not camera:
		return
	
	shake_timer += delta
	
	# Calculate decay
	var decay = 1.0 - (shake_timer / shake_duration)
	var current_intensity = shake_intensity * decay
	
	# Apply random shake
	var shake_offset = Vector2(
		randf_range(-current_intensity, current_intensity),
		randf_range(-current_intensity, current_intensity)
	)
	
	camera.global_position = original_position + shake_offset
	
	# Reset when done
	if shake_timer >= shake_duration:
		camera.global_position = original_position

# =============================================================================
# CAMERA TRANSITIONS AND EFFECTS
# =============================================================================

func zoom_to(target_zoom: Vector2, duration: float = 0.5, ease_type: Tween.EaseType = Tween.EASE_OUT):
	if not camera:
		return
	
	if zoom_tween:
		zoom_tween.kill()
	
	zoom_tween = create_tween()
	zoom_tween.set_ease(ease_type)
	zoom_tween.set_trans(Tween.TRANS_QUART)
	zoom_tween.tween_property(camera, "zoom", target_zoom, duration)

func pan_to(target_position: Vector2, duration: float = 1.0, ease_type: Tween.EaseType = Tween.EASE_OUT):
	if not camera:
		return
	
	if position_tween:
		position_tween.kill()
	
	position_tween = create_tween()
	position_tween.set_ease(ease_type)
	position_tween.set_trans(Tween.TRANS_QUART)
	position_tween.tween_property(camera, "global_position", target_position, duration)
	
	# Update original position
	position_tween.tween_callback(func(): original_position = target_position)

func rotate_to(target_rotation: float, duration: float = 0.5, ease_type: Tween.EaseType = Tween.EASE_OUT):
	if not camera:
		return
	
	if rotation_tween:
		rotation_tween.kill()
	
	rotation_tween = create_tween()
	rotation_tween.set_ease(ease_type)
	rotation_tween.set_trans(Tween.TRANS_QUART)
	rotation_tween.tween_property(camera, "rotation", target_rotation, duration)
	
	# Update original rotation
	rotation_tween.tween_callback(func(): original_rotation = target_rotation)

func reset_camera(duration: float = 0.5):
	zoom_to(Vector2.ONE, duration)
	pan_to(original_position, duration)
	rotate_to(0.0, duration)

# =============================================================================
# DRAMATIC EFFECTS
# =============================================================================

func dramatic_zoom_in(target_zoom: Vector2 = Vector2(1.5, 1.5), duration: float = 0.3):
	zoom_to(target_zoom, duration, Tween.EASE_IN)
	add_trauma(0.3)

func dramatic_zoom_out(target_zoom: Vector2 = Vector2(0.8, 0.8), duration: float = 0.3):
	zoom_to(target_zoom, duration, Tween.EASE_OUT)
	add_trauma(0.2)

func impact_effect(intensity: float = 0.8):
	# Combination of trauma and zoom
	add_trauma(intensity)
	dramatic_zoom_in(Vector2(1.2, 1.2), 0.1)
	
	# Return to normal after brief pause
	await get_tree().create_timer(0.2).timeout
	zoom_to(Vector2.ONE, 0.3)

func critical_hit_effect():
	# Intense screen shake with dramatic zoom
	add_trauma(1.0)
	dramatic_zoom_in(Vector2(1.8, 1.8), 0.1)
	flash_screen(Color.RED, 0.15)
	
	# Return to normal
	await get_tree().create_timer(0.3).timeout
	zoom_to(Vector2.ONE, 0.5)

func victory_effect():
	# Celebratory camera movement
	flash_screen(Color.GOLD, 0.2)
	
	# Zoom out and back in
	zoom_to(Vector2(0.7, 0.7), 0.5)
	await get_tree().create_timer(0.5).timeout
	zoom_to(Vector2.ONE, 0.5)

# =============================================================================
# FLASH EFFECTS
# =============================================================================

func flash_screen(color: Color, duration: float = 0.3, intensity: float = 0.8):
	if not flash_overlay:
		return
	
	flash_overlay.color = color
	flash_overlay.modulate.a = intensity
	flash_overlay.visible = true
	
	var tween = create_tween()
	tween.tween_property(flash_overlay, "modulate:a", 0.0, duration)
	tween.tween_callback(func(): flash_overlay.visible = false)

func flash_damage(damage_amount: int):
	# Flash intensity based on damage
	var intensity = min(damage_amount / 100.0, 1.0)
	var color = Color.RED
	
	flash_screen(color, 0.2, intensity)

func flash_heal():
	flash_screen(Color.GREEN, 0.3, 0.5)

func flash_status_effect(effect_type: String):
	var color = Color.WHITE
	
	match effect_type.to_lower():
		"poison":
			color = Color.PURPLE
		"burn":
			color = Color.ORANGE
		"freeze":
			color = Color.CYAN
		"paralysis":
			color = Color.YELLOW
		"sleep":
			color = Color.BLUE
		"confusion":
			color = Color.MAGENTA
	
	flash_screen(color, 0.4, 0.4)

# =============================================================================
# CINEMATIC EFFECTS
# =============================================================================

func cinematic_focus(target_position: Vector2, zoom_level: Vector2 = Vector2(1.5, 1.5), duration: float = 1.0):
	# Smooth pan and zoom to focus on target
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(camera, "global_position", target_position, duration)
	tween.tween_property(camera, "zoom", zoom_level, duration)
	
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)

func battle_intro_effect(enemy_position: Vector2, player_position: Vector2):
	# Dramatic battle introduction
	
	# Start zoomed out
	camera.zoom = Vector2(0.5, 0.5)
	
	# Focus on enemy first
	cinematic_focus(enemy_position, Vector2(1.2, 1.2), 1.0)
	await get_tree().create_timer(1.2).timeout
	
	# Pan to player
	cinematic_focus(player_position, Vector2(1.2, 1.2), 0.8)
	await get_tree().create_timer(1.0).timeout
	
	# Zoom out to battle view
	reset_camera(0.5)

func level_up_effect():
	# Celebration effect for level ups
	flash_screen(Color.GOLD, 0.5, 0.6)
	
	# Bounce effect
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Zoom in and out
	tween.tween_property(camera, "zoom", Vector2(1.3, 1.3), 0.3)
	tween.tween_property(camera, "zoom", Vector2.ONE, 0.3)
	
	# Slight rotation
	tween.tween_property(camera, "rotation", deg_to_rad(5), 0.15)
	tween.tween_property(camera, "rotation", deg_to_rad(-5), 0.15)
	tween.tween_property(camera, "rotation", 0.0, 0.2)
	
	# Add some trauma for extra effect
	add_trauma(0.5)

# =============================================================================
# UTILITY METHODS
# =============================================================================

func is_shaking() -> bool:
	return trauma > 0.0 or shake_timer < shake_duration

func stop_all_effects():
	trauma = 0.0
	shake_timer = shake_duration
	
	if zoom_tween:
		zoom_tween.kill()
	if position_tween:
		position_tween.kill()
	if rotation_tween:
		rotation_tween.kill()
	
	if camera:
		camera.global_position = original_position
		camera.zoom = original_zoom
		camera.rotation = original_rotation
	
	if flash_overlay:
		flash_overlay.visible = false

# =============================================================================
# STATIC ACCESS METHODS
# =============================================================================

static func shake(intensity: float, duration: float):
	if instance:
		instance.shake_screen(intensity, duration)

static func add_trauma_static(amount: float):
	if instance:
		instance.add_trauma(amount)

static func flash(color: Color, duration: float = 0.3, intensity: float = 0.8):
	if instance:
		instance.flash_screen(color, duration, intensity)

static func impact(intensity: float = 0.8):
	if instance:
		instance.impact_effect(intensity)

static func critical_hit():
	if instance:
		instance.critical_hit_effect()

static func victory():
	if instance:
		instance.victory_effect()

static func focus(target_position: Vector2, zoom_level: Vector2 = Vector2(1.5, 1.5), duration: float = 1.0):
	if instance:
		instance.cinematic_focus(target_position, zoom_level, duration)

static func reset(duration: float = 0.5):
	if instance:
		instance.reset_camera(duration)