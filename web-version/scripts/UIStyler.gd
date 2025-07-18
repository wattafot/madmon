class_name UIStyler
extends RefCounted

# Centralized UI styling system for Menschenmon
# Provides consistent styling across all UI elements with theme support

# Color Schemes
enum UITheme {
	LIGHT,
	DARK,
	BATTLE
}

static var current_theme: UITheme = UITheme.LIGHT

# Color Definitions
static var colors = {
	UITheme.LIGHT: {
		"background": Color("#F5F5F5"),
		"surface": Color("#FFFFFF"),
		"primary": Color("#007AFF"),
		"secondary": Color("#34C759"),
		"accent": Color("#FF9500"),
		"text": Color("#000000"),
		"text_secondary": Color("#666666"),
		"border": Color("#DDDDDD"),
		"selection": Color("#FFFACD"),
		"selection_border": Color("#FF4500"),
		"disabled": Color("#999999"),
		"success": Color("#34C759"),
		"warning": Color("#FFCC00"),
		"error": Color("#FF3B30"),
		"hp_high": Color("#32CD32"),
		"hp_medium": Color("#FFFF00"),
		"hp_low": Color("#FF0000")
	},
	UITheme.DARK: {
		"background": Color("#1C1C1E"),
		"surface": Color("#2C2C2E"),
		"primary": Color("#0A84FF"),
		"secondary": Color("#30D158"),
		"accent": Color("#FF9F0A"),
		"text": Color("#FFFFFF"),
		"text_secondary": Color("#AEAEB2"),
		"border": Color("#38383A"),
		"selection": Color("#48484A"),
		"selection_border": Color("#FF9F0A"),
		"disabled": Color("#636366"),
		"success": Color("#30D158"),
		"warning": Color("#FFD60A"),
		"error": Color("#FF453A"),
		"hp_high": Color("#30D158"),
		"hp_medium": Color("#FFD60A"),
		"hp_low": Color("#FF453A")
	},
	UITheme.BATTLE: {
		"background": Color("#2C2C2E"),
		"surface": Color("#FFFFFF"),
		"primary": Color("#007AFF"),
		"secondary": Color("#34C759"),
		"accent": Color("#FF9500"),
		"text": Color("#000000"),
		"text_secondary": Color("#666666"),
		"border": Color("#DDDDDD"),
		"selection": Color("#FFFACD"),
		"selection_border": Color("#FF4500"),
		"disabled": Color("#999999"),
		"success": Color("#34C759"),
		"warning": Color("#FFCC00"),
		"error": Color("#FF3B30"),
		"hp_high": Color("#32CD32"),
		"hp_medium": Color("#FFFF00"),
		"hp_low": Color("#FF0000")
	}
}

# Font Sizes
static var font_sizes = {
	"tiny": 10,
	"small": 12,
	"body": 14,
	"subtitle": 16,
	"title": 18,
	"large": 20,
	"xl": 24,
	"xxl": 32
}

# Spacing
static var spacing = {
	"xs": 2,
	"small": 4,
	"medium": 8,
	"large": 12,
	"xl": 16,
	"xxl": 24
}

# Border Radius
static var border_radius = {
	"small": 4,
	"medium": 6,
	"large": 8,
	"xl": 12,
	"round": 50
}

# Animation Durations
static var animation = {
	"fast": 0.1,
	"normal": 0.2,
	"slow": 0.3,
	"very_slow": 0.5
}

# Utility Functions
static func get_color(color_name: String) -> Color:
	return colors[current_theme].get(color_name, Color.WHITE)

static func set_theme(theme: UITheme):
	current_theme = theme

# Button Styling
static func style_button(button: Button, style: String = "default") -> void:
	var normal_style = StyleBoxFlat.new()
	var hover_style = StyleBoxFlat.new()
	var pressed_style = StyleBoxFlat.new()
	var disabled_style = StyleBoxFlat.new()
	
	match style:
		"default":
			_apply_default_button_style(normal_style, hover_style, pressed_style, disabled_style)
		"primary":
			_apply_primary_button_style(normal_style, hover_style, pressed_style, disabled_style)
		"secondary":
			_apply_secondary_button_style(normal_style, hover_style, pressed_style, disabled_style)
		"category":
			_apply_category_button_style(normal_style, hover_style, pressed_style, disabled_style)
		"flat":
			_apply_flat_button_style(normal_style, hover_style, pressed_style, disabled_style)
	
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_stylebox_override("disabled", disabled_style)

static func _apply_default_button_style(normal: StyleBoxFlat, hover: StyleBoxFlat, pressed: StyleBoxFlat, disabled: StyleBoxFlat):
	# Normal state
	normal.bg_color = get_color("surface")
	normal.border_color = get_color("border")
	_set_border_width(normal, 1)
	_set_corner_radius(normal, border_radius.medium)
	_set_content_margin(normal, spacing.medium)
	
	# Hover state
	hover.bg_color = get_color("surface").lightened(0.1)
	hover.border_color = get_color("primary")
	_set_border_width(hover, 1)
	_set_corner_radius(hover, border_radius.medium)
	_set_content_margin(hover, spacing.medium)
	
	# Pressed state
	pressed.bg_color = get_color("selection")
	pressed.border_color = get_color("selection_border")
	_set_border_width(pressed, 2)
	_set_corner_radius(pressed, border_radius.medium)
	_set_content_margin(pressed, spacing.medium)
	
	# Disabled state
	disabled.bg_color = get_color("disabled")
	disabled.border_color = get_color("disabled")
	_set_border_width(disabled, 1)
	_set_corner_radius(disabled, border_radius.medium)
	_set_content_margin(disabled, spacing.medium)

static func _apply_primary_button_style(normal: StyleBoxFlat, hover: StyleBoxFlat, pressed: StyleBoxFlat, disabled: StyleBoxFlat):
	# Normal state
	normal.bg_color = get_color("primary")
	normal.border_color = get_color("primary")
	_set_border_width(normal, 1)
	_set_corner_radius(normal, border_radius.medium)
	_set_content_margin(normal, spacing.medium)
	
	# Hover state
	hover.bg_color = get_color("primary").lightened(0.1)
	hover.border_color = get_color("primary").lightened(0.1)
	_set_border_width(hover, 1)
	_set_corner_radius(hover, border_radius.medium)
	_set_content_margin(hover, spacing.medium)
	
	# Pressed state
	pressed.bg_color = get_color("primary").darkened(0.2)
	pressed.border_color = get_color("primary").darkened(0.2)
	_set_border_width(pressed, 2)
	_set_corner_radius(pressed, border_radius.medium)
	_set_content_margin(pressed, spacing.medium)
	
	# Disabled state
	disabled.bg_color = get_color("disabled")
	disabled.border_color = get_color("disabled")
	_set_border_width(disabled, 1)
	_set_corner_radius(disabled, border_radius.medium)
	_set_content_margin(disabled, spacing.medium)

static func _apply_secondary_button_style(normal: StyleBoxFlat, hover: StyleBoxFlat, pressed: StyleBoxFlat, disabled: StyleBoxFlat):
	# Normal state
	normal.bg_color = get_color("secondary")
	normal.border_color = get_color("secondary")
	_set_border_width(normal, 1)
	_set_corner_radius(normal, border_radius.medium)
	_set_content_margin(normal, spacing.medium)
	
	# Hover state
	hover.bg_color = get_color("secondary").lightened(0.1)
	hover.border_color = get_color("secondary").lightened(0.1)
	_set_border_width(hover, 1)
	_set_corner_radius(hover, border_radius.medium)
	_set_content_margin(hover, spacing.medium)
	
	# Pressed state
	pressed.bg_color = get_color("secondary").darkened(0.2)
	pressed.border_color = get_color("secondary").darkened(0.2)
	_set_border_width(pressed, 2)
	_set_corner_radius(pressed, border_radius.medium)
	_set_content_margin(pressed, spacing.medium)
	
	# Disabled state
	disabled.bg_color = get_color("disabled")
	disabled.border_color = get_color("disabled")
	_set_border_width(disabled, 1)
	_set_corner_radius(disabled, border_radius.medium)
	_set_content_margin(disabled, spacing.medium)

static func _apply_category_button_style(normal: StyleBoxFlat, hover: StyleBoxFlat, pressed: StyleBoxFlat, disabled: StyleBoxFlat):
	# Normal state
	normal.bg_color = get_color("surface")
	normal.border_color = get_color("border")
	_set_border_width(normal, 1)
	_set_corner_radius(normal, border_radius.medium)
	_set_content_margin(normal, spacing.small)
	
	# Hover state
	hover.bg_color = get_color("surface").lightened(0.1)
	hover.border_color = get_color("accent")
	_set_border_width(hover, 2)
	_set_corner_radius(hover, border_radius.medium)
	_set_content_margin(hover, spacing.small)
	
	# Pressed state (selected)
	pressed.bg_color = get_color("accent").lightened(0.3)
	pressed.border_color = get_color("accent")
	_set_border_width(pressed, 3)
	_set_corner_radius(pressed, border_radius.medium)
	_set_content_margin(pressed, spacing.small)
	
	# Disabled state
	disabled.bg_color = get_color("disabled")
	disabled.border_color = get_color("disabled")
	_set_border_width(disabled, 1)
	_set_corner_radius(disabled, border_radius.medium)
	_set_content_margin(disabled, spacing.small)

static func _apply_flat_button_style(normal: StyleBoxFlat, hover: StyleBoxFlat, pressed: StyleBoxFlat, disabled: StyleBoxFlat):
	# Normal state
	normal.bg_color = Color.TRANSPARENT
	normal.border_color = Color.TRANSPARENT
	_set_border_width(normal, 0)
	_set_corner_radius(normal, border_radius.medium)
	_set_content_margin(normal, spacing.medium)
	
	# Hover state
	hover.bg_color = get_color("surface").lightened(0.1)
	hover.border_color = Color.TRANSPARENT
	_set_border_width(hover, 0)
	_set_corner_radius(hover, border_radius.medium)
	_set_content_margin(hover, spacing.medium)
	
	# Pressed state
	pressed.bg_color = get_color("selection")
	pressed.border_color = Color.TRANSPARENT
	_set_border_width(pressed, 0)
	_set_corner_radius(pressed, border_radius.medium)
	_set_content_margin(pressed, spacing.medium)
	
	# Disabled state
	disabled.bg_color = Color.TRANSPARENT
	disabled.border_color = Color.TRANSPARENT
	_set_border_width(disabled, 0)
	_set_corner_radius(disabled, border_radius.medium)
	_set_content_margin(disabled, spacing.medium)

# Panel Styling
static func style_panel(panel: Panel, style: String = "default") -> void:
	var panel_style = StyleBoxFlat.new()
	
	match style:
		"default":
			panel_style.bg_color = get_color("surface")
			panel_style.border_color = get_color("border")
			_set_border_width(panel_style, 1)
			_set_corner_radius(panel_style, border_radius.medium)
		"card":
			panel_style.bg_color = get_color("surface")
			panel_style.border_color = get_color("border")
			_set_border_width(panel_style, 1)
			_set_corner_radius(panel_style, border_radius.large)
			panel_style.shadow_size = 4
			panel_style.shadow_color = Color.BLACK
			panel_style.shadow_color.a = 0.1
		"battle":
			panel_style.bg_color = get_color("surface")
			panel_style.modulate = Color(1, 1, 1, 0.95)
			panel_style.border_color = get_color("border")
			_set_border_width(panel_style, 1)
			_set_corner_radius(panel_style, border_radius.large)
		"selected":
			panel_style.bg_color = get_color("selection")
			panel_style.border_color = get_color("selection_border")
			_set_border_width(panel_style, 3)
			_set_corner_radius(panel_style, border_radius.large)
		"category":
			panel_style.bg_color = get_color("surface")
			panel_style.border_color = get_color("border")
			_set_border_width(panel_style, 1)
			_set_corner_radius(panel_style, border_radius.medium)
			_set_content_margin(panel_style, spacing.medium)
	
	panel.add_theme_stylebox_override("panel", panel_style)

# Progress Bar Styling
static func style_progress_bar(progress_bar: ProgressBar, color_type: String = "primary") -> void:
	var bg_style = StyleBoxFlat.new()
	var fill_style = StyleBoxFlat.new()
	
	# Background
	bg_style.bg_color = get_color("background")
	bg_style.border_color = get_color("border")
	_set_border_width(bg_style, 1)
	_set_corner_radius(bg_style, border_radius.small)
	
	# Fill
	match color_type:
		"hp":
			fill_style.bg_color = get_color("hp_high")
		"primary":
			fill_style.bg_color = get_color("primary")
		"secondary":
			fill_style.bg_color = get_color("secondary")
		"success":
			fill_style.bg_color = get_color("success")
		"warning":
			fill_style.bg_color = get_color("warning")
		"error":
			fill_style.bg_color = get_color("error")
		_:
			fill_style.bg_color = get_color("primary")
	
	_set_corner_radius(fill_style, border_radius.small)
	
	progress_bar.add_theme_stylebox_override("background", bg_style)
	progress_bar.add_theme_stylebox_override("fill", fill_style)

# Type Badge Styling
static func style_type_badge(label: Label, type_name: String) -> void:
	var badge_style = StyleBoxFlat.new()
	_set_border_width(badge_style, 1)
	_set_corner_radius(badge_style, border_radius.small)
	_set_content_margin(badge_style, spacing.small)
	
	# Color based on type
	match type_name.to_lower():
		"alkohol":
			badge_style.bg_color = Color("#8B4513") # Brown
			badge_style.border_color = Color("#654321")
		"normal":
			badge_style.bg_color = Color("#A8A878") # Beige
			badge_style.border_color = Color("#6D6D4E")
		"party":
			badge_style.bg_color = Color("#FF1493") # Pink
			badge_style.border_color = Color("#C71585")
		"gemutlich":
			badge_style.bg_color = Color("#87CEEB") # Sky blue
			badge_style.border_color = Color("#4682B4")
		"chaos":
			badge_style.bg_color = Color("#FF4500") # Orange red
			badge_style.border_color = Color("#B22222")
		"medizin":
			badge_style.bg_color = get_color("success")
			badge_style.border_color = get_color("success").darkened(0.2)
		"fangen":
			badge_style.bg_color = get_color("accent")
			badge_style.border_color = get_color("accent").darkened(0.2)
		"boost":
			badge_style.bg_color = Color("#AF52DE") # Purple
			badge_style.border_color = Color("#9A2DDB")
		_:
			badge_style.bg_color = get_color("disabled")
			badge_style.border_color = get_color("disabled").darkened(0.2)
	
	label.add_theme_stylebox_override("normal", badge_style)
	label.add_theme_color_override("font_color", Color.WHITE)

# Utility functions for StyleBoxFlat
static func _set_border_width(style: StyleBoxFlat, width: int) -> void:
	style.border_width_left = width
	style.border_width_right = width
	style.border_width_top = width
	style.border_width_bottom = width

static func _set_corner_radius(style: StyleBoxFlat, radius: int) -> void:
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius

static func _set_content_margin(style: StyleBoxFlat, margin: int) -> void:
	style.content_margin_left = margin
	style.content_margin_right = margin
	style.content_margin_top = margin
	style.content_margin_bottom = margin

# Animation helpers
static func animate_button_press(button: Button) -> void:
	if not button:
		return
	
	var tween = button.create_tween()
	tween.set_parallel(true)
	tween.tween_property(button, "scale", Vector2(0.95, 0.95), animation.fast)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), animation.fast)

static func animate_fade_in(node: Control, duration: float = animation.normal) -> void:
	if not node:
		return
	
	node.modulate.a = 0.0
	node.visible = true
	var tween = node.create_tween()
	tween.tween_property(node, "modulate:a", 1.0, duration)

static func animate_fade_out(node: Control, duration: float = animation.normal) -> void:
	if not node:
		return
	
	var tween = node.create_tween()
	tween.tween_property(node, "modulate:a", 0.0, duration)
	tween.tween_callback(func(): node.visible = false)

static func animate_slide_in(node: Control, direction: Vector2, duration: float = animation.normal) -> void:
	if not node:
		return
	
	var original_position = node.position
	node.position = original_position + direction
	node.visible = true
	var tween = node.create_tween()
	tween.tween_property(node, "position", original_position, duration)

static func animate_bounce(node: Control, intensity: float = 1.2, duration: float = animation.fast) -> void:
	if not node:
		return
	
	var tween = node.create_tween()
	tween.set_parallel(true)
	tween.tween_property(node, "scale", Vector2(intensity, intensity), duration / 2)
	tween.tween_property(node, "scale", Vector2(1.0, 1.0), duration / 2)

# HP Color Helper
static func get_hp_color(hp_percent: float) -> Color:
	if hp_percent > 0.5:
		return get_color("hp_high")
	elif hp_percent > 0.2:
		return get_color("hp_medium")
	else:
		return get_color("hp_low")

# Font styling
static func style_font(label: Label, size: String = "body", weight: String = "normal") -> void:
	if font_sizes.has(size):
		label.add_theme_font_size_override("font_size", font_sizes[size])
	
	match weight:
		"normal":
			label.add_theme_color_override("font_color", get_color("text"))
		"secondary":
			label.add_theme_color_override("font_color", get_color("text_secondary"))
		"bold":
			label.add_theme_color_override("font_color", get_color("text"))
			# Note: Bold would require loading a bold font resource