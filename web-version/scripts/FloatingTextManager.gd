class_name FloatingTextManager
extends Node2D

# Floating Text Manager for dynamic battle text
# Shows animated text for various battle events

# Text types
enum TextType {
	DAMAGE,
	HEAL,
	CRITICAL,
	MISS,
	STATUS,
	BUFF,
	DEBUFF,
	SPECIAL
}

# Color schemes for different text types
static var text_colors = {
	TextType.DAMAGE: Color.RED,
	TextType.HEAL: Color.GREEN,
	TextType.CRITICAL: Color.ORANGE,
	TextType.MISS: Color.GRAY,
	TextType.STATUS: Color.PURPLE,
	TextType.BUFF: Color.CYAN,
	TextType.DEBUFF: Color.MAGENTA,
	TextType.SPECIAL: Color.GOLD
}

# Singleton instance
static var instance: FloatingTextManager

func _ready():
	instance = self

# Main function to create floating text
func create_floating_text(text: String, position: Vector2, type: TextType = TextType.DAMAGE, duration: float = 2.0):
	var floating_text = _create_text_node(text, type)
	floating_text.global_position = position
	add_child(floating_text)
	
	# Animate the text
	_animate_floating_text(floating_text, type, duration)

func _create_text_node(text: String, type: TextType) -> Label:
	var label = Label.new()
	label.text = text
	label.z_index = 100
	
	# Style based on type
	match type:
		TextType.DAMAGE:
			label.add_theme_font_size_override("font_size", 24)
			label.add_theme_color_override("font_color", text_colors[type])
		TextType.HEAL:
			label.add_theme_font_size_override("font_size", 20)
			label.add_theme_color_override("font_color", text_colors[type])
			label.text = "+" + label.text
		TextType.CRITICAL:
			label.add_theme_font_size_override("font_size", 32)
			label.add_theme_color_override("font_color", text_colors[type])
			label.text = "KRITISCH!\n" + label.text
		TextType.MISS:
			label.add_theme_font_size_override("font_size", 18)
			label.add_theme_color_override("font_color", text_colors[type])
			label.text = "VERFEHLT!"
		TextType.STATUS:
			label.add_theme_font_size_override("font_size", 16)
			label.add_theme_color_override("font_color", text_colors[type])
		TextType.BUFF:
			label.add_theme_font_size_override("font_size", 18)
			label.add_theme_color_override("font_color", text_colors[type])
			label.text = "▲ " + label.text
		TextType.DEBUFF:
			label.add_theme_font_size_override("font_size", 18)
			label.add_theme_color_override("font_color", text_colors[type])
			label.text = "▼ " + label.text
		TextType.SPECIAL:
			label.add_theme_font_size_override("font_size", 26)
			label.add_theme_color_override("font_color", text_colors[type])
	
	# Add outline for better visibility
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 2)
	
	# Center the text
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	return label

func _animate_floating_text(label: Label, type: TextType, duration: float):
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Base movement animation
	var end_position = label.global_position + Vector2(0, -60)
	
	# Customize animation based on type
	match type:
		TextType.DAMAGE:
			# Float up with slight shake
			end_position += Vector2(randf_range(-10, 10), 0)
			tween.tween_property(label, "global_position", end_position, duration)
			tween.tween_property(label, "scale", Vector2(1.2, 1.2), duration * 0.2)
			tween.chain().tween_property(label, "scale", Vector2(1.0, 1.0), duration * 0.3)
		
		TextType.HEAL:
			# Gentle float up
			tween.tween_property(label, "global_position", end_position, duration)
			tween.tween_property(label, "rotation", deg_to_rad(10), duration * 0.5)
			tween.chain().tween_property(label, "rotation", deg_to_rad(-10), duration * 0.5)
		
		TextType.CRITICAL:
			# Dramatic scale and movement
			end_position += Vector2(randf_range(-20, 20), -20)
			tween.tween_property(label, "global_position", end_position, duration)
			tween.tween_property(label, "scale", Vector2(1.5, 1.5), duration * 0.3)
			tween.chain().tween_property(label, "scale", Vector2(1.2, 1.2), duration * 0.7)
			
			# Add bounce effect
			var bounce_tween = create_tween()
			bounce_tween.set_loops(3)
			bounce_tween.tween_property(label, "scale", Vector2(1.3, 1.3), 0.1)
			bounce_tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.1)
		
		TextType.MISS:
			# Sideways drift
			end_position = label.global_position + Vector2(30, -30)
			tween.tween_property(label, "global_position", end_position, duration)
			tween.tween_property(label, "rotation", deg_to_rad(15), duration)
		
		TextType.STATUS:
			# Circular motion
			var center = label.global_position
			var radius = 20
			for i in range(4):
				var angle = i * PI / 2
				var pos = center + Vector2(cos(angle), sin(angle)) * radius
				tween.tween_property(label, "global_position", pos, duration / 4)
		
		TextType.BUFF:
			# Quick upward burst
			end_position = label.global_position + Vector2(0, -80)
			tween.tween_property(label, "global_position", end_position, duration * 0.7)
			tween.tween_property(label, "scale", Vector2(1.3, 1.3), duration * 0.3)
		
		TextType.DEBUFF:
			# Slow downward drift
			end_position = label.global_position + Vector2(0, -20)
			tween.tween_property(label, "global_position", end_position, duration * 1.5)
			tween.tween_property(label, "scale", Vector2(0.8, 0.8), duration)
		
		TextType.SPECIAL:
			# Spiral effect
			var original_pos = label.global_position
			for i in range(8):
				var angle = i * PI / 4
				var radius = 30 * (1 - float(i) / 8)
				var pos = original_pos + Vector2(cos(angle), sin(angle)) * radius + Vector2(0, -i * 10)
				tween.tween_property(label, "global_position", pos, duration / 8)
	
	# Fade out
	tween.tween_property(label, "modulate:a", 0.0, duration * 0.3)
	
	# Remove after animation
	tween.tween_callback(label.queue_free)

# Convenience functions
static func damage(amount: int, position: Vector2, is_critical: bool = false):
	if instance:
		if is_critical:
			instance.create_floating_text(str(amount), position, TextType.CRITICAL)
		else:
			instance.create_floating_text(str(amount), position, TextType.DAMAGE)

static func heal(amount: int, position: Vector2):
	if instance:
		instance.create_floating_text(str(amount), position, TextType.HEAL)

static func miss(position: Vector2):
	if instance:
		instance.create_floating_text("", position, TextType.MISS)

static func status(text: String, position: Vector2):
	if instance:
		instance.create_floating_text(text, position, TextType.STATUS)

static func buff(text: String, position: Vector2):
	if instance:
		instance.create_floating_text(text, position, TextType.BUFF)

static func debuff(text: String, position: Vector2):
	if instance:
		instance.create_floating_text(text, position, TextType.DEBUFF)

static func special(text: String, position: Vector2):
	if instance:
		instance.create_floating_text(text, position, TextType.SPECIAL)

# Combo text system
func create_combo_text(combo_count: int, position: Vector2):
	var combo_text = str(combo_count) + "x COMBO!"
	var label = _create_text_node(combo_text, TextType.SPECIAL)
	label.global_position = position
	add_child(label)
	
	# Special combo animation
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Scale bounce
	tween.tween_property(label, "scale", Vector2(2.0, 2.0), 0.2)
	tween.chain().tween_property(label, "scale", Vector2(1.5, 1.5), 0.1)
	
	# Position
	tween.tween_property(label, "global_position", position + Vector2(0, -100), 1.5)
	
	# Rotation
	tween.tween_property(label, "rotation", deg_to_rad(360), 1.0)
	
	# Fade
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	
	tween.tween_callback(label.queue_free)

# Multi-hit text
func create_multi_hit_text(hits: int, position: Vector2):
	for i in range(hits):
		var offset = Vector2(randf_range(-30, 30), randf_range(-20, 20))
		var delay = i * 0.1
		
		var timer = Timer.new()
		timer.wait_time = delay
		timer.one_shot = true
		timer.timeout.connect(func(): 
			create_floating_text("HIT!", position + offset, TextType.DAMAGE, 1.0)
			timer.queue_free()
		)
		add_child(timer)
		timer.start()