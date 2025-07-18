extends Node

# UI Enhancement System for Menschenmon
# Adds polished UI features and quality-of-life improvements

signal tooltip_shown(text: String)
signal tooltip_hidden
signal screen_shake_requested(intensity: float, duration: float)
signal ui_animation_started(animation_name: String)
signal ui_animation_finished(animation_name: String)

# Tooltip system
var tooltip_node: Control
var tooltip_delay: float = 0.5
var tooltip_timer: Timer
var current_tooltip_text: String = ""

# Screen effects
var screen_shake_tween: Tween
var screen_shake_intensity: float = 0.0
var screen_shake_duration: float = 0.0

# UI Animation system
var ui_tweens: Dictionary = {}
var animation_speed_multiplier: float = 1.0

# Notification system
var notification_container: VBoxContainer
var notification_scene: PackedScene
var max_notifications: int = 5
var notification_duration: float = 3.0

# Loading screen system
var loading_screen: Control
var loading_progress: ProgressBar
var loading_text: Label
var loading_spinner: AnimationPlayer

# Achievement popup system
var achievement_popup: Control
var achievement_queue: Array = []  # Array of Dictionary
var achievement_showing: bool = false

func _ready():
	# Initialize UI enhancement systems
	print("UIEnhancements: Initializing...")
	
	# Setup tooltip system
	_setup_tooltip_system()
	
	# Setup screen effects
	_setup_screen_effects()
	
	# Setup notification system
	_setup_notification_system()
	
	# Setup loading screen
	_setup_loading_screen()
	
	# Setup achievement system
	_setup_achievement_system()
	
	# Connect to other systems
	_connect_to_systems()
	
	print("UIEnhancements: Ready")

func _setup_tooltip_system():
	# Create tooltip node
	tooltip_node = Control.new()
	tooltip_node.name = "TooltipSystem"
	tooltip_node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tooltip_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tooltip_node.z_index = 1000  # Very high z-index
	
	# Create tooltip background
	var tooltip_bg = PanelContainer.new()
	tooltip_bg.name = "TooltipBackground"
	tooltip_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Style the tooltip
	var tooltip_style = StyleBoxFlat.new()
	tooltip_style.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	tooltip_style.border_color = Color(0.3, 0.3, 0.3, 1.0)
	tooltip_style.border_width_left = 1
	tooltip_style.border_width_right = 1
	tooltip_style.border_width_top = 1
	tooltip_style.border_width_bottom = 1
	tooltip_style.corner_radius_top_left = 4
	tooltip_style.corner_radius_top_right = 4
	tooltip_style.corner_radius_bottom_left = 4
	tooltip_style.corner_radius_bottom_right = 4
	tooltip_bg.add_theme_stylebox_override("panel", tooltip_style)
	
	# Create tooltip label
	var tooltip_label = Label.new()
	tooltip_label.name = "TooltipLabel"
	tooltip_label.add_theme_color_override("font_color", Color.WHITE)
	tooltip_label.add_theme_font_size_override("font_size", 12)
	tooltip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tooltip_label.custom_minimum_size = Vector2(0, 0)
	
	# Build tooltip hierarchy
	tooltip_bg.add_child(tooltip_label)
	tooltip_node.add_child(tooltip_bg)
	
	# Initially hide tooltip
	tooltip_node.visible = false
	
	# Add to scene tree
	get_tree().root.add_child(tooltip_node)
	
	# Create tooltip timer
	tooltip_timer = Timer.new()
	tooltip_timer.wait_time = tooltip_delay
	tooltip_timer.one_shot = true
	tooltip_timer.timeout.connect(_show_tooltip)
	add_child(tooltip_timer)

func _setup_screen_effects():
	# Create screen shake tween (will be created when needed)
	screen_shake_tween = null

func _setup_notification_system():
	# Create notification container
	notification_container = VBoxContainer.new()
	notification_container.name = "NotificationContainer"
	notification_container.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	notification_container.custom_minimum_size = Vector2(300, 0)
	notification_container.offset_left = -320
	notification_container.offset_top = 20
	
	# Add to scene tree
	get_tree().root.add_child(notification_container)

func _setup_loading_screen():
	# Create loading screen
	loading_screen = Control.new()
	loading_screen.name = "LoadingScreen"
	loading_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	loading_screen.color = Color(0, 0, 0, 0.8)
	loading_screen.visible = false
	loading_screen.z_index = 999
	
	# Create loading content
	var loading_content = VBoxContainer.new()
	loading_content.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	loading_content.custom_minimum_size = Vector2(400, 200)
	
	# Loading text
	loading_text = Label.new()
	loading_text.text = "Loading..."
	loading_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_text.add_theme_font_size_override("font_size", 24)
	loading_text.add_theme_color_override("font_color", Color.WHITE)
	
	# Loading progress bar
	loading_progress = ProgressBar.new()
	loading_progress.custom_minimum_size = Vector2(300, 20)
	loading_progress.value = 0
	loading_progress.max_value = 100
	
	# Build loading screen
	loading_content.add_child(loading_text)
	loading_content.add_child(loading_progress)
	loading_screen.add_child(loading_content)
	
	# Add to scene tree
	get_tree().root.add_child(loading_screen)

func _setup_achievement_system():
	# Create achievement popup
	achievement_popup = Control.new()
	achievement_popup.name = "AchievementPopup"
	achievement_popup.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	achievement_popup.custom_minimum_size = Vector2(350, 100)
	achievement_popup.offset_left = -370
	achievement_popup.offset_top = -120
	achievement_popup.visible = false
	
	# Create achievement background
	var achievement_bg = PanelContainer.new()
	achievement_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Style achievement popup
	var achievement_style = StyleBoxFlat.new()
	achievement_style.bg_color = Color(0.2, 0.6, 0.2, 0.95)
	achievement_style.border_color = Color(0.4, 0.8, 0.4, 1.0)
	achievement_style.border_width_left = 2
	achievement_style.border_width_right = 2
	achievement_style.border_width_top = 2
	achievement_style.border_width_bottom = 2
	achievement_style.corner_radius_top_left = 8
	achievement_style.corner_radius_top_right = 8
	achievement_style.corner_radius_bottom_left = 8
	achievement_style.corner_radius_bottom_right = 8
	achievement_bg.add_theme_stylebox_override("panel", achievement_style)
	
	# Create achievement content
	var achievement_content = VBoxContainer.new()
	achievement_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	achievement_content.offset_left = 10
	achievement_content.offset_top = 10
	achievement_content.offset_right = -10
	achievement_content.offset_bottom = -10
	
	# Achievement title
	var achievement_title = Label.new()
	achievement_title.name = "AchievementTitle"
	achievement_title.text = "Achievement Unlocked!"
	achievement_title.add_theme_font_size_override("font_size", 16)
	achievement_title.add_theme_color_override("font_color", Color.WHITE)
	achievement_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Achievement description
	var achievement_desc = Label.new()
	achievement_desc.name = "AchievementDescription"
	achievement_desc.text = "You did something amazing!"
	achievement_desc.add_theme_font_size_override("font_size", 12)
	achievement_desc.add_theme_color_override("font_color", Color.WHITE)
	achievement_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	achievement_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	# Build achievement popup
	achievement_content.add_child(achievement_title)
	achievement_content.add_child(achievement_desc)
	achievement_bg.add_child(achievement_content)
	achievement_popup.add_child(achievement_bg)
	
	# Add to scene tree
	get_tree().root.add_child(achievement_popup)

func _connect_to_systems():
	# Connect to other systems for UI enhancements
	var human_system = get_node_or_null("/root/HumanSystem")
	if human_system:
		human_system.human_caught.connect(_on_human_caught)
		human_system.active_human_changed.connect(_on_active_human_changed)
	
	var save_manager = get_node_or_null("/root/SaveManager")
	if save_manager:
		save_manager.save_completed.connect(_on_save_completed)
		save_manager.load_completed.connect(_on_load_completed)
	
	var data_manager = get_node_or_null("/root/DataManager")
	if data_manager:
		data_manager.data_loaded.connect(_on_data_loaded)
		data_manager.data_load_failed.connect(_on_data_load_failed)

func _on_human_caught(human):
	show_achievement("Neuer Mensch gefangen!", "Du hast " + human.nickname + " gefangen!")
	show_notification("Mensch gefangen: " + human.nickname, Color.GREEN)

func _on_active_human_changed(human):
	show_notification("Aktiver Mensch: " + human.nickname, Color.BLUE)

func _on_save_completed(success: bool):
	if success:
		show_notification("Spiel gespeichert!", Color.GREEN)
	else:
		show_notification("Fehler beim Speichern!", Color.RED)

func _on_load_completed(success: bool):
	if success:
		show_notification("Spiel geladen!", Color.GREEN)
	else:
		show_notification("Fehler beim Laden!", Color.RED)

func _on_data_loaded():
	show_notification("Daten geladen!", Color.BLUE)

func _on_data_load_failed(error: String):
	show_notification("Fehler beim Laden der Daten: " + error, Color.RED)

# Public API - Tooltips
func show_tooltip_for_node(node: Control, text: String):
	if not node:
		return
	
	# Connect mouse events
	if not node.mouse_entered.is_connected(_on_tooltip_mouse_entered):
		node.mouse_entered.connect(_on_tooltip_mouse_entered.bind(text))
		node.mouse_exited.connect(_on_tooltip_mouse_exited)

func _on_tooltip_mouse_entered(text: String):
	current_tooltip_text = text
	tooltip_timer.start()

func _on_tooltip_mouse_exited():
	tooltip_timer.stop()
	_hide_tooltip()

func _show_tooltip():
	if current_tooltip_text == "":
		return
	
	var tooltip_label = tooltip_node.get_node("TooltipBackground/TooltipLabel")
	tooltip_label.text = current_tooltip_text
	
	# Position tooltip at mouse cursor
	var mouse_pos = get_viewport().get_mouse_position()
	var tooltip_bg = tooltip_node.get_node("TooltipBackground")
	
	# Calculate tooltip size
	tooltip_label.custom_minimum_size = Vector2(0, 0)
	var content_size = tooltip_label.get_theme_font("font").get_string_size(
		current_tooltip_text, 
		HORIZONTAL_ALIGNMENT_LEFT, 
		200, 
		tooltip_label.get_theme_font_size("font_size")
	)
	
	# Set tooltip size and position
	tooltip_bg.custom_minimum_size = content_size + Vector2(20, 10)
	tooltip_bg.position = mouse_pos + Vector2(10, 10)
	
	# Keep tooltip on screen
	var screen_size = get_viewport().get_visible_rect().size
	if tooltip_bg.position.x + tooltip_bg.size.x > screen_size.x:
		tooltip_bg.position.x = mouse_pos.x - tooltip_bg.size.x - 10
	if tooltip_bg.position.y + tooltip_bg.size.y > screen_size.y:
		tooltip_bg.position.y = mouse_pos.y - tooltip_bg.size.y - 10
	
	tooltip_node.visible = true
	tooltip_shown.emit(current_tooltip_text)

func _hide_tooltip():
	tooltip_node.visible = false
	tooltip_hidden.emit()

# Public API - Screen Effects
func shake_screen(intensity: float, duration: float):
	screen_shake_intensity = intensity
	screen_shake_duration = duration
	screen_shake_requested.emit(intensity, duration)
	
	# Apply screen shake to main camera
	var main_camera = get_viewport().get_camera_2d()
	if main_camera:
		_apply_screen_shake(main_camera)

func _apply_screen_shake(camera: Camera2D):
	var original_offset = camera.offset
	var shake_count = int(screen_shake_duration * 60)  # 60 FPS
	
	for i in range(shake_count):
		var shake_offset = Vector2(
			randf_range(-screen_shake_intensity, screen_shake_intensity),
			randf_range(-screen_shake_intensity, screen_shake_intensity)
		)
		camera.offset = original_offset + shake_offset
		await get_tree().process_frame
	
	camera.offset = original_offset

func flash_screen(color: Color, duration: float):
	var flash_overlay = ColorRect.new()
	flash_overlay.color = color
	flash_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash_overlay.z_index = 998
	get_tree().root.add_child(flash_overlay)
	
	var flash_tween = create_tween()
	flash_tween.tween_property(flash_overlay, "modulate:a", 0.0, duration)
	await flash_tween.finished
	
	flash_overlay.queue_free()

# Public API - Notifications
func show_notification(text: String, color: Color = Color.WHITE, duration: float = 3.0):
	# Create notification
	var notification = _create_notification(text, color)
	notification_container.add_child(notification)
	
	# Animate in
	notification.modulate.a = 0.0
	notification.position.x = 100
	var tween = create_tween()
	tween.parallel().tween_property(notification, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(notification, "position:x", 0, 0.3)
	
	# Auto-remove after duration
	await get_tree().create_timer(duration).timeout
	
	# Animate out
	var out_tween = create_tween()
	out_tween.parallel().tween_property(notification, "modulate:a", 0.0, 0.3)
	out_tween.parallel().tween_property(notification, "position:x", 100, 0.3)
	await out_tween.finished
	
	notification.queue_free()
	
	# Remove oldest notifications if too many
	_cleanup_notifications()

func _create_notification(text: String, color: Color) -> Control:
	var notification = PanelContainer.new()
	notification.custom_minimum_size = Vector2(280, 40)
	
	# Style notification
	var notification_style = StyleBoxFlat.new()
	notification_style.bg_color = color
	notification_style.bg_color.a = 0.9
	notification_style.border_color = Color.WHITE
	notification_style.border_width_left = 1
	notification_style.border_width_right = 1
	notification_style.border_width_top = 1
	notification_style.border_width_bottom = 1
	notification_style.corner_radius_top_left = 6
	notification_style.corner_radius_top_right = 6
	notification_style.corner_radius_bottom_left = 6
	notification_style.corner_radius_bottom_right = 6
	notification.add_theme_stylebox_override("panel", notification_style)
	
	# Create label
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 14)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	notification.add_child(label)
	return notification

func _cleanup_notifications():
	while notification_container.get_child_count() > max_notifications:
		var oldest = notification_container.get_child(0)
		oldest.queue_free()

# Public API - Loading Screen
func show_loading_screen(text: String = "Loading..."):
	loading_text.text = text
	loading_progress.value = 0
	loading_screen.visible = true

func hide_loading_screen():
	loading_screen.visible = false

func update_loading_progress(progress: float, text: String = ""):
	loading_progress.value = progress
	if text != "":
		loading_text.text = text

# Public API - Achievements
func show_achievement(title: String, description: String):
	var achievement_data = {
		"title": title,
		"description": description
	}
	
	achievement_queue.append(achievement_data)
	
	if not achievement_showing:
		_show_next_achievement()

func _show_next_achievement():
	if achievement_queue.size() == 0:
		achievement_showing = false
		return
	
	achievement_showing = true
	var achievement_data = achievement_queue.pop_front()
	
	# Update achievement popup
	var title_label = achievement_popup.get_node("PanelContainer/VBoxContainer/AchievementTitle")
	var desc_label = achievement_popup.get_node("PanelContainer/VBoxContainer/AchievementDescription")
	
	title_label.text = achievement_data["title"]
	desc_label.text = achievement_data["description"]
	
	# Animate achievement popup
	achievement_popup.position.x = 50  # Start off-screen
	achievement_popup.modulate.a = 0.0
	achievement_popup.visible = true
	
	var tween = create_tween()
	tween.parallel().tween_property(achievement_popup, "position:x", -370, 0.5)
	tween.parallel().tween_property(achievement_popup, "modulate:a", 1.0, 0.5)
	
	await tween.finished
	
	# Show for 3 seconds
	await get_tree().create_timer(3.0).timeout
	
	# Animate out
	var out_tween = create_tween()
	out_tween.parallel().tween_property(achievement_popup, "position:x", 50, 0.5)
	out_tween.parallel().tween_property(achievement_popup, "modulate:a", 0.0, 0.5)
	
	await out_tween.finished
	
	achievement_popup.visible = false
	
	# Show next achievement if any
	_show_next_achievement()

# Public API - UI Animations
func animate_ui_element(element: Control, animation_type: String, duration: float = 0.3):
	if element == null:
		return
	
	var tween_key = element.get_instance_id()
	if tween_key in ui_tweens:
		ui_tweens[tween_key].kill()
	
	var tween = create_tween()
	ui_tweens[tween_key] = tween
	
	ui_animation_started.emit(animation_type)
	
	match animation_type:
		"fade_in":
			element.modulate.a = 0.0
			tween.tween_property(element, "modulate:a", 1.0, duration)
		"fade_out":
			tween.tween_property(element, "modulate:a", 0.0, duration)
		"slide_in_left":
			var original_pos = element.position
			element.position.x -= 100
			tween.tween_property(element, "position", original_pos, duration)
		"slide_in_right":
			var original_pos = element.position
			element.position.x += 100
			tween.tween_property(element, "position", original_pos, duration)
		"scale_in":
			element.scale = Vector2.ZERO
			tween.tween_property(element, "scale", Vector2.ONE, duration)
		"bounce":
			var original_scale = element.scale
			tween.tween_property(element, "scale", original_scale * 1.2, duration * 0.5)
			tween.tween_property(element, "scale", original_scale, duration * 0.5)
		"shake":
			var original_pos = element.position
			for i in range(10):
				var shake_offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
				tween.tween_property(element, "position", original_pos + shake_offset, duration / 10)
			tween.tween_property(element, "position", original_pos, duration / 10)
	
	await tween.finished
	ui_animation_finished.emit(animation_type)
	
	if tween_key in ui_tweens:
		ui_tweens.erase(tween_key)

# Public API - Utility
func get_ui_enhancement_settings() -> Dictionary:
	return {
		"tooltip_delay": tooltip_delay,
		"max_notifications": max_notifications,
		"notification_duration": notification_duration,
		"animation_speed_multiplier": animation_speed_multiplier
	}

func set_ui_enhancement_settings(settings: Dictionary):
	if settings.has("tooltip_delay"):
		tooltip_delay = settings["tooltip_delay"]
		tooltip_timer.wait_time = tooltip_delay
	
	if settings.has("max_notifications"):
		max_notifications = settings["max_notifications"]
	
	if settings.has("notification_duration"):
		notification_duration = settings["notification_duration"]
	
	if settings.has("animation_speed_multiplier"):
		animation_speed_multiplier = settings["animation_speed_multiplier"]

# Battle-specific UI enhancements
func show_battle_damage_popup(damage: int, position: Vector2, is_critical: bool = false):
	var damage_popup = Label.new()
	damage_popup.text = str(damage)
	damage_popup.add_theme_font_size_override("font_size", 24 if is_critical else 18)
	damage_popup.add_theme_color_override("font_color", Color.RED if is_critical else Color.WHITE)
	damage_popup.position = position
	damage_popup.z_index = 100
	
	get_tree().root.add_child(damage_popup)
	
	# Animate damage popup
	var tween = create_tween()
	tween.parallel().tween_property(damage_popup, "position:y", position.y - 50, 1.0)
	tween.parallel().tween_property(damage_popup, "modulate:a", 0.0, 1.0)
	
	await tween.finished
	damage_popup.queue_free()

func show_status_effect_popup(effect_name: String, position: Vector2):
	var status_popup = Label.new()
	status_popup.text = effect_name
	status_popup.add_theme_font_size_override("font_size", 16)
	status_popup.add_theme_color_override("font_color", Color.YELLOW)
	status_popup.position = position
	status_popup.z_index = 100
	
	get_tree().root.add_child(status_popup)
	
	# Animate status popup
	var tween = create_tween()
	tween.parallel().tween_property(status_popup, "position:y", position.y - 30, 0.8)
	tween.parallel().tween_property(status_popup, "modulate:a", 0.0, 0.8)
	
	await tween.finished
	status_popup.queue_free()

func show_type_effectiveness_popup(effectiveness: String, position: Vector2):
	var color = Color.GREEN if effectiveness == "Super effektiv!" else Color.ORANGE
	
	var effectiveness_popup = Label.new()
	effectiveness_popup.text = effectiveness
	effectiveness_popup.add_theme_font_size_override("font_size", 20)
	effectiveness_popup.add_theme_color_override("font_color", color)
	effectiveness_popup.position = position
	effectiveness_popup.z_index = 100
	
	get_tree().root.add_child(effectiveness_popup)
	
	# Animate effectiveness popup
	var tween = create_tween()
	tween.parallel().tween_property(effectiveness_popup, "position:y", position.y - 40, 1.2)
	tween.parallel().tween_property(effectiveness_popup, "modulate:a", 0.0, 1.2)
	
	await tween.finished
	effectiveness_popup.queue_free()

# Debug functions
func test_ui_enhancements():
	print("UIEnhancements: Testing UI enhancements...")
	
	# Test notification
	show_notification("Test Notification", Color.BLUE)
	await get_tree().create_timer(1.0).timeout
	
	# Test achievement
	show_achievement("Test Achievement", "This is a test achievement!")
	await get_tree().create_timer(2.0).timeout
	
	# Test screen shake
	shake_screen(5.0, 0.5)
	await get_tree().create_timer(1.0).timeout
	
	# Test screen flash
	flash_screen(Color.WHITE, 0.2)
	
	print("UIEnhancements: Test complete")