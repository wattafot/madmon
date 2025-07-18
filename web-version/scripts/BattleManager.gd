extends Node2D

# Battle participants
var enemy_trainer_name = "Anführer BENEDIKT"
var enemy_fighter_name = "BOBO"
var player_trainer_name = "Kleines Pokemon"
var player_fighter_name = "FRIEDER"

# UI References
@onready var enemy_name_label = $UI/StatusBars/FoeStatusBar/FoeNameLevel
@onready var enemy_hp_bar = $UI/StatusBars/FoeStatusBar/FoeHPBar
@onready var player_name_label = $UI/StatusBars/AllyStatusBar/AllyNameLevel
@onready var player_hp_bar = $UI/StatusBars/AllyStatusBar/AllyHPBar
@onready var player_hp_text = $UI/StatusBars/AllyStatusBar/AllyHPText
@onready var player_xp_bar = $UI/StatusBars/AllyStatusBar/AllyXPBar
@onready var battle_text = $UI/BattleText/TextLabel
@onready var command_box = $UI/CommandGrid
@onready var battle_text_box = $UI/BattleText
@onready var attack_button = $UI/CommandGrid/FightButton
@onready var bag_button = $UI/CommandGrid/ItemsButton
@onready var humans_button = $UI/CommandGrid/SwitchButton
@onready var run_button = $UI/CommandGrid/RunButton

# Battle state
enum BattlePhase {
	INTRO,
	PLAYER_TURN,
	ENEMY_TURN,
	BATTLE_END
}

var current_phase = BattlePhase.INTRO
var game_state_manager = null

# Button navigation system
var button_array = []
var current_button_index = 0

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	# Get game state manager
	game_state_manager = get_node("/root/GameStateManager")
	
	# Setup UI styling first
	_setup_ui_styling()
	
	# Start battle sequence
	_start_battle_intro()

func _start_battle_intro():
	# Set up UI
	enemy_name_label.text = enemy_fighter_name + "    Lv11"
	player_name_label.text = player_fighter_name + "    Lv9"
	
	# Setup HP bars with color coding
	_update_hp_bar_colors()
	
	# Set initial battle text
	battle_text.text = enemy_trainer_name + " fordert dich heraus!\n\nWas soll dein Pokémon tun?"
	
	# Show text box initially, hide command box
	battle_text_box.visible = true
	command_box.visible = false
	
	# Play intro sequence
	await _play_intro_sequence()
	
	# Switch to command interface
	battle_text_box.visible = false
	command_box.visible = true
	current_phase = BattlePhase.PLAYER_TURN
	
	# Connect button signals
	_connect_battle_buttons()

func _play_intro_sequence():
	# Simple intro delay without sprites
	await get_tree().create_timer(1.0).timeout

# ============================================================================
# INPUT HANDLING
# ============================================================================

func _input(event):
	if current_phase == BattlePhase.PLAYER_TURN and event.is_pressed():
		if event.is_action("ui_cancel"):
			# Return to exploration (flee)
			_end_battle()
		elif event.is_action("ui_right") or event.is_action("ui_left"):
			# Navigate horizontally between buttons
			_navigate_buttons_horizontal(event.is_action("ui_right"))
		elif event.is_action("ui_down") or event.is_action("ui_up"):
			# Navigate vertically between buttons
			_navigate_buttons_vertical(event.is_action("ui_down"))
		elif event.is_action("ui_accept"):
			# Press the currently selected button
			_press_current_button()
		elif event is InputEventKey:
			# Handle WASD navigation
			_handle_wasd_input(event)

func _end_battle():
	if game_state_manager:
		game_state_manager.change_state(game_state_manager.GameState.EXPLORING)
		# Return to main scene
		get_tree().change_scene_to_file("res://scenes/main.tscn")

# ============================================================================
# HP BAR SYSTEM
# ============================================================================

func _update_hp_bar_colors():
	# Universal HP/Motivation color system
	var healthy_green = Color("#32CD32")      # Forest green for 51-100%
	var warning_yellow = Color("#FFFF00")     # Bright yellow for 21-50%
	var critical_red = Color("#FF0000")       # Alert red for 0-20%
	
	# Enemy HP bar color coding
	var enemy_hp_percent = enemy_hp_bar.value / enemy_hp_bar.max_value
	if enemy_hp_percent > 0.51:
		enemy_hp_bar.modulate = healthy_green
	elif enemy_hp_percent > 0.21:
		enemy_hp_bar.modulate = warning_yellow
	else:
		enemy_hp_bar.modulate = critical_red
		# Add blinking effect for critical HP
		if enemy_hp_percent <= 0.20:
			_add_critical_blink(enemy_hp_bar)
	
	# Player HP bar color coding (identical system)
	var player_hp_percent = player_hp_bar.value / player_hp_bar.max_value
	if player_hp_percent > 0.51:
		player_hp_bar.modulate = healthy_green
	elif player_hp_percent > 0.21:
		player_hp_bar.modulate = warning_yellow
	else:
		player_hp_bar.modulate = critical_red
		# Add blinking effect for critical HP
		if player_hp_percent <= 0.20:
			_add_critical_blink(player_hp_bar)
	
	# Update player HP text
	player_hp_text.text = str(int(player_hp_bar.value)) + "/" + str(int(player_hp_bar.max_value))

func _add_critical_blink(hp_bar):
	# Create pulsing effect for critical HP
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(hp_bar, "modulate:a", 0.3, 0.5)
	tween.tween_property(hp_bar, "modulate:a", 1.0, 0.5)

# ============================================================================
# UI STYLING SYSTEM
# ============================================================================

func _setup_ui_styling():
	# Get UI component references
	var enemy_status_bar = $UI/StatusBars/FoeStatusBar
	var player_status_bar = $UI/StatusBars/AllyStatusBar
	var command_grid = $UI/CommandGrid
	var battle_text_panel = $UI/BattleText
	
	# Enemy combat box (top-left) - light red/orange theme with black text
	var enemy_style = StyleBoxFlat.new()
	enemy_style.bg_color = Color("#FFE4E1")  # Light red/pink background
	enemy_style.border_color = Color("#FF6B6B")  # Red border
	enemy_style.border_width_left = 2
	enemy_style.border_width_right = 2
	enemy_style.border_width_top = 2
	enemy_style.border_width_bottom = 2
	enemy_style.corner_radius_top_left = 15
	enemy_style.corner_radius_top_right = 15
	enemy_style.corner_radius_bottom_left = 15
	enemy_style.corner_radius_bottom_right = 15
	enemy_status_bar.add_theme_stylebox_override("panel", enemy_style)
	
	# Player combat box (bottom-right) - light blue/green theme with black text
	var player_style = StyleBoxFlat.new()
	player_style.bg_color = Color("#E6F3FF")  # Light blue background
	player_style.border_color = Color("#4A90E2")  # Blue border
	player_style.border_width_left = 2
	player_style.border_width_right = 2
	player_style.border_width_top = 2
	player_style.border_width_bottom = 2
	player_style.corner_radius_top_left = 15
	player_style.corner_radius_top_right = 15
	player_style.corner_radius_bottom_left = 15
	player_style.corner_radius_bottom_right = 15
	player_status_bar.add_theme_stylebox_override("panel", player_style)
	
	# XP bar styling with cyan/violet
	var xp_cyan = Color("#00BFFF")  # Deep sky blue for progress
	player_xp_bar.modulate = xp_cyan
	
	# Battle text box styling with rounded corners
	var text_style = StyleBoxFlat.new()
	text_style.bg_color = Color("#FFFFFF")  # White background
	text_style.border_color = Color("#CCCCCC")  # Light gray border
	text_style.border_width_left = 1
	text_style.border_width_right = 1
	text_style.border_width_top = 1
	text_style.border_width_bottom = 1
	text_style.corner_radius_top_left = 10
	text_style.corner_radius_top_right = 10
	text_style.corner_radius_bottom_left = 10
	text_style.corner_radius_bottom_right = 10
	battle_text_panel.add_theme_stylebox_override("panel", text_style)
	
	# Style all text for better contrast
	_style_text_elements()

func _style_text_elements():
	# Text color for maximum contrast on light backgrounds
	var text_black = Color("#000000")
	var status_purple = Color("#9932CC")  # Purple for status effects
	
	# Enemy box text - black for contrast against light red
	enemy_name_label.add_theme_color_override("font_color", text_black)
	$UI/StatusBars/FoeStatusBar/FoeHPLabel.add_theme_color_override("font_color", text_black)
	
	# Player box text - black for contrast against light blue
	player_name_label.add_theme_color_override("font_color", text_black)
	$UI/StatusBars/AllyStatusBar/AllyHPLabel.add_theme_color_override("font_color", text_black)
	$UI/StatusBars/AllyStatusBar/AllyXPLabel.add_theme_color_override("font_color", text_black)
	player_hp_text.add_theme_color_override("font_color", text_black)
	
	# Battle text - black for contrast against white
	battle_text.add_theme_color_override("font_color", text_black)
	
	# Command buttons - enhanced styling with selection cursor
	_style_command_buttons()

func _style_command_buttons():
	# Command button styling with selection highlighting and rounded corners
	var buttons = [attack_button, bag_button, humans_button, run_button]
	
	for button in buttons:
		# Create rounded style for normal state
		var normal_style = StyleBoxFlat.new()
		normal_style.bg_color = Color("#F0F0F0")
		normal_style.border_color = Color("#CCCCCC")
		normal_style.border_width_left = 1
		normal_style.border_width_right = 1
		normal_style.border_width_top = 1
		normal_style.border_width_bottom = 1
		normal_style.corner_radius_top_left = 8
		normal_style.corner_radius_top_right = 8
		normal_style.corner_radius_bottom_left = 8
		normal_style.corner_radius_bottom_right = 8
		button.add_theme_stylebox_override("normal", normal_style)
		
		# Create rounded style for hover state
		var hover_style = StyleBoxFlat.new()
		hover_style.bg_color = Color("#FFFF00")  # Bright yellow for cursor/selection
		hover_style.border_color = Color("#FFA500")
		hover_style.border_width_left = 2
		hover_style.border_width_right = 2
		hover_style.border_width_top = 2
		hover_style.border_width_bottom = 2
		hover_style.corner_radius_top_left = 8
		hover_style.corner_radius_top_right = 8
		hover_style.corner_radius_bottom_left = 8
		hover_style.corner_radius_bottom_right = 8
		button.add_theme_stylebox_override("hover", hover_style)
		
		# Text color
		button.add_theme_color_override("font_color", Color("#000000"))
		button.add_theme_color_override("font_color_hover", Color("#000000"))
		button.add_theme_color_override("font_color_pressed", Color("#000000"))


func _add_status_effect_display(character_name: String, effect_name: String):
	# Add status effect with purple/pink styling
	var status_purple = Color("#9932CC")  # Purple for status effects
	var status_text = "[" + effect_name + "]"
	
	# This would be implemented based on your status effect system
	# For now, we'll prepare the styling

# ============================================================================
# BUTTON NAVIGATION SYSTEM
# ============================================================================

func _connect_battle_buttons():
	attack_button.pressed.connect(_on_attack_pressed)
	bag_button.pressed.connect(_on_bag_pressed)
	humans_button.pressed.connect(_on_humans_pressed)
	run_button.pressed.connect(_on_run_pressed)
	
	# Setup button array for navigation
	button_array = [attack_button, humans_button, bag_button, run_button]
	current_button_index = 0
	_update_button_selection()

func _handle_wasd_input(event):
	if event.keycode == KEY_W or event.keycode == KEY_S:
		_navigate_buttons_vertical(event.keycode == KEY_S)
	elif event.keycode == KEY_A or event.keycode == KEY_D:
		_navigate_buttons_horizontal(event.keycode == KEY_D)
	elif event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
		_press_current_button()

func _navigate_buttons_horizontal(go_right: bool):
	if go_right:
		current_button_index = (current_button_index + 1) % 2 + (current_button_index / 2) * 2
	else:
		current_button_index = (current_button_index - 1) % 2 + (current_button_index / 2) * 2
		if current_button_index < 0:
			current_button_index = 1 + (current_button_index / 2) * 2
	_update_button_selection()

func _navigate_buttons_vertical(go_down: bool):
	if go_down:
		current_button_index = (current_button_index + 2) % 4
	else:
		current_button_index = (current_button_index - 2) % 4
		if current_button_index < 0:
			current_button_index += 4
	_update_button_selection()

func _press_current_button():
	if current_button_index < button_array.size():
		button_array[current_button_index].pressed.emit()

func _update_button_selection():
	# Reset all buttons to normal style
	for i in range(button_array.size()):
		var button = button_array[i]
		if i == current_button_index:
			# Highlight selected button
			_set_button_selected(button, true)
		else:
			# Set button to normal state
			_set_button_selected(button, false)

func _set_button_selected(button: Button, selected: bool):
	if selected:
		# Create selected style with bright border
		var selected_style = StyleBoxFlat.new()
		selected_style.bg_color = Color("#FFFACD")  # Light yellow background
		selected_style.border_color = Color("#FF4500")  # Orange border
		selected_style.border_width_left = 3
		selected_style.border_width_right = 3
		selected_style.border_width_top = 3
		selected_style.border_width_bottom = 3
		selected_style.corner_radius_top_left = 8
		selected_style.corner_radius_top_right = 8
		selected_style.corner_radius_bottom_left = 8
		selected_style.corner_radius_bottom_right = 8
		button.add_theme_stylebox_override("normal", selected_style)
	else:
		# Return to normal style
		var normal_style = StyleBoxFlat.new()
		normal_style.bg_color = Color("#F0F0F0")
		normal_style.border_color = Color("#CCCCCC")
		normal_style.border_width_left = 1
		normal_style.border_width_right = 1
		normal_style.border_width_top = 1
		normal_style.border_width_bottom = 1
		normal_style.corner_radius_top_left = 8
		normal_style.corner_radius_top_right = 8
		normal_style.corner_radius_bottom_left = 8
		normal_style.corner_radius_bottom_right = 8
		button.add_theme_stylebox_override("normal", normal_style)

# ============================================================================
# BATTLE ACTIONS
# ============================================================================

func _on_attack_pressed():
	_show_battle_text("Wähle eine Attacke für " + player_fighter_name + "!\n\n(Attack menu would open here)")

func _on_bag_pressed():
	_show_battle_text("Was möchtest du aus dem Beutel nehmen?\n\n(Bag menu would open here)")

func _on_humans_pressed():
	_show_battle_text("Welchen Menschen möchtest du einsetzen?\n\n(Human selection would open here)")

func _on_run_pressed():
	_show_battle_text("Du kannst nicht vor einem Trainer-Kampf fliehen!")
	run_button.disabled = true

func _show_battle_text(text: String):
	battle_text.text = text
	battle_text_box.visible = true
	command_box.visible = false
	
	# Auto-switch back to commands after a delay
	await get_tree().create_timer(2.0).timeout
	battle_text_box.visible = false
	command_box.visible = true

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

func get_battle_data():
	return {
		"enemy_trainer": enemy_trainer_name,
		"enemy_fighter": enemy_fighter_name,
		"player_trainer": player_trainer_name,
		"player_fighter": player_fighter_name
	}