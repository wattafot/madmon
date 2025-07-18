extends Node2D

# Performance-optimized Battle Manager with external data integration
# Version 2.0 - Improved architecture for Menschen-System compatibility

# Visual effects managers
var particle_manager: ParticleManager
var camera_effects: CameraEffects
var floating_text_manager: FloatingTextManager

# Status effect managers
var player_status_manager: StatusEffectManager
var enemy_status_manager: StatusEffectManager

# Battle participants
var enemy_trainer_name = "Anführer BENEDIKT"
var enemy_fighter_name = "BOBO"
var player_trainer_name = "Kleines Pokemon"
var player_fighter_name = "FRIEDER"

# External data management
var data_manager: Node = null
var save_manager: Node = null

# Current enemy configuration
var current_enemy_id = "benedikt"

# Cached UI styles for performance
var cached_ui_styles: Dictionary = {}

# Legacy enemy database (will be removed when DataManager is fully integrated)
var enemy_database = {
	"benedikt": {
		"trainer_name": "Bene der Mitteldicke",
		"fighter_name": "Bene",
		"fighter_level": 1,
		"title": "Der Träge",
		"fighter_type": AttackType.GEMUTLICH,
		"attacks": [
			{
				"name": "Schwerfälliger Hieb",
				"type": AttackType.NORMAL,
				"category": AttackCategory.PHYSICAL,
				"base_power": 70,
				"accuracy": 95,
				"max_ap": 25,
				"description": "Ein langsamer aber kräftiger Schlag",
				"priority": 0,
				"status_effect": "",
				"status_chance": 0.0
			},
			{
				"name": "Energiesparmodus",
				"type": AttackType.GEMUTLICH,
				"category": AttackCategory.STATUS,
				"base_power": 0,
				"accuracy": 100,
				"max_ap": 10,
				"description": "Erhöht Verteidigung, verhindert Angriff",
				"priority": 0,
				"status_effect": "verteidigung_hoch",
				"status_chance": 1.0
			},
			{
				"name": "Überraschungs-Sprint",
				"type": AttackType.CHAOS,
				"category": AttackCategory.PHYSICAL,
				"base_power": 50,
				"accuracy": 100,
				"max_ap": 15,
				"description": "Überraschend schneller Angriff",
				"priority": 2,
				"status_effect": "",
				"status_chance": 0.0
			},
			{
				"name": "Provozieren",
				"type": AttackType.CHAOS,
				"category": AttackCategory.STATUS,
				"base_power": 0,
				"accuracy": 75,
				"max_ap": 10,
				"description": "Macht den Gegner wütend",
				"priority": 0,
				"status_effect": "wütend",
				"status_chance": 0.60
			}
		]
	},
	"example_trainer": {
		"trainer_name": "Trainer EXAMPLE",
		"fighter_name": "DEMO",
		"fighter_level": 10,
		"title": "Der Beispiel-Trainer",
		"fighter_type": AttackType.NORMAL,
		"attacks": [
			{
				"name": "Grundschlag",
				"type": AttackType.NORMAL,
				"category": AttackCategory.PHYSICAL,
				"base_power": 50,
				"accuracy": 100,
				"max_ap": 30,
				"description": "Ein einfacher Schlag",
				"priority": 0,
				"status_effect": "",
				"status_chance": 0.0
			}
		]
	},
	"party_felix": {
		"trainer_name": "Party-König FELIX",
		"fighter_name": "FEIERBIEST",
		"fighter_level": 13,
		"title": "Der Unaufhaltsame",
		"fighter_type": AttackType.PARTY,
		"attacks": [
			{
				"name": "Konfetti-Sturm",
				"type": AttackType.PARTY,
				"category": AttackCategory.SPECIAL,
				"base_power": 75,
				"accuracy": 85,
				"max_ap": 10,
				"description": "Ein bunter Angriff mit Konfetti",
				"priority": 0,
				"status_effect": "verwirrt",
				"status_chance": 0.2
			},
			{
				"name": "Musik-Attacke",
				"type": AttackType.PARTY,
				"category": AttackCategory.SPECIAL,
				"base_power": 60,
				"accuracy": 100,
				"max_ap": 20,
				"description": "Laute Musik betäubt den Gegner",
				"priority": 0,
				"status_effect": "",
				"status_chance": 0.0
			},
			{
				"name": "Tanz-Wirbel",
				"type": AttackType.PARTY,
				"category": AttackCategory.STATUS,
				"base_power": 0,
				"accuracy": 95,
				"max_ap": 15,
				"description": "Hypnotisierender Tanz",
				"priority": 0,
				"status_effect": "verwirrt",
				"status_chance": 0.8
			},
			{
				"name": "Feier-Boost",
				"type": AttackType.PARTY,
				"category": AttackCategory.STATUS,
				"base_power": 0,
				"accuracy": 100,
				"max_ap": 5,
				"description": "Verstärkt alle Werte durch Partystimmung",
				"priority": 0,
				"status_effect": "angriff_hoch",
				"status_chance": 1.0
			}
		]
	},
	"chaos_anna": {
		"trainer_name": "Chaos-Meisterin ANNA",
		"fighter_name": "WIRBELWIND",
		"fighter_level": 14,
		"title": "Die Unberechenbare",
		"fighter_type": AttackType.CHAOS,
		"attacks": [
			{
				"name": "Zufalls-Schlag",
				"type": AttackType.CHAOS,
				"category": AttackCategory.PHYSICAL,
				"base_power": 80,
				"accuracy": 70,
				"max_ap": 15,
				"description": "Unvorhersehbarer Angriff mit variabler Stärke",
				"priority": 0,
				"status_effect": "",
				"status_chance": 0.0
			},
			{
				"name": "Verwirrung-Welle",
				"type": AttackType.CHAOS,
				"category": AttackCategory.STATUS,
				"base_power": 0,
				"accuracy": 90,
				"max_ap": 10,
				"description": "Stiftet totale Verwirrung",
				"priority": 0,
				"status_effect": "verwirrt",
				"status_chance": 0.9
			},
			{
				"name": "Überraschungs-Hieb",
				"type": AttackType.CHAOS,
				"category": AttackCategory.PHYSICAL,
				"base_power": 40,
				"accuracy": 100,
				"max_ap": 25,
				"description": "Schneller, unerwarteter Angriff",
				"priority": 3,
				"status_effect": "",
				"status_chance": 0.0
			},
			{
				"name": "Totales Chaos",
				"type": AttackType.CHAOS,
				"category": AttackCategory.SPECIAL,
				"base_power": 100,
				"accuracy": 50,
				"max_ap": 5,
				"description": "Alles oder nichts - maximale Kraft oder Fehlschlag",
				"priority": 0,
				"status_effect": "betrunken",
				"status_chance": 0.5
			}
		]
	},
	"wild_mario": {
		"trainer_name": "Wilder MARIO",
		"fighter_name": "MARIO",
		"fighter_level": 8,
		"title": "Der Sprungmeister",
		"fighter_type": AttackType.NORMAL,
		"base_speed": 70,  # Ziemlich schnell
		"attacks": [
			{
				"name": "Sprung-Attacke",
				"type": AttackType.NORMAL,
				"category": AttackCategory.PHYSICAL,
				"base_power": 60,
				"accuracy": 100,
				"max_ap": 20,
				"description": "Ein kraftvoller Sprung-Angriff",
				"priority": 0,
				"status_effect": "",
				"status_chance": 0.0
			},
			{
				"name": "Münzen-Wurf",
				"type": AttackType.NORMAL,
				"category": AttackCategory.PHYSICAL,
				"base_power": 40,
				"accuracy": 95,
				"max_ap": 25,
				"description": "Wirft Münzen nach dem Gegner",
				"priority": 0,
				"status_effect": "",
				"status_chance": 0.0
			},
			{
				"name": "Giftige Röhre",
				"type": AttackType.CHAOS,
				"category": AttackCategory.SPECIAL,
				"base_power": 30,
				"accuracy": 90,
				"max_ap": 15,
				"description": "Spuckt Gift aus einer Röhre",
				"priority": 0,
				"status_effect": "vergiftet",
				"status_chance": 0.8
			},
			{
				"name": "Feuer-Blume",
				"type": AttackType.CHAOS,
				"category": AttackCategory.SPECIAL,
				"base_power": 55,
				"accuracy": 85,
				"max_ap": 10,
				"description": "Verbrennt den Gegner mit Feuer",
				"priority": 0,
				"status_effect": "verbrennung",
				"status_chance": 0.6
			}
		]
	}
}

# Current enemy configuration (already declared at top)

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
@onready var attack_menu = $UI/AttackMenu
@onready var attack_grid = $UI/AttackMenu/AttackGrid

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

# Attack system
enum AttackType {
	NORMAL,
	ALKOHOL,
	GEMUTLICH,
	PARTY,
	CHAOS
}

enum AttackCategory {
	PHYSICAL,
	SPECIAL,
	STATUS
}

class Attack:
	var name: String
	var type: AttackType
	var category: AttackCategory
	var base_power: int
	var accuracy: int
	var max_ap: int
	var current_ap: int
	var description: String
	var priority: int = 0
	var crit_ratio: float = 0.0625 # 1/16 chance
	var status_effect: String = ""
	var status_chance: float = 0.0
	
	func _init(n: String, t: AttackType, c: AttackCategory, power: int, acc: int, ap: int, desc: String, prio: int = 0, effect: String = "", effect_chance: float = 0.0):
		name = n
		type = t
		category = c
		base_power = power
		accuracy = acc
		max_ap = ap
		current_ap = ap
		description = desc
		priority = prio
		status_effect = effect
		status_chance = effect_chance

# Fighter data
var player_attacks = []
var enemy_attacks = []
var attack_menu_active = false
var current_attack_index = 0

# Status effect tracking
var player_status_effects = {}
var enemy_status_effects = {}

# UI references for status effects
@onready var player_status_container = $UI/StatusBars/AllyStatusBar/AllyStatusEffects
@onready var enemy_status_container = $UI/StatusBars/FoeStatusBar/FoeStatusEffects

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	# Get core managers
	game_state_manager = get_node("/root/GameStateManager")
	data_manager = get_node_or_null("/root/DataManager")
	save_manager = get_node_or_null("/root/SaveManager")
	
	# Initialize cached UI styles for performance
	_initialize_ui_style_cache()
	
	# Wait for data manager to load if available
	if data_manager and not data_manager.is_data_loaded():
		data_manager.data_loaded.connect(_on_data_loaded)
		data_manager.data_load_failed.connect(_on_data_load_failed)
	else:
		_initialize_battle_system()

func _on_data_loaded():
	print("BattleManager: Data loaded successfully, initializing battle system")
	_initialize_battle_system()

func _on_data_load_failed(error: String):
	print("BattleManager: Data load failed: ", error, " - Using fallback data")
	_initialize_battle_system()

func _initialize_battle_system():
	# Initialize attack sets
	_initialize_attacks()
	
	# Setup UI styling
	_setup_ui_styling()
	
	# Setup visual effects and status managers
	_setup_visual_effects()
	
	# Start battle sequence
	_start_battle_intro()

func _setup_visual_effects():
	# Create and initialize ParticleManager
	particle_manager = ParticleManager.new()
	add_child(particle_manager)
	
	# Create and initialize CameraEffects
	camera_effects = CameraEffects.new()
	add_child(camera_effects)
	
	# Initialize camera effects with the current camera
	var camera = get_viewport().get_camera_2d()
	if camera:
		camera_effects.initialize_camera(camera)
	
	# Create and initialize FloatingTextManager
	floating_text_manager = FloatingTextManager.new()
	add_child(floating_text_manager)
	
	# Create and initialize StatusEffectManagers
	player_status_manager = preload("res://scripts/StatusEffectManager.gd").new()
	player_status_manager.set_owner_name(player_fighter_name)
	player_status_manager.position = Vector2(50, 50)  # Top-left for player
	add_child(player_status_manager)
	
	enemy_status_manager = preload("res://scripts/StatusEffectManager.gd").new()
	enemy_status_manager.set_owner_name(enemy_fighter_name)
	enemy_status_manager.position = Vector2(950, 50)  # Top-right for enemy
	add_child(enemy_status_manager)

func _initialize_ui_style_cache():
	# Pre-create commonly used UI styles for performance
	print("BattleManager: Initializing UI style cache...")
	
	# Enemy status bar style
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
	cached_ui_styles["enemy_status_bar"] = enemy_style
	
	# Player status bar style
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
	cached_ui_styles["player_status_bar"] = player_style
	
	# Button normal style
	var button_normal_style = StyleBoxFlat.new()
	button_normal_style.bg_color = Color("#F0F0F0")
	button_normal_style.border_color = Color("#CCCCCC")
	button_normal_style.border_width_left = 1
	button_normal_style.border_width_right = 1
	button_normal_style.border_width_top = 1
	button_normal_style.border_width_bottom = 1
	button_normal_style.corner_radius_top_left = 8
	button_normal_style.corner_radius_top_right = 8
	button_normal_style.corner_radius_bottom_left = 8
	button_normal_style.corner_radius_bottom_right = 8
	cached_ui_styles["button_normal"] = button_normal_style
	
	# Button selected style
	var button_selected_style = StyleBoxFlat.new()
	button_selected_style.bg_color = Color("#FFFACD")  # Light yellow background
	button_selected_style.border_color = Color("#FF4500")  # Orange border
	button_selected_style.border_width_left = 3
	button_selected_style.border_width_right = 3
	button_selected_style.border_width_top = 3
	button_selected_style.border_width_bottom = 3
	button_selected_style.corner_radius_top_left = 8
	button_selected_style.corner_radius_top_right = 8
	button_selected_style.corner_radius_bottom_left = 8
	button_selected_style.corner_radius_bottom_right = 8
	cached_ui_styles["button_selected"] = button_selected_style
	
	# Attack panel normal style
	var attack_panel_normal = StyleBoxFlat.new()
	attack_panel_normal.bg_color = Color("#FFFFFF")
	attack_panel_normal.border_color = Color("#DDDDDD")
	attack_panel_normal.border_width_left = 1
	attack_panel_normal.border_width_right = 1
	attack_panel_normal.border_width_top = 1
	attack_panel_normal.border_width_bottom = 1
	attack_panel_normal.corner_radius_top_left = 8
	attack_panel_normal.corner_radius_top_right = 8
	attack_panel_normal.corner_radius_bottom_left = 8
	attack_panel_normal.corner_radius_bottom_right = 8
	cached_ui_styles["attack_panel_normal"] = attack_panel_normal
	
	# Attack panel selected style
	var attack_panel_selected = StyleBoxFlat.new()
	attack_panel_selected.bg_color = Color("#FFFACD")  # Light yellow
	attack_panel_selected.border_color = Color("#FF4500")  # Orange border
	attack_panel_selected.border_width_left = 3
	attack_panel_selected.border_width_right = 3
	attack_panel_selected.border_width_top = 3
	attack_panel_selected.border_width_bottom = 3
	attack_panel_selected.corner_radius_top_left = 8
	attack_panel_selected.corner_radius_top_right = 8
	attack_panel_selected.corner_radius_bottom_left = 8
	attack_panel_selected.corner_radius_bottom_right = 8
	cached_ui_styles["attack_panel_selected"] = attack_panel_selected
	
	print("BattleManager: UI style cache initialized with ", cached_ui_styles.size(), " styles")

func _start_battle_intro():
	# Load enemy data from database
	_load_enemy_data()
	
	# Set up UI
	enemy_name_label.text = enemy_fighter_name + "    Lv" + str(_get_enemy_level())
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

func _load_enemy_data():
	# Load enemy data from database
	if current_enemy_id in enemy_database:
		var enemy_data = enemy_database[current_enemy_id]
		enemy_trainer_name = enemy_data["trainer_name"]
		enemy_fighter_name = enemy_data["fighter_name"]
		print("Loaded enemy: ", enemy_trainer_name, " with ", enemy_fighter_name)
	else:
		print("Warning: Enemy ID '", current_enemy_id, "' not found in database. Using default.")
		# Fallback to hardcoded values
		enemy_trainer_name = "Anführer BENEDIKT"
		enemy_fighter_name = "BOBO"

func _get_enemy_level() -> int:
	if current_enemy_id in enemy_database:
		return enemy_database[current_enemy_id]["fighter_level"]
	return 11 # Default level

func _get_enemy_type() -> AttackType:
	if current_enemy_id in enemy_database:
		return enemy_database[current_enemy_id]["fighter_type"]
	return AttackType.GEMUTLICH # Default type

func set_enemy(enemy_id: String):
	# Public function to set which enemy to battle
	if enemy_id in enemy_database:
		current_enemy_id = enemy_id
		print("Enemy set to: ", enemy_id)
	else:
		print("Error: Enemy ID '", enemy_id, "' not found in database!")

func add_enemy_to_database(enemy_id: String, enemy_data: Dictionary):
	# Public function to add new enemies to the database
	# Example usage:
	# var new_enemy = {
	#     "trainer_name": "Trainer HANS",
	#     "fighter_name": "WILLI",
	#     "fighter_level": 12,
	#     "title": "Der Starke",
	#     "fighter_type": AttackType.NORMAL,
	#     "attacks": [...]
	# }
	# add_enemy_to_database("hans", new_enemy)
	enemy_database[enemy_id] = enemy_data
	print("Added enemy '", enemy_id, "' to database: ", enemy_data["trainer_name"])

func get_enemy_list() -> Array:
	# Public function to get a list of all available enemies
	return enemy_database.keys()

func test_enemy_system():
	# Test function to demonstrate the modular enemy system
	print("=== Testing Enemy Database System ===")
	print("Available enemies: ", get_enemy_list())
	
	# Test switching to different enemies
	for enemy_id in get_enemy_list():
		print("Testing enemy: ", enemy_id)
		set_enemy(enemy_id)
		var enemy_data = enemy_database[enemy_id]
		print("  - Trainer: ", enemy_data["trainer_name"])
		print("  - Fighter: ", enemy_data["fighter_name"], " Lv", enemy_data["fighter_level"])
		print("  - Type: ", enemy_data["fighter_type"])
		print("  - Attacks: ", enemy_data["attacks"].size())
	
	# Return to default enemy
	set_enemy("benedikt")
	print("=== Test Complete ===")

func add_test_status():
	# Test function to add a status effect and show it works
	print("Adding test status effect...")
	_add_status_effect(true, "betrunken", 3) # Add drunk effect to player
	_add_status_effect(false, "verwirrt", 2) # Add confused effect to enemy
	print("Status effects added successfully!")

func _initialize_attacks():
	# FRIEDER's attack set - "Der Alkoholiker"
	player_attacks = [
		Attack.new("Bier-Sturz", AttackType.ALKOHOL, AttackCategory.SPECIAL, 65, 100, 15, "Ein mächtiger Angriff mit spritzender Flüssigkeit", 0, "betrunken", 0.3),
		Attack.new("Lallender Monolog", AttackType.ALKOHOL, AttackCategory.STATUS, 0, 85, 10, "Verwirrt den Gegner mit unverständlichem Gerede", 0, "verwirrt", 0.75),
		Attack.new("Konter-Schlag", AttackType.NORMAL, AttackCategory.PHYSICAL, 60, 100, 20, "Ein schneller Vergeltungsschlag", 1, "", 0.0),
		Attack.new("Prost!", AttackType.ALKOHOL, AttackCategory.STATUS, 0, 100, 5, "Heilt eigene LP und verstärkt Angriff", 0, "angriff_hoch", 1.0)
	]
	
	# Load enemy attacks from database
	_load_enemy_attacks()

func _load_enemy_attacks():
	# Load enemy attacks from database
	enemy_attacks = []
	
	if current_enemy_id in enemy_database:
		var enemy_data = enemy_database[current_enemy_id]
		var attack_data_list = enemy_data["attacks"]
		
		for attack_data in attack_data_list:
			var attack = Attack.new(
				attack_data["name"],
				attack_data["type"],
				attack_data["category"],
				attack_data["base_power"],
				attack_data["accuracy"],
				attack_data["max_ap"],
				attack_data["description"],
				attack_data["priority"],
				attack_data["status_effect"],
				attack_data["status_chance"]
			)
			enemy_attacks.append(attack)
		
		print("Loaded ", enemy_attacks.size(), " attacks for enemy: ", current_enemy_id)
	else:
		print("Warning: Could not load attacks for enemy: ", current_enemy_id)
		# Fallback to default attacks
		enemy_attacks = [
			Attack.new("Schwerfälliger Hieb", AttackType.NORMAL, AttackCategory.PHYSICAL, 70, 95, 25, "Ein langsamer aber kräftiger Schlag", 0, "", 0.0)
		]

func _play_intro_sequence():
	# Simple intro delay without sprites
	await get_tree().create_timer(1.0).timeout

# ============================================================================
# INPUT HANDLING
# ============================================================================

func _input(event):
	if current_phase == BattlePhase.PLAYER_TURN and event.is_pressed():
		if attack_menu_active:
			_handle_attack_menu_input(event)
		else:
			# ESC key disabled - players must fight to completion
			if event.is_action("ui_right") or event.is_action("ui_left"):
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
	var healthy_green = Color("#32CD32") # Forest green for 51-100%
	var warning_yellow = Color("#FFFF00") # Bright yellow for 21-50%
	var critical_red = Color("#FF0000") # Alert red for 0-20%
	
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
	enemy_style.bg_color = Color("#FFE4E1") # Light red/pink background
	enemy_style.border_color = Color("#FF6B6B") # Red border
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
	player_style.bg_color = Color("#E6F3FF") # Light blue background
	player_style.border_color = Color("#4A90E2") # Blue border
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
	var xp_cyan = Color("#00BFFF") # Deep sky blue for progress
	player_xp_bar.modulate = xp_cyan
	
	# Battle text box styling with rounded corners
	var text_style = StyleBoxFlat.new()
	text_style.bg_color = Color("#FFFFFF") # White background
	text_style.border_color = Color("#CCCCCC") # Light gray border
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
	var status_purple = Color("#9932CC") # Purple for status effects
	
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
		hover_style.bg_color = Color("#FFFF00") # Bright yellow for cursor/selection
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
	var status_purple = Color("#9932CC") # Purple for status effects
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
		selected_style.bg_color = Color("#FFFACD") # Light yellow background
		selected_style.border_color = Color("#FF4500") # Orange border
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
	_show_attack_menu()

func _on_bag_pressed():
	_show_battle_text("Was möchtest du aus dem Beutel nehmen?\n\n(Bag menu would open here)")

func _on_humans_pressed():
	_show_battle_text("Welchen Menschen möchtest du einsetzen?\n\n(Human selection would open here)")

func _on_run_pressed():
	_show_battle_text("Du kannst nicht vor einem Trainer-Kampf fliehen!")
	run_button.disabled = true

func _show_attack_menu():
	# Hide command box and show attack menu
	command_box.visible = false
	attack_menu.visible = true
	attack_menu_active = true
	current_attack_index = 0
	
	# Update attack menu with current attack data
	_update_attack_menu_display()
	
	# Style the attack menu
	_style_attack_menu()
	
	# Update selection
	_update_attack_selection()

func _update_attack_menu_display():
	# Update each attack slot with current data
	for i in range(4):
		if i < player_attacks.size():
			var attack = player_attacks[i]
			var attack_panel = attack_grid.get_child(i)
			var vbox = attack_panel.get_child(0)
			
			# Get the new UI elements
			var hbox = vbox.get_child(0) # HBox containing name and type badge
			var attack_info = vbox.get_child(1) # AttackInfo containing AP and power
			
			var name_label = hbox.get_child(0)
			var type_badge = hbox.get_child(1)
			var ap_label = attack_info.get_child(0)
			var power_indicator = attack_info.get_child(1)
			
			# Update labels
			name_label.text = attack.name
			type_badge.text = _get_attack_type_string(attack.type)
			ap_label.text = "AP: " + str(attack.current_ap) + "/" + str(attack.max_ap)
			
			# Update type badge color
			_style_type_badge(type_badge, attack.type)
			
			# Update power indicator
			power_indicator.text = _get_power_stars(attack.base_power)
			
			# Add effectiveness indicator
			var effectiveness = _get_attack_effectiveness(attack, true)
			if effectiveness > 1.0:
				power_indicator.text += " ++"  # Super effective
			elif effectiveness < 1.0:
				power_indicator.text += " --"  # Not very effective
			
			# Gray out if no AP left
			if attack.current_ap <= 0:
				name_label.modulate = Color(0.5, 0.5, 0.5, 1.0)
				type_badge.modulate = Color(0.5, 0.5, 0.5, 1.0)
				ap_label.modulate = Color(0.5, 0.5, 0.5, 1.0)
				power_indicator.modulate = Color(0.5, 0.5, 0.5, 1.0)
			else:
				name_label.modulate = Color(0, 0, 0, 1.0)
				ap_label.modulate = Color(0, 0, 0, 1.0)
				power_indicator.modulate = Color(1, 0.8, 0, 1.0)

func _get_attack_type_string(type: AttackType) -> String:
	match type:
		AttackType.NORMAL:
			return "NORMAL"
		AttackType.ALKOHOL:
			return "ALKOHOL"
		AttackType.GEMUTLICH:
			return "GEMÜTLICH"
		AttackType.PARTY:
			return "PARTY"
		AttackType.CHAOS:
			return "CHAOS"
		_:
			return "NORMAL"

func _style_type_badge(badge: Label, type: AttackType):
	# Create StyleBox for type badge with appropriate color
	var badge_style = StyleBoxFlat.new()
	badge_style.border_width_left = 1
	badge_style.border_width_right = 1
	badge_style.border_width_top = 1
	badge_style.border_width_bottom = 1
	badge_style.corner_radius_top_left = 4
	badge_style.corner_radius_top_right = 4
	badge_style.corner_radius_bottom_left = 4
	badge_style.corner_radius_bottom_right = 4
	badge_style.content_margin_left = 4
	badge_style.content_margin_right = 4
	badge_style.content_margin_top = 2
	badge_style.content_margin_bottom = 2
	
	# Set colors based on type
	match type:
		AttackType.ALKOHOL:
			badge_style.bg_color = Color("#4A90E2") # Blue
			badge_style.border_color = Color("#357ABD")
		AttackType.NORMAL:
			badge_style.bg_color = Color("#8E8E93") # Gray
			badge_style.border_color = Color("#6D6D70")
		AttackType.GEMUTLICH:
			badge_style.bg_color = Color("#34C759") # Green
			badge_style.border_color = Color("#28A745")
		AttackType.PARTY:
			badge_style.bg_color = Color("#FF9500") # Orange
			badge_style.border_color = Color("#FF8C00")
		AttackType.CHAOS:
			badge_style.bg_color = Color("#AF52DE") # Purple
			badge_style.border_color = Color("#9A2DDB")
		_:
			badge_style.bg_color = Color("#8E8E93") # Default gray
			badge_style.border_color = Color("#6D6D70")
	
	badge.add_theme_stylebox_override("normal", badge_style)
	badge.modulate = Color.WHITE # Ensure text is white

func _get_power_stars(base_power: int) -> String:
	# Convert base power to readable power rating
	if base_power == 0:
		return "STA"  # Status move
	elif base_power <= 40:
		return "SCHWACH"  # Weak
	elif base_power <= 60:
		return "MITTEL"   # Medium
	elif base_power <= 80:
		return "STARK"    # Strong
	elif base_power <= 100:
		return "SEHR STARK"  # Very Strong
	else:
		return "EXTREM"   # Extreme

# ============================================================================
# STATUS EFFECT SYSTEM
# ============================================================================

func _add_status_effect(is_player: bool, effect_name: String, duration: int = 3):
	# Convert old effect names to new enum values
	var effect_type = _convert_status_effect_name(effect_name)
	if effect_type == -1:
		return  # Invalid effect name
	
	var status_manager = player_status_manager if is_player else enemy_status_manager
	if status_manager:
		status_manager.apply_effect(effect_type, duration)
	
	# Keep old system for compatibility
	var status_dict = player_status_effects if is_player else enemy_status_effects
	status_dict[effect_name] = duration
	_update_status_display()

func _remove_status_effect(is_player: bool, effect_name: String):
	# Convert old effect names to new enum values
	var effect_type = _convert_status_effect_name(effect_name)
	if effect_type != -1:
		var status_manager = player_status_manager if is_player else enemy_status_manager
		if status_manager:
			status_manager.remove_effect(effect_type)
	
	# Keep old system for compatibility
	var status_dict = player_status_effects if is_player else enemy_status_effects
	if effect_name in status_dict:
		status_dict.erase(effect_name)
	_update_status_display()

func _convert_status_effect_name(effect_name: String) -> int:
	"""Convert German status effect names to new enum values."""
	match effect_name:
		"vergiftet":
			return StatusEffectIndicator.StatusEffectType.POISON
		"gelähmt":
			return StatusEffectIndicator.StatusEffectType.PARALYSIS
		"verbrennung":
			return StatusEffectIndicator.StatusEffectType.BURN
		"eingefroren":
			return StatusEffectIndicator.StatusEffectType.FREEZE
		"schlaf":
			return StatusEffectIndicator.StatusEffectType.SLEEP
		"verwirrt", "betrunken":
			return StatusEffectIndicator.StatusEffectType.CONFUSION
		"angriff_hoch":
			return StatusEffectIndicator.StatusEffectType.ATTACK_BOOST
		"verteidigung_hoch":
			return StatusEffectIndicator.StatusEffectType.DEFENSE_BOOST
		"geschwindigkeit_hoch":
			return StatusEffectIndicator.StatusEffectType.SPEED_BOOST
		"angriff_schwach":
			return StatusEffectIndicator.StatusEffectType.ATTACK_DEBUFF
		"verteidigung_schwach":
			return StatusEffectIndicator.StatusEffectType.DEFENSE_DEBUFF
		"geschwindigkeit_schwach":
			return StatusEffectIndicator.StatusEffectType.SPEED_DEBUFF
		"regeneration":
			return StatusEffectIndicator.StatusEffectType.REGENERATION
		"schild":
			return StatusEffectIndicator.StatusEffectType.SHIELD
		"kritik_hoch":
			return StatusEffectIndicator.StatusEffectType.CRITICAL_BOOST
		_:
			return -1  # Invalid effect name

func _process_turn_status_effects():
	"""Process status effects at the end of each turn."""
	# Process player status effects
	if player_status_manager:
		var player_effects = player_status_manager.process_turn_effects()
		if player_effects.damage > 0:
			_apply_status_damage(true, player_effects.damage)
		if player_effects.healing > 0:
			_apply_status_healing(true, player_effects.healing)
		for message in player_effects.messages:
			_show_battle_text(message)
	
	# Process enemy status effects
	if enemy_status_manager:
		var enemy_effects = enemy_status_manager.process_turn_effects()
		if enemy_effects.damage > 0:
			_apply_status_damage(false, enemy_effects.damage)
		if enemy_effects.healing > 0:
			_apply_status_healing(false, enemy_effects.healing)
		for message in enemy_effects.messages:
			_show_battle_text(message)

func _apply_status_damage(is_player: bool, damage: int):
	"""Apply damage from status effects."""
	if is_player:
		player_hp_bar.value = max(0, player_hp_bar.value - damage)
		
		# Show damage animation
		if floating_text_manager:
			var damage_pos = player_hp_bar.global_position + Vector2(0, -20)
			FloatingTextManager.damage(damage, damage_pos, false)
	else:
		enemy_hp_bar.value = max(0, enemy_hp_bar.value - damage)
		
		# Show damage animation
		if floating_text_manager:
			var damage_pos = enemy_hp_bar.global_position + Vector2(0, -20)
			FloatingTextManager.damage(damage, damage_pos, false)
	
	# Update HP colors
	_update_hp_bar_colors()
	
	# Check for battle end
	if player_hp_bar.value <= 0 or enemy_hp_bar.value <= 0:
		_end_battle()

func _apply_status_healing(is_player: bool, healing: int):
	"""Apply healing from status effects."""
	if is_player:
		player_hp_bar.value = min(player_hp_bar.max_value, player_hp_bar.value + healing)
		
		# Show healing animation
		if floating_text_manager:
			var heal_pos = player_hp_bar.global_position + Vector2(0, -20)
			FloatingTextManager.heal(healing, heal_pos)
	else:
		enemy_hp_bar.value = min(enemy_hp_bar.max_value, enemy_hp_bar.value + healing)
		
		# Show healing animation
		if floating_text_manager:
			var heal_pos = enemy_hp_bar.global_position + Vector2(0, -20)
			FloatingTextManager.heal(healing, heal_pos)
	
	# Update HP colors
	_update_hp_bar_colors()

func _update_status_display():
	# Clear existing status badges
	for child in player_status_container.get_children():
		child.queue_free()
	for child in enemy_status_container.get_children():
		child.queue_free()
	
	# Add player status badges
	for effect in player_status_effects.keys():
		_create_status_badge(player_status_container, effect)
	
	# Add enemy status badges
	for effect in enemy_status_effects.keys():
		_create_status_badge(enemy_status_container, effect)

func _create_status_badge(container: HBoxContainer, effect_name: String):
	var badge = Label.new()
	badge.text = _get_status_german_name(effect_name)
	badge.add_theme_font_size_override("font_size", 10)
	badge.add_theme_color_override("font_color", Color.WHITE)
	
	# Create colored background
	var badge_style = StyleBoxFlat.new()
	badge_style.bg_color = _get_status_color(effect_name)
	badge_style.border_width_left = 1
	badge_style.border_width_right = 1
	badge_style.border_width_top = 1
	badge_style.border_width_bottom = 1
	badge_style.border_color = Color.WHITE
	badge_style.corner_radius_top_left = 3
	badge_style.corner_radius_top_right = 3
	badge_style.corner_radius_bottom_left = 3
	badge_style.corner_radius_bottom_right = 3
	badge_style.content_margin_left = 3
	badge_style.content_margin_right = 3
	badge_style.content_margin_top = 1
	badge_style.content_margin_bottom = 1
	
	badge.add_theme_stylebox_override("normal", badge_style)
	container.add_child(badge)

func _get_status_german_name(effect_name: String) -> String:
	match effect_name:
		"betrunken":
			return "DRUNK"
		"verwirrt":
			return "CONF"
		"müde":
			return "SLEEP"
		"wütend":
			return "ANGRY"
		"angriff_hoch":
			return "ATK+"
		"verteidigung_hoch":
			return "DEF+"
		"vergiftet":
			return "POISON"
		"verbrannt":
			return "BURN"
		"gelähmt":
			return "PARA"
		_:
			return "?"

func _get_status_color(effect_name: String) -> Color:
	match effect_name:
		"betrunken":
			return Color("#FF6B6B") # Red
		"verwirrt":
			return Color("#9B59B6") # Purple
		"müde":
			return Color("#3498DB") # Blue
		"wütend":
			return Color("#DC143C") # Crimson
		"angriff_hoch":
			return Color("#E74C3C") # Red
		"verteidigung_hoch":
			return Color("#2ECC71") # Green
		"vergiftet":
			return Color("#8E44AD") # Dark Purple
		"verbrannt":
			return Color("#E67E22") # Orange
		"gelähmt":
			return Color("#F39C12") # Yellow
		_:
			return Color("#95A5A6") # Gray

func _get_status_german_description(effect_name: String) -> String:
	match effect_name:
		"betrunken":
			return "betrunken und verwirrt"
		"verwirrt":
			return "völlig verwirrt"
		"müde":
			return "müde und schläfrig"
		"wütend":
			return "wütend und aggressiv"
		"angriff_hoch":
			return "stärker und energischer"
		"verteidigung_hoch":
			return "defensiver und robuster"
		"vergiftet":
			return "vergiftet"
		"verbrannt":
			return "verbrannt"
		"gelähmt":
			return "gelähmt"
		_:
			return "von einem Effekt betroffen"

func _style_attack_menu():
	# Apply rounded corners and styling to attack menu
	var menu_style = StyleBoxFlat.new()
	menu_style.bg_color = Color("#F8F8F8")
	menu_style.border_color = Color("#CCCCCC")
	menu_style.border_width_left = 2
	menu_style.border_width_right = 2
	menu_style.border_width_top = 2
	menu_style.border_width_bottom = 2
	menu_style.corner_radius_top_left = 15
	menu_style.corner_radius_top_right = 15
	menu_style.corner_radius_bottom_left = 15
	menu_style.corner_radius_bottom_right = 15
	attack_menu.add_theme_stylebox_override("panel", menu_style)
	
	# Style each attack slot
	for i in range(4):
		var attack_panel = attack_grid.get_child(i)
		var slot_style = StyleBoxFlat.new()
		slot_style.bg_color = Color("#FFFFFF")
		slot_style.border_color = Color("#DDDDDD")
		slot_style.border_width_left = 1
		slot_style.border_width_right = 1
		slot_style.border_width_top = 1
		slot_style.border_width_bottom = 1
		slot_style.corner_radius_top_left = 8
		slot_style.corner_radius_top_right = 8
		slot_style.corner_radius_bottom_left = 8
		slot_style.corner_radius_bottom_right = 8
		attack_panel.add_theme_stylebox_override("panel", slot_style)

func _update_attack_selection():
	# Reset all attack slots to normal
	for i in range(4):
		var attack_panel = attack_grid.get_child(i)
		if i == current_attack_index:
			# Highlight selected attack
			var selected_style = StyleBoxFlat.new()
			selected_style.bg_color = Color("#FFFACD") # Light yellow
			selected_style.border_color = Color("#FF4500") # Orange border
			selected_style.border_width_left = 3
			selected_style.border_width_right = 3
			selected_style.border_width_top = 3
			selected_style.border_width_bottom = 3
			selected_style.corner_radius_top_left = 8
			selected_style.corner_radius_top_right = 8
			selected_style.corner_radius_bottom_left = 8
			selected_style.corner_radius_bottom_right = 8
			attack_panel.add_theme_stylebox_override("panel", selected_style)
		else:
			# Normal styling
			var normal_style = StyleBoxFlat.new()
			normal_style.bg_color = Color("#FFFFFF")
			normal_style.border_color = Color("#DDDDDD")
			normal_style.border_width_left = 1
			normal_style.border_width_right = 1
			normal_style.border_width_top = 1
			normal_style.border_width_bottom = 1
			normal_style.corner_radius_top_left = 8
			normal_style.corner_radius_top_right = 8
			normal_style.corner_radius_bottom_left = 8
			normal_style.corner_radius_bottom_right = 8
			attack_panel.add_theme_stylebox_override("panel", normal_style)

func _handle_attack_menu_input(event):
	if event.is_action("ui_cancel"):
		# Return to main command menu
		_hide_attack_menu()
	elif event.is_action("ui_accept"):
		# Select current attack
		_select_attack(current_attack_index)
	elif event.is_action("ui_right") or event.is_action("ui_left"):
		# Navigate horizontally between attacks
		_navigate_attacks_horizontal(event.is_action("ui_right"))
	elif event.is_action("ui_down") or event.is_action("ui_up"):
		# Navigate vertically between attacks
		_navigate_attacks_vertical(event.is_action("ui_down"))
	elif event is InputEventKey:
		# Handle WASD navigation in attack menu
		_handle_attack_wasd_input(event)

func _hide_attack_menu():
	attack_menu.visible = false
	command_box.visible = true
	attack_menu_active = false

func _navigate_attacks_horizontal(go_right: bool):
	if go_right:
		current_attack_index = (current_attack_index + 1) % 2 + (current_attack_index / 2) * 2
	else:
		current_attack_index = (current_attack_index - 1) % 2 + (current_attack_index / 2) * 2
		if current_attack_index < 0:
			current_attack_index = 1 + (current_attack_index / 2) * 2
	_update_attack_selection()

func _navigate_attacks_vertical(go_down: bool):
	if go_down:
		current_attack_index = (current_attack_index + 2) % 4
	else:
		current_attack_index = (current_attack_index - 2) % 4
		if current_attack_index < 0:
			current_attack_index += 4
	_update_attack_selection()

func _handle_attack_wasd_input(event):
	if event.keycode == KEY_W or event.keycode == KEY_S:
		_navigate_attacks_vertical(event.keycode == KEY_S)
	elif event.keycode == KEY_A or event.keycode == KEY_D:
		_navigate_attacks_horizontal(event.keycode == KEY_D)
	elif event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
		_select_attack(current_attack_index)

func _select_attack(attack_index: int):
	if attack_index < player_attacks.size():
		var selected_attack = player_attacks[attack_index]
		
		# Check if attack has AP left
		if selected_attack.current_ap <= 0:
			# Show "no AP left" message
			_show_battle_text(selected_attack.name + " hat keine AP mehr!")
			return
		
		# Use the attack
		_execute_attack(selected_attack, true) # true = player attack

func _show_battle_text(text: String):
	battle_text.text = text
	battle_text_box.visible = true
	command_box.visible = false
	attack_menu.visible = false
	attack_menu_active = false
	
	# Auto-switch back to commands after a delay
	await get_tree().create_timer(2.0).timeout
	battle_text_box.visible = false
	command_box.visible = true

# ============================================================================
# ATTACK EXECUTION SYSTEM
# ============================================================================

func _execute_attack(attack: Attack, is_player: bool):
	# Hide all UI elements except status bars
	command_box.visible = false
	attack_menu.visible = false
	attack_menu_active = false
	battle_text_box.visible = true
	
	# Reduce AP
	attack.current_ap -= 1
	
	# Determine attacker and defender
	var attacker_name = player_fighter_name if is_player else enemy_fighter_name
	var defender_name = enemy_fighter_name if is_player else player_fighter_name
	var attacker_hp_bar = player_hp_bar if is_player else enemy_hp_bar
	var defender_hp_bar = enemy_hp_bar if is_player else player_hp_bar
	
	# Step 1: Announce the attack
	battle_text.text = attacker_name + " setzt " + attack.name + " ein!"
	await get_tree().create_timer(1.5).timeout
	
	# Step 2: Check if attack hits
	var hit_chance = randf() * 100
	if hit_chance > attack.accuracy:
		# Attack misses
		battle_text.text = attacker_name + "s Attacke geht daneben!"
		await get_tree().create_timer(1.5).timeout
		_end_attack_sequence(is_player)
		return
	
	# Step 3: Calculate damage
	var damage = _calculate_damage(attack, is_player)
	var is_critical = _check_critical_hit(attack)
	
	# Step 4: Apply damage and show effects
	if attack.category != AttackCategory.STATUS:
		# Visual hit effect
		_play_hit_animation(defender_hp_bar, is_critical)
		
		# Apply damage
		var current_hp = defender_hp_bar.value
		var new_hp = max(0, current_hp - damage)
		defender_hp_bar.value = new_hp
		
		# Update HP colors
		_update_hp_bar_colors()
		
		# Show damage feedback
		if is_critical:
			battle_text.text = "Ein kritischer Treffer!"
			await get_tree().create_timer(1.2).timeout
		
		# Show effectiveness message
		var effectiveness = _get_attack_effectiveness(attack, is_player)
		if effectiveness != 1.0:
			if effectiveness > 1.0:
				battle_text.text = "Das ist sehr effektiv!"
			else:
				battle_text.text = "Das ist nicht sehr effektiv..."
			await get_tree().create_timer(1.2).timeout
	else:
		# Status attack
		battle_text.text = _get_status_message(attack, defender_name)
		await get_tree().create_timer(1.5).timeout
	
	# Step 5: Check if defender is defeated
	if defender_hp_bar.value <= 0:
		battle_text.text = defender_name + " ist kampfunfähig!"
		await get_tree().create_timer(2.0).timeout
		_end_battle()
		return
	
	# Step 6: Apply status effects
	if attack.status_effect != "" and randf() < attack.status_chance:
		_add_status_effect(not is_player, attack.status_effect)
		battle_text.text = defender_name + " ist jetzt " + _get_status_german_description(attack.status_effect) + "!"
		await get_tree().create_timer(1.5).timeout
	
	# Step 7: Process status effects at end of turn
	_process_turn_status_effects()
	
	_end_attack_sequence(is_player)

func _calculate_damage(attack: Attack, is_player: bool) -> int:
	if attack.category == AttackCategory.STATUS:
		return 0
	
	# Base damage calculation
	var base_damage = attack.base_power
	var attacker_level = 9 if is_player else _get_enemy_level()
	var defender_level = _get_enemy_level() if is_player else 9
	
	# Level and stat modifiers
	var level_modifier = (2 * attacker_level / 5 + 2)
	var attack_stat = 65 + (attacker_level - 5) * 3 # Simulated attack stat
	var defense_stat = 60 + (defender_level - 5) * 3 # Simulated defense stat
	
	# Calculate damage
	var damage = ((level_modifier * base_damage * attack_stat / defense_stat) / 50) + 2
	
	# Apply effectiveness
	var effectiveness = _get_attack_effectiveness(attack, is_player)
	damage *= effectiveness
	
	# Apply critical hit
	if _check_critical_hit(attack):
		damage *= 1.5
	
	# Random factor (85-100%)
	var random_factor = 0.85 + randf() * 0.15
	damage *= random_factor
	
	return int(damage)

func _check_critical_hit(attack: Attack) -> bool:
	return randf() < attack.crit_ratio

func _get_attack_effectiveness(attack: Attack, is_player: bool) -> float:
	# Simplified type effectiveness system
	# In a full implementation, this would be a complex type chart
	var attacker_type = attack.type
	var defender_type = _get_enemy_type() if not is_player else AttackType.NORMAL # Enemy type from database, player is "normal"
	
	# Example effectiveness rules
	match attacker_type:
		AttackType.ALKOHOL:
			if defender_type == AttackType.GEMUTLICH:
				return 0.5 # Alcohol is not very effective against chill people
			else:
				return 1.0
		AttackType.CHAOS:
			if defender_type == AttackType.GEMUTLICH:
				return 2.0 # Chaos is very effective against chill people
			else:
				return 1.0
		AttackType.NORMAL:
			return 1.0
		_:
			return 1.0

func _get_status_message(attack: Attack, target_name: String) -> String:
	match attack.status_effect:
		"betrunken":
			return target_name + " ist jetzt betrunken und verwirrt!"
		"verwirrt":
			return target_name + " ist jetzt verwirrt!"
		"wütend":
			return target_name + " wird wütend!"
		"angriff_hoch":
			return target_name + " fühlt sich stärker!"
		"verteidigung_hoch":
			return target_name + " wird defensiver!"
		"müde":
			return target_name + " wird müde!"
		_:
			return target_name + " ist von der Attacke betroffen!"

func _play_hit_animation(hp_bar: ProgressBar, is_critical: bool):
	# Screen shake effect
	var original_pos = hp_bar.position
	for i in range(8):
		hp_bar.position = original_pos + Vector2(randf_range(-3, 3), randf_range(-3, 3))
		await get_tree().create_timer(0.05).timeout
	hp_bar.position = original_pos
	
	# HP bar flash
	var flash_color = Color.RED if is_critical else Color.WHITE
	hp_bar.modulate = flash_color
	await get_tree().create_timer(0.1).timeout
	hp_bar.modulate = Color.WHITE

func _end_attack_sequence(was_player_turn: bool):
	# Switch to enemy turn if player attacked, or back to player if enemy attacked
	if was_player_turn:
		await get_tree().create_timer(0.5).timeout
		_enemy_turn()
	else:
		await get_tree().create_timer(0.5).timeout
		battle_text_box.visible = false
		command_box.visible = true
		_update_button_selection() # Reset button selection

func _enemy_turn():
	# Enemy AI chooses an attack
	var available_attacks = []
	for attack in enemy_attacks:
		if attack.current_ap > 0:
			available_attacks.append(attack)
	
	if available_attacks.size() == 0:
		# No attacks available - struggle or something
		battle_text.text = enemy_fighter_name + " hat keine Attacken mehr!"
		await get_tree().create_timer(2.0).timeout
		battle_text_box.visible = false
		command_box.visible = true
		return
	
	# Simple AI - choose random available attack
	var chosen_attack = available_attacks[randi() % available_attacks.size()]
	_execute_attack(chosen_attack, false) # false = enemy attack

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