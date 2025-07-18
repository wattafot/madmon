class_name EnhancedButton
extends Button

# Enhanced Button with built-in animations and styling
# Automatically applies UIStyler styles and smooth animations

@export var button_style: String = "default"
@export var enable_animations: bool = true
@export var enable_sound: bool = true
@export var animate_on_ready: bool = false

# Animation properties
@export var hover_scale: float = 1.05
@export var press_scale: float = 0.95
@export var animation_duration: float = 0.1

# Sound properties (for future audio implementation)
@export var hover_sound: String = ""
@export var click_sound: String = ""

# Internal state
var is_hovered: bool = false
var is_pressed_down: bool = false
var original_scale: Vector2 = Vector2.ONE

# Tween references
var hover_tween: Tween
var press_tween: Tween

func _ready():
	# Apply styling
	UIStyler.style_button(self, button_style)
	
	# Store original scale
	original_scale = scale
	
	# Connect signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	
	# Animate in if requested
	if animate_on_ready:
		animate_in()

func _on_mouse_entered():
	if not enable_animations:
		return
	
	is_hovered = true
	
	# Cancel any existing hover tween
	if hover_tween:
		hover_tween.kill()
	
	# Create hover animation
	hover_tween = create_tween()
	hover_tween.set_parallel(true)
	
	if not is_pressed_down:
		hover_tween.tween_property(self, "scale", original_scale * hover_scale, animation_duration)
	
	# Optional: Add subtle rotation or color change
	hover_tween.tween_property(self, "rotation", deg_to_rad(1), animation_duration)
	
	# Play hover sound (future implementation)
	if enable_sound and hover_sound != "":
		_play_sound(hover_sound)

func _on_mouse_exited():
	if not enable_animations:
		return
	
	is_hovered = false
	
	# Cancel any existing hover tween
	if hover_tween:
		hover_tween.kill()
	
	# Create exit animation
	hover_tween = create_tween()
	hover_tween.set_parallel(true)
	
	if not is_pressed_down:
		hover_tween.tween_property(self, "scale", original_scale, animation_duration)
	
	hover_tween.tween_property(self, "rotation", 0.0, animation_duration)

func _on_button_down():
	if not enable_animations:
		return
	
	is_pressed_down = true
	
	# Cancel any existing press tween
	if press_tween:
		press_tween.kill()
	
	# Create press animation
	press_tween = create_tween()
	press_tween.set_parallel(true)
	press_tween.tween_property(self, "scale", original_scale * press_scale, animation_duration / 2)
	
	# Screen shake for important buttons
	if button_style == "primary":
		ParticleManager.shake(2.0, 0.1)

func _on_button_up():
	if not enable_animations:
		return
	
	is_pressed_down = false
	
	# Cancel any existing press tween
	if press_tween:
		press_tween.kill()
	
	# Create release animation
	press_tween = create_tween()
	press_tween.set_parallel(true)
	
	# Return to hover state if still hovered, otherwise normal
	var target_scale = original_scale * hover_scale if is_hovered else original_scale
	press_tween.tween_property(self, "scale", target_scale, animation_duration)
	
	# Play click sound
	if enable_sound and click_sound != "":
		_play_sound(click_sound)

# Public animation methods
func animate_in(delay: float = 0.0):
	# Start invisible and small
	modulate.a = 0.0
	scale = Vector2.ZERO
	
	# Wait for delay
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	
	# Animate in
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, animation_duration * 2)
	tween.tween_property(self, "scale", original_scale, animation_duration * 2)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

func animate_out():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, animation_duration * 2)
	tween.tween_property(self, "scale", Vector2.ZERO, animation_duration * 2)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)

func pulse_animation(intensity: float = 1.2, duration: float = 0.5):
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "scale", original_scale * intensity, duration / 2)
	tween.tween_property(self, "scale", original_scale, duration / 2)
	tween.set_ease(Tween.EASE_IN_OUT)

func stop_pulse():
	if hover_tween:
		hover_tween.kill()
	if press_tween:
		press_tween.kill()
	
	var tween = create_tween()
	tween.tween_property(self, "scale", original_scale, animation_duration)

func bounce_animation():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", original_scale * 1.3, animation_duration)
	tween.tween_property(self, "scale", original_scale, animation_duration)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)

func shake_animation(intensity: float = 5.0, duration: float = 0.5):
	var original_pos = position
	var tween = create_tween()
	tween.set_loops(int(duration / 0.05))
	
	for i in range(int(duration / 0.05)):
		var random_offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		tween.tween_property(self, "position", original_pos + random_offset, 0.05)
	
	tween.tween_property(self, "position", original_pos, 0.05)

func glow_animation(color: Color = Color.WHITE, intensity: float = 0.5, duration: float = 1.0):
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "modulate", Color.WHITE + color * intensity, duration / 2)
	tween.tween_property(self, "modulate", Color.WHITE, duration / 2)
	tween.set_ease(Tween.EASE_IN_OUT)

func stop_glow():
	if hover_tween:
		hover_tween.kill()
	
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, animation_duration)

# Style update method
func update_style(new_style: String):
	button_style = new_style
	UIStyler.style_button(self, button_style)

# Sound system (placeholder for future audio implementation)
func _play_sound(sound_name: String):
	# Future implementation: AudioManager.play_sound(sound_name)
	pass

# Utility method to set up as a selection indicator
func set_as_selected(selected: bool):
	if selected:
		glow_animation(Color.YELLOW, 0.3, 0.8)
		button_pressed = true
	else:
		stop_glow()
		button_pressed = false

# Utility method for disabled state with animation
func set_disabled_animated(disabled: bool):
	var tween = create_tween()
	tween.set_parallel(true)
	
	if disabled:
		tween.tween_property(self, "modulate", Color.GRAY, animation_duration)
		tween.tween_property(self, "scale", original_scale * 0.9, animation_duration)
	else:
		tween.tween_property(self, "modulate", Color.WHITE, animation_duration)
		tween.tween_property(self, "scale", original_scale, animation_duration)
	
	self.disabled = disabled

# Method to temporarily highlight button (for tutorials or notifications)
func highlight_temporary(duration: float = 2.0):
	pulse_animation(1.15, 0.3)
	
	# Stop after duration
	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.timeout.connect(stop_pulse)
	add_child(timer)
	timer.start()
	
	# Auto-remove timer
	timer.timeout.connect(func(): timer.queue_free())

# Method to chain button animations
func chain_animation(other_button: EnhancedButton, delay: float = 0.1):
	animate_in()
	other_button.animate_in(delay)

# Method to set disabled state with animation
func set_disabled_with_animation(value: bool):
	set_disabled_animated(value)

# Handle theme changes
func _on_theme_changed():
	UIStyler.style_button(self, button_style)

# Debug method to test all animations
func test_animations():
	print("Testing animations for button: ", text)
	
	# Test sequence
	animate_in()
	await get_tree().create_timer(1.0).timeout
	
	bounce_animation()
	await get_tree().create_timer(1.0).timeout
	
	shake_animation(3.0, 0.5)
	await get_tree().create_timer(1.0).timeout
	
	glow_animation(Color.BLUE, 0.5, 0.5)
	await get_tree().create_timer(2.0).timeout
	
	stop_glow()
	print("Animation test complete for button: ", text)