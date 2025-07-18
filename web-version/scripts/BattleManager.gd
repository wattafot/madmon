extends Node2D

# Visual effects managers
var particle_manager: ParticleManager
var camera_effects: CameraEffects
var floating_text_manager: FloatingTextManager

# Battle participants
var enemy_trainer_name = "Anführer BENEDIKT"
var enemy_fighter_name = "BOBO"
var player_trainer_name = "Kleines Pokemon"
var player_fighter_name = "FRIEDER"

# Enemy definitions database
var enemy_database = {
	"benedikt": {
		"trainer_name": "Bene der Mitteldicke",
		"fighter_name": "Bene",
		"fighter_level": 1,
		"title": "Der Träge",
		"fighter_type": AttackType.GEMUTLICH,
		"base_speed": 30,  # Sehr langsam, da "träge"
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
		"base_speed": 65,  # Durchschnittliche Geschwindigkeit
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
		"base_speed": 80,  # Sehr schnell, da "unaufhaltsam"
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
		"base_speed": 95,  # Extrem schnell, da "Wirbelwind"
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
			}
		]
	}
}

# Current enemy configuration
var current_enemy_id = "benedikt"

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
@onready var attack_grid = $UI/AttackMenu/MenuContainer/AttackGrid
@onready var category_selector = $UI/AttackMenu/MenuContainer/CategorySelector
@onready var category_buttons = $UI/AttackMenu/MenuContainer/CategorySelector/CategoryButtons
@onready var tab_medizin = $UI/AttackMenu/MenuContainer/CategorySelector/CategoryButtons/TabMedizin
@onready var tab_fanggeraete = $UI/AttackMenu/MenuContainer/CategorySelector/CategoryButtons/TabFanggeraete
@onready var tab_boosts = $UI/AttackMenu/MenuContainer/CategorySelector/CategoryButtons/TabBoosts
@onready var v_separator = $UI/AttackMenu/MenuContainer/VSeparator

# Inventory integration
var inventory_manager: Node = null
var inventory_ui: Control = null
var battle_inventory_ui: Control = null
var battle_inventory_compact: Control = null

# Battle state
enum BattlePhase {
	INTRO,
	PLAYER_TURN,
	ENEMY_TURN,
	BATTLE_END
}

var current_phase = BattlePhase.INTRO
var game_state_manager = null

# Flucht-System
var is_wild_battle = true  # true = wilde Menschen, false = Trainer-Kämpfe
var escape_attempts = 0   # Zähler für Fluchtversuche (erhöht Erfolgschance)

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

# Menu modes
enum MenuMode {
	ATTACK,
	INVENTORY
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

# Menu system
var current_menu_mode = MenuMode.ATTACK
var current_inventory_items = []
var current_inventory_category = "medizin"
var is_in_tab_navigation = false
var current_tab_index = 0

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
	# Initialize visual effects systems
	_setup_visual_effects()
	
	# Get game state manager
	game_state_manager = get_node("/root/GameStateManager")
	
	# Get inventory manager
	inventory_manager = get_node_or_null("/root/InventoryManager")
	
	# Create inventory UI
	var inventory_scene = preload("res://scenes/inventory.tscn")
	inventory_ui = inventory_scene.instantiate()
	get_tree().root.add_child(inventory_ui)
	
	# Create battle inventory UI (full screen - for outside battles)
	var battle_inventory_scene = preload("res://scenes/battle_inventory.tscn")
	battle_inventory_ui = battle_inventory_scene.instantiate()
	add_child(battle_inventory_ui)
	
# Compact inventory is now integrated into the attack menu system
	
	# Connect inventory signals
	if inventory_ui:
		inventory_ui.inventory_closed.connect(_on_inventory_closed)
		inventory_ui.item_selected.connect(_on_catching_item_selected)
	
	# Connect battle inventory signals
	if battle_inventory_ui:
		battle_inventory_ui.inventory_closed.connect(_on_battle_inventory_closed)
		battle_inventory_ui.item_selected.connect(_on_battle_item_selected)
	
# Compact inventory is now integrated into the attack menu system
	
	# Initialize attack sets
	_initialize_attacks()
	
	# Setup UI styling first
	_setup_ui_styling()
	
	# Connect bag button
	if bag_button:
		bag_button.pressed.connect(_on_bag_button_pressed)
	
	# Start battle sequence
	_start_battle_intro()

func _start_battle_intro():
	# Load enemy data from database
	_load_enemy_data()
	
	# Set up battle background based on enemy type
	_setup_battle_background()
	
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

func set_wild_battle(enemy_id: String):
	# Setze einen wilden Kampf (Flucht erlaubt)
	set_enemy(enemy_id)
	set_battle_type(true)

func set_trainer_battle(enemy_id: String):
	# Setze einen Trainer-Kampf (Flucht nicht erlaubt)
	set_enemy(enemy_id)
	set_battle_type(false)

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

func test_escape_system():
	# Test function to demonstrate the escape system
	print("=== Testing Escape System ===")
	
	# Test gegen verschiedene Gegner (wilde und Trainer)
	var test_enemies = ["benedikt", "wild_mario", "party_felix", "chaos_anna"]
	
	for enemy_id in test_enemies:
		print("\nTesting escape against: ", enemy_id)
		
		# Setze Battle-Typ basierend auf Enemy-ID
		var is_wild = enemy_id.begins_with("wild_")
		if is_wild:
			set_wild_battle(enemy_id)
		else:
			set_trainer_battle(enemy_id)
		
		var player_speed = _get_player_speed()
		var enemy_speed = _get_enemy_speed()
		
		print("  Battle Type: ", "Wild" if is_wild else "Trainer")
		print("  Player Speed: ", player_speed)
		print("  Enemy Speed: ", enemy_speed)
		
		if is_wild:
			# Simuliere mehrere Flucht-Versuche
			escape_attempts = 0
			for attempt in range(1, 4):
				escape_attempts = attempt - 1
				var chance = _calculate_escape_chance()
				print("  Attempt ", attempt, ": ", int(chance * 100), "% chance")
		else:
			print("  Escape: NOT ALLOWED (Trainer Battle)")
		
		escape_attempts = 0  # Reset
	
	print("=== Escape System Test Complete ===")
	
	# Zurück zum Standard-Gegner
	set_wild_battle("benedikt")

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
	# Enhanced battle intro with dramatic effects
	if camera_effects:
		# Flash screen to white for dramatic entrance
		camera_effects.flash_screen(Color.WHITE, 0.5, 1.0)
		await get_tree().create_timer(0.3).timeout
		
		# Show enemy entrance text with screen shake
		battle_text.text = enemy_trainer_name + " erscheint!"
		if particle_manager:
			particle_manager.shake_screen(8.0, 0.4)
		
		# Dramatic zoom and camera effects
		camera_effects.dramatic_zoom_in(Vector2(1.3, 1.3), 0.8)
		await get_tree().create_timer(1.0).timeout
		
		# Focus on enemy position briefly
		if enemy_name_label:
			var enemy_pos = enemy_name_label.global_position
			camera_effects.cinematic_focus(enemy_pos, Vector2(1.2, 1.2), 0.8)
			await get_tree().create_timer(0.8).timeout
		
		# Pan to player position
		if player_name_label:
			var player_pos = player_name_label.global_position
			camera_effects.cinematic_focus(player_pos, Vector2(1.2, 1.2), 0.8)
			await get_tree().create_timer(0.8).timeout
		
		# Zoom out to battle view
		camera_effects.reset_camera(1.0)
		await get_tree().create_timer(0.5).timeout
		
		# Show battle start text with floating text
		battle_text.text = "Kampf beginnt!"
		if floating_text_manager:
			var center_pos = get_viewport().get_visible_rect().size / 2
			FloatingTextManager.special("KAMPF!", center_pos)
		
		# Final dramatic pause
		await get_tree().create_timer(1.5).timeout
	else:
		# Fallback simple intro
		await get_tree().create_timer(1.0).timeout

func _play_victory_sequence():
	# Player wins - celebratory sequence
	if camera_effects:
		# Victory effects
		camera_effects.victory_effect()
		
		# Flash screen gold
		camera_effects.flash_screen(Color.GOLD, 0.8, 0.7)
		await get_tree().create_timer(0.5).timeout
		
		# Show victory text
		battle_text.text = "Sieg! " + player_fighter_name + " hat gewonnen!"
		if floating_text_manager:
			var center_pos = get_viewport().get_visible_rect().size / 2
			FloatingTextManager.special("SIEG!", center_pos)
		
		# Victory particles
		if particle_manager:
			var victory_pos = player_name_label.global_position if player_name_label else Vector2.ZERO
			particle_manager.show_level_up_effect(victory_pos)
		
		# Play victory sound
		AudioManager.play_victory_sound()
		
		await get_tree().create_timer(3.0).timeout
	else:
		# Fallback victory
		battle_text.text = "Sieg! " + player_fighter_name + " hat gewonnen!"
		await get_tree().create_timer(2.0).timeout

func _play_defeat_sequence():
	# Player loses - dramatic defeat sequence
	if camera_effects:
		# Defeat effects
		camera_effects.add_trauma_static(0.8)
		
		# Flash screen red
		camera_effects.flash_screen(Color.RED, 1.0, 0.8)
		await get_tree().create_timer(0.5).timeout
		
		# Show defeat text
		battle_text.text = "Niederlage! " + player_fighter_name + " ist kampfunfähig!"
		if floating_text_manager:
			var center_pos = get_viewport().get_visible_rect().size / 2
			FloatingTextManager.special("NIEDERLAGE!", center_pos)
		
		# Dramatic zoom out
		camera_effects.dramatic_zoom_out(Vector2(0.6, 0.6), 1.5)
		
		# Play defeat sound
		AudioManager.play_defeat_sound()
		
		await get_tree().create_timer(3.0).timeout
	else:
		# Fallback defeat
		battle_text.text = "Niederlage! " + player_fighter_name + " ist kampfunfähig!"
		await get_tree().create_timer(2.0).timeout

func _setup_battle_background():
	# Dynamic battle background system based on enemy type and battle conditions
	var background_node = get_node_or_null("BattleBackground")
	if not background_node:
		# Create background node if it doesn't exist
		background_node = ColorRect.new()
		background_node.name = "BattleBackground"
		background_node.z_index = -100
		background_node.size = get_viewport().get_visible_rect().size
		background_node.position = Vector2.ZERO
		add_child(background_node)
		move_child(background_node, 0) # Move to back
	
	# Get enemy data for background selection
	var enemy_data = enemy_database.get(current_enemy_id, {})
	var enemy_type = enemy_data.get("fighter_type", AttackType.NORMAL)
	var enemy_level = enemy_data.get("fighter_level", 1)
	
	# Choose background based on enemy type
	var background_gradient = _create_battle_gradient(enemy_type, enemy_level)
	background_node.material = _create_animated_background_material(background_gradient)
	
	# Add atmospheric particles based on enemy type
	_add_atmospheric_effects(enemy_type)

func _create_battle_gradient(enemy_type: AttackType, enemy_level: int) -> Gradient:
	var gradient = Gradient.new()
	
	# Base colors based on enemy type
	var primary_color: Color
	var secondary_color: Color
	
	match enemy_type:
		AttackType.ALKOHOL:
			primary_color = Color("#1a1a2e") # Dark blue
			secondary_color = Color("#16213e") # Darker blue
		AttackType.PARTY:
			primary_color = Color("#ff6b6b") # Bright red
			secondary_color = Color("#feca57") # Golden yellow
		AttackType.GEMUTLICH:
			primary_color = Color("#26de81") # Soft green
			secondary_color = Color("#20bf6b") # Deeper green
		AttackType.CHAOS:
			primary_color = Color("#a55eea") # Purple
			secondary_color = Color("#fd79a8") # Pink
		AttackType.NORMAL:
			primary_color = Color("#636e72") # Gray
			secondary_color = Color("#2d3436") # Dark gray
		_:
			primary_color = Color("#74b9ff") # Light blue
			secondary_color = Color("#0984e3") # Dark blue
	
	# Intensity based on enemy level
	var intensity = min(enemy_level / 20.0, 1.0) # Max intensity at level 20
	primary_color = primary_color.lerp(Color.WHITE, intensity * 0.2)
	secondary_color = secondary_color.lerp(Color.BLACK, intensity * 0.3)
	
	gradient.add_point(0.0, primary_color)
	gradient.add_point(0.5, primary_color.lerp(secondary_color, 0.5))
	gradient.add_point(1.0, secondary_color)
	
	return gradient

func _create_animated_background_material(gradient: Gradient) -> ShaderMaterial:
	# Create animated gradient background
	var material = ShaderMaterial.new()
	
	# Simple animated gradient shader (shader code would need to be created)
	# For now, we'll use a simple gradient texture
	var texture = GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 512
	texture.height = 512
	texture.fill = GradientTexture2D.FILL_RADIAL
	
	# Apply texture to material (this would need proper shader setup)
	return material

func _add_atmospheric_effects(enemy_type: AttackType):
	# Add atmospheric particle effects based on enemy type
	if not particle_manager:
		return
	
	var atmosphere_particles = CPUParticles2D.new()
	atmosphere_particles.name = "AtmosphereParticles"
	atmosphere_particles.z_index = -50
	add_child(atmosphere_particles)
	
	# Configure atmospheric particles
	atmosphere_particles.emitting = true
	atmosphere_particles.amount = 50
	atmosphere_particles.lifetime = 8.0
	atmosphere_particles.preprocess = 2.0
	atmosphere_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	atmosphere_particles.emission_sphere_radius = 400.0
	atmosphere_particles.position = get_viewport().get_visible_rect().size / 2
	
	# Type-specific atmospheric effects
	match enemy_type:
		AttackType.ALKOHOL:
			# Floating bubbles
			atmosphere_particles.direction = Vector2(0, -1)
			atmosphere_particles.initial_velocity_min = 10.0
			atmosphere_particles.initial_velocity_max = 30.0
			atmosphere_particles.color = Color(0.8, 0.8, 1.0, 0.3)
			atmosphere_particles.scale_amount_min = 0.2
			atmosphere_particles.scale_amount_max = 0.8
		
		AttackType.PARTY:
			# Confetti-like particles
			atmosphere_particles.direction = Vector2(0, 1)
			atmosphere_particles.initial_velocity_min = 30.0
			atmosphere_particles.initial_velocity_max = 80.0
			atmosphere_particles.color = Color(1.0, 0.5, 0.8, 0.6)
			atmosphere_particles.angular_velocity_min = -360.0
			atmosphere_particles.angular_velocity_max = 360.0
		
		AttackType.GEMUTLICH:
			# Gentle floating leaves
			atmosphere_particles.direction = Vector2(0, 1)
			atmosphere_particles.initial_velocity_min = 5.0
			atmosphere_particles.initial_velocity_max = 15.0
			atmosphere_particles.color = Color(0.5, 0.8, 0.3, 0.4)
			atmosphere_particles.gravity = Vector2(0, 20)
		
		AttackType.CHAOS:
			# Chaotic energy sparks
			atmosphere_particles.direction = Vector2(0, 0)
			atmosphere_particles.initial_velocity_min = 20.0
			atmosphere_particles.initial_velocity_max = 60.0
			atmosphere_particles.color = Color(0.9, 0.2, 0.9, 0.5)
			atmosphere_particles.linear_accel_min = -50.0
			atmosphere_particles.linear_accel_max = 50.0
		
		AttackType.NORMAL:
			# Simple dust particles
			atmosphere_particles.direction = Vector2(1, 0)
			atmosphere_particles.initial_velocity_min = 5.0
			atmosphere_particles.initial_velocity_max = 20.0
			atmosphere_particles.color = Color(0.8, 0.8, 0.8, 0.2)
			atmosphere_particles.scale_amount_min = 0.1
			atmosphere_particles.scale_amount_max = 0.3
		
		_:
			# Default atmospheric effect
			atmosphere_particles.direction = Vector2(0, -1)
			atmosphere_particles.initial_velocity_min = 10.0
			atmosphere_particles.initial_velocity_max = 25.0
			atmosphere_particles.color = Color(0.7, 0.7, 1.0, 0.2)

# ============================================================================
# INPUT HANDLING
# ============================================================================

func _input(event):
	if current_phase == BattlePhase.PLAYER_TURN and event.is_pressed():
		if attack_menu_active:
			_handle_attack_menu_input(event)
		else:
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
	
	# Setze Initial-Zustand des Flucht-Buttons
	set_battle_type(is_wild_battle)

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
	_show_inventory_menu()

func _on_humans_pressed():
	_show_battle_text("Welchen Menschen möchtest du einsetzen?\n\n(Human selection would open here)")

func _on_run_pressed():
	_attempt_escape()

func _show_attack_menu():
	# Hide command box and show attack menu
	command_box.visible = false
	attack_menu.visible = true
	attack_menu_active = true
	current_attack_index = 0
	current_menu_mode = MenuMode.ATTACK
	
	# Hide category selector for attack mode
	category_selector.visible = false
	v_separator.visible = false
	
	# Update attack menu with current attack data
	_update_attack_menu_display()
	
	# Style the attack menu
	_style_attack_menu()
	
	# Update selection
	_update_attack_selection()

func _show_inventory_menu():
	# Hide command box and show attack menu (reused for inventory)
	command_box.visible = false
	attack_menu.visible = true
	attack_menu_active = true
	current_attack_index = 0
	current_menu_mode = MenuMode.INVENTORY
	current_inventory_category = "medizin"
	is_in_tab_navigation = false
	current_tab_index = 0
	
	# Show category selector for inventory
	category_selector.visible = true
	v_separator.visible = true
	
	# Connect tab signals
	_connect_tab_signals()
	
	# Update inventory menu with current items
	_update_inventory_menu_display()
	
	# Style the attack menu (same styling)
	_style_attack_menu()
	_style_inventory_categories()
	
	# Update selection
	_update_attack_selection()

func _update_inventory_menu_display():
	if not inventory_manager:
		return
	
	# Get items for current category
	var category_enum = _get_inventory_category_enum(current_inventory_category)
	var items = inventory_manager.get_inventory_by_category(category_enum)
	
	# Convert to array
	current_inventory_items = []
	for item_id in items:
		var item_data = items[item_id]
		current_inventory_items.append({
			"id": item_id,
			"name": item_data["data"]["name"],
			"quantity": item_data["quantity"],
			"data": item_data["data"],
			"usable": _is_item_usable_in_battle(item_id, item_data["data"])
		})
	
	# Update each slot with inventory items
	for i in range(4):
		var attack_panel = attack_grid.get_child(i)
		var vbox = attack_panel.get_child(0)
		
		if i < current_inventory_items.size():
			var item = current_inventory_items[i]
			
			# Get the UI elements
			var hbox = vbox.get_child(0)
			var attack_info = vbox.get_child(1)
			
			var name_label = hbox.get_child(0)
			var type_badge = hbox.get_child(1)
			var ap_label = attack_info.get_child(0)
			var power_indicator = attack_info.get_child(1)
			
			# Update labels for inventory
			name_label.text = item.name
			type_badge.text = _get_item_category_display(current_inventory_category)
			ap_label.text = "x" + str(item.quantity)
			power_indicator.text = "BENUTZEN" if item.usable else "---"
			
			# Style type badge for inventory
			_style_inventory_badge(type_badge, current_inventory_category)
			
			# Gray out if not usable
			if not item.usable:
				name_label.modulate = Color(0.5, 0.5, 0.5, 1.0)
				type_badge.modulate = Color(0.5, 0.5, 0.5, 1.0)
				ap_label.modulate = Color(0.5, 0.5, 0.5, 1.0)
				power_indicator.modulate = Color(0.5, 0.5, 0.5, 1.0)
			else:
				name_label.modulate = Color(0, 0, 0, 1.0)
				type_badge.modulate = Color.WHITE
				ap_label.modulate = Color(0, 0, 0, 1.0)
				power_indicator.modulate = Color(1, 0.8, 0, 1.0)
		else:
			# Empty slot
			var hbox = vbox.get_child(0)
			var attack_info = vbox.get_child(1)
			
			var name_label = hbox.get_child(0)
			var type_badge = hbox.get_child(1)
			var ap_label = attack_info.get_child(0)
			var power_indicator = attack_info.get_child(1)
			
			name_label.text = ""
			type_badge.text = ""
			ap_label.text = ""
			power_indicator.text = ""
	
	# Update selection highlighting
	_update_inventory_selection()

func _get_inventory_category_enum(category: String) -> int:
	match category:
		"fanggeraete":
			return 0
		"medizin":
			return 1
		"kampf_boosts":
			return 2
		_:
			return 3

func _get_item_category_display(category: String) -> String:
	match category:
		"fanggeraete":
			return "FANGEN"
		"medizin":
			return "MEDIZIN"
		"kampf_boosts":
			return "BOOST"
		_:
			return "ITEM"

func _style_inventory_badge(badge: Label, category: String):
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
	
	# Set colors based on category
	match category:
		"fanggeraete":
			badge_style.bg_color = Color("#FF9500") # Orange
			badge_style.border_color = Color("#FF8C00")
		"medizin":
			badge_style.bg_color = Color("#34C759") # Green
			badge_style.border_color = Color("#28A745")
		"kampf_boosts":
			badge_style.bg_color = Color("#AF52DE") # Purple
			badge_style.border_color = Color("#9A2DDB")
		_:
			badge_style.bg_color = Color("#8E8E93") # Gray
			badge_style.border_color = Color("#6D6D70")
	
	badge.add_theme_stylebox_override("normal", badge_style)
	badge.modulate = Color.WHITE

func _is_item_usable_in_battle(item_id: String, item_data: Dictionary) -> bool:
	var category = item_data.get("category", "")
	var team_members = _get_team_members_data()
	
	match category:
		"fanggeraete":
			return true  # Always usable in battle for now
		"medizin":
			var heal_amount = item_data.get("heal_amount", 0)
			var cures_status = item_data.get("cures_status", [])
			var revive = item_data.get("revive", false)
			
			# Check if player can benefit
			if revive and player_hp_bar.value <= 0:
				return true
			if heal_amount > 0 and player_hp_bar.value < player_hp_bar.max_value:
				return true
			if cures_status.size() > 0 and player_status_effects.size() > 0:
				return true
			return false
		"kampf_boosts":
			return true
	
	return false

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
	var status_dict = player_status_effects if is_player else enemy_status_effects
	status_dict[effect_name] = duration
	_update_status_display()

func _remove_status_effect(is_player: bool, effect_name: String):
	var status_dict = player_status_effects if is_player else enemy_status_effects
	if effect_name in status_dict:
		status_dict.erase(effect_name)
	_update_status_display()

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

func _connect_tab_signals():
	# Connect tab button signals
	if not tab_medizin.pressed.is_connected(_on_tab_medizin_pressed):
		tab_medizin.pressed.connect(_on_tab_medizin_pressed)
	if not tab_fanggeraete.pressed.is_connected(_on_tab_fanggeraete_pressed):
		tab_fanggeraete.pressed.connect(_on_tab_fanggeraete_pressed)
	if not tab_boosts.pressed.is_connected(_on_tab_boosts_pressed):
		tab_boosts.pressed.connect(_on_tab_boosts_pressed)

func _on_tab_medizin_pressed():
	current_inventory_category = "medizin"
	current_tab_index = 0
	_update_inventory_menu_display()
	_update_tab_selection()

func _on_tab_fanggeraete_pressed():
	current_inventory_category = "fanggeraete"
	current_tab_index = 1
	_update_inventory_menu_display()
	_update_tab_selection()

func _on_tab_boosts_pressed():
	current_inventory_category = "kampf_boosts"
	current_tab_index = 2
	_update_inventory_menu_display()
	_update_tab_selection()

func _style_inventory_categories():
	# Style the category selector panel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color("#F8F8F8")
	panel_style.border_color = Color("#CCCCCC")
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	category_selector.add_theme_stylebox_override("panel", panel_style)
	
	# Style the category buttons
	var buttons = [tab_medizin, tab_fanggeraete, tab_boosts]
	
	for i in range(buttons.size()):
		var button = buttons[i]
		
		# Normal button style
		var normal_style = StyleBoxFlat.new()
		normal_style.bg_color = Color("#E0E0E0")
		normal_style.border_color = Color("#999999")
		normal_style.border_width_left = 1
		normal_style.border_width_right = 1
		normal_style.border_width_top = 1
		normal_style.border_width_bottom = 1
		normal_style.corner_radius_top_left = 6
		normal_style.corner_radius_top_right = 6
		normal_style.corner_radius_bottom_left = 6
		normal_style.corner_radius_bottom_right = 6
		button.add_theme_stylebox_override("normal", normal_style)
		
		# Selected button style
		var selected_style = StyleBoxFlat.new()
		selected_style.bg_color = Color("#FFFACD")
		selected_style.border_color = Color("#FF4500")
		selected_style.border_width_left = 2
		selected_style.border_width_right = 2
		selected_style.border_width_top = 2
		selected_style.border_width_bottom = 2
		selected_style.corner_radius_top_left = 6
		selected_style.corner_radius_top_right = 6
		selected_style.corner_radius_bottom_left = 6
		selected_style.corner_radius_bottom_right = 6
		button.add_theme_stylebox_override("pressed", selected_style)
		
		# Text colors
		button.add_theme_color_override("font_color", Color("#000000"))
		button.add_theme_color_override("font_color_pressed", Color("#000000"))
		button.add_theme_color_override("font_color_hover", Color("#000000"))
	
	# Update initial selection
	_update_tab_selection()

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
	
	# Set battle theme for UI
	UIStyler.set_theme(UIStyler.UITheme.BATTLE)
	
	# Apply enhanced styling to key UI elements
	_apply_enhanced_styling()

func _play_enhanced_hit_animation(hp_bar: ProgressBar, is_critical: bool, attack: Attack):
	# Create hit particles
	var hit_position = hp_bar.global_position + Vector2(hp_bar.size.x / 2, hp_bar.size.y / 2)
	if particle_manager:
		var element_type = _get_attack_type_string(attack.type).to_lower()
		particle_manager.create_hit_effect(hit_position, is_critical, element_type)
	
	# Screen shake based on attack power
	if camera_effects:
		var shake_intensity = attack.base_power / 20.0
		if is_critical:
			shake_intensity *= 2.0
		camera_effects.shake_screen(shake_intensity, 0.3)
	
	# HP bar flash effect
	var original_color = hp_bar.modulate
	hp_bar.modulate = Color.RED if is_critical else Color.WHITE
	await get_tree().create_timer(0.1).timeout
	hp_bar.modulate = original_color

func _animate_hp_change(hp_bar: ProgressBar, from_hp: float, to_hp: float):
	# Smooth HP bar animation
	var tween = create_tween()
	tween.tween_property(hp_bar, "value", to_hp, 0.5)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	
	# Update HP text if it's the player's HP bar
	if hp_bar == player_hp_bar:
		tween.tween_callback(func(): 
			player_hp_text.text = str(int(to_hp)) + "/" + str(int(hp_bar.max_value))
		)

func _play_attack_announcement(attack_name: String, is_player: bool):
	# Create animated attack name display
	var announcement_label = Label.new()
	announcement_label.text = attack_name.to_upper()
	announcement_label.add_theme_font_size_override("font_size", 32)
	announcement_label.add_theme_color_override("font_color", Color.WHITE)
	announcement_label.add_theme_color_override("font_outline_color", Color.BLACK)
	announcement_label.add_theme_constant_override("outline_size", 2)
	
	# Position based on attacker
	if is_player:
		announcement_label.position = Vector2(850, 400)
	else:
		announcement_label.position = Vector2(200, 200)
	
	get_tree().current_scene.add_child(announcement_label)
	
	# Animate the announcement
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(announcement_label, "scale", Vector2(1.5, 1.5), 0.3)
	tween.tween_property(announcement_label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(announcement_label.queue_free)

func _play_attack_animation(attack: Attack, is_player: bool):
	# Animate based on attack type
	match attack.type:
		AttackType.ALKOHOL:
			await _animate_alkohol_attack(is_player)
		AttackType.PARTY:
			await _animate_party_attack(is_player)
		AttackType.CHAOS:
			await _animate_chaos_attack(is_player)
		AttackType.GEMUTLICH:
			await _animate_gemutlich_attack(is_player)
		_:
			await _animate_normal_attack(is_player)

func _animate_alkohol_attack(is_player: bool):
	# Swaying drunk animation
	if camera_effects:
		camera_effects.rotate_to(deg_to_rad(5), 0.2)
		await get_tree().create_timer(0.2).timeout
		camera_effects.rotate_to(deg_to_rad(-5), 0.2)
		await get_tree().create_timer(0.2).timeout
		camera_effects.rotate_to(0, 0.2)
	
	# Brown particle burst
	var position = Vector2(640, 360)
	if particle_manager:
		particle_manager.create_hit_effect(position, false, "alkohol")

func _animate_party_attack(is_player: bool):
	# Colorful party effects
	if camera_effects:
		camera_effects.flash_screen(Color.MAGENTA, 0.1, 0.3)
		await get_tree().create_timer(0.1).timeout
		camera_effects.flash_screen(Color.CYAN, 0.1, 0.3)
		await get_tree().create_timer(0.1).timeout
		camera_effects.flash_screen(Color.YELLOW, 0.1, 0.3)
	
	# Confetti effect
	var position = Vector2(640, 360)
	if particle_manager:
		particle_manager.create_hit_effect(position, false, "party")

func _animate_chaos_attack(is_player: bool):
	# Chaotic screen shake
	if camera_effects:
		camera_effects.add_trauma(0.8)
	
	# Multiple random particle bursts
	for i in range(3):
		var random_pos = Vector2(randf_range(200, 1080), randf_range(200, 500))
		if particle_manager:
			particle_manager.create_hit_effect(random_pos, false, "chaos")
		await get_tree().create_timer(0.1).timeout

func _animate_gemutlich_attack(is_player: bool):
	# Slow, relaxed animation
	if camera_effects:
		camera_effects.zoom_to(Vector2(1.1, 1.1), 0.5)
		await get_tree().create_timer(0.5).timeout
		camera_effects.zoom_to(Vector2(1.0, 1.0), 0.5)
	
	# Soft blue particles
	var position = Vector2(640, 360)
	if particle_manager:
		particle_manager.create_hit_effect(position, false, "gemutlich")

func _animate_normal_attack(is_player: bool):
	# Basic attack animation
	if camera_effects:
		camera_effects.shake_screen(3.0, 0.2)
	
	# Simple particle effect
	var position = Vector2(640, 360)
	if particle_manager:
		particle_manager.create_hit_effect(position, false, "normal")

func _apply_enhanced_styling():
	# Apply UIStyler styling to main UI elements
	if battle_text_box:
		UIStyler.style_panel(battle_text_box, "battle")
	
	if command_box:
		UIStyler.style_panel(command_box, "default")
	
	if attack_menu:
		UIStyler.style_panel(attack_menu, "battle")
	
	# Style command buttons
	if attack_button:
		UIStyler.style_button(attack_button, "primary")
	if command_box:
		var children = command_box.get_children()
		for child in children:
			if child is Button:
				UIStyler.style_button(child, "default")
	
	# Style progress bars
	if player_hp_bar:
		UIStyler.style_progress_bar(player_hp_bar, "hp")
	if enemy_hp_bar:
		UIStyler.style_progress_bar(enemy_hp_bar, "hp")
	if player_xp_bar:
		UIStyler.style_progress_bar(player_xp_bar, "primary")
	
	# Style category buttons
	if tab_medizin:
		UIStyler.style_button(tab_medizin, "category")
	if tab_fanggeraete:
		UIStyler.style_button(tab_fanggeraete, "category")
	if tab_boosts:
		UIStyler.style_button(tab_boosts, "category")

func _update_tab_selection():
	var tabs = [tab_medizin, tab_fanggeraete, tab_boosts]
	var categories = ["medizin", "fanggeraete", "kampf_boosts"]
	
	# Update button pressed states
	for i in range(tabs.size()):
		tabs[i].button_pressed = (categories[i] == current_inventory_category)
	
	# Update visual selection if in tab navigation
	if is_in_tab_navigation:
		for i in range(tabs.size()):
			var tab = tabs[i]
			if i == current_tab_index:
				# Highlight selected tab
				var highlight_style = StyleBoxFlat.new()
				highlight_style.bg_color = Color("#FFFF00")  # Bright yellow
				highlight_style.border_color = Color("#FF4500")
				highlight_style.border_width_left = 3
				highlight_style.border_width_right = 3
				highlight_style.border_width_top = 3
				highlight_style.border_width_bottom = 3
				highlight_style.corner_radius_top_left = 6
				highlight_style.corner_radius_top_right = 6
				highlight_style.corner_radius_bottom_left = 6
				highlight_style.corner_radius_bottom_right = 6
				tab.add_theme_stylebox_override("normal", highlight_style)
			else:
				# Normal tab style
				var normal_style = StyleBoxFlat.new()
				normal_style.bg_color = Color("#E0E0E0")
				normal_style.border_color = Color("#999999")
				normal_style.border_width_left = 1
				normal_style.border_width_right = 1
				normal_style.border_width_top = 1
				normal_style.border_width_bottom = 1
				normal_style.corner_radius_top_left = 6
				normal_style.corner_radius_top_right = 6
				normal_style.corner_radius_bottom_left = 6
				normal_style.corner_radius_bottom_right = 6
				tab.add_theme_stylebox_override("normal", normal_style)

func _update_inventory_selection():
	# Update inventory item selection highlighting
	if current_menu_mode == MenuMode.INVENTORY and not is_in_tab_navigation:
		for i in range(4):
			var attack_panel = attack_grid.get_child(i)
			if i == current_attack_index and i < current_inventory_items.size():
				# Highlight selected item
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

func _update_attack_selection():
	# Reset all attack slots to normal
	for i in range(4):
		var attack_panel = attack_grid.get_child(i)
		if i == current_attack_index and not is_in_tab_navigation:
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
		if current_menu_mode == MenuMode.ATTACK:
			# Select current attack
			_select_attack(current_attack_index)
		elif current_menu_mode == MenuMode.INVENTORY:
			if is_in_tab_navigation:
				# Select current category
				_select_current_category()
			else:
				# Select current item
				_select_inventory_item(current_attack_index)
	elif event.is_action("ui_right") or event.is_action("ui_left"):
		if current_menu_mode == MenuMode.INVENTORY:
			if event.is_action("ui_left") and not is_in_tab_navigation:
				# Move to category navigation
				is_in_tab_navigation = true
				_update_tab_selection()
				_update_attack_selection()
			elif event.is_action("ui_right") and is_in_tab_navigation:
				# Move to item navigation
				is_in_tab_navigation = false
				_update_tab_selection()
				_update_attack_selection()
			else:
				# Navigate horizontally between items
				_navigate_attacks_horizontal(event.is_action("ui_right"))
		else:
			# Navigate horizontally between attacks
			_navigate_attacks_horizontal(event.is_action("ui_right"))
	elif event.is_action("ui_down") or event.is_action("ui_up"):
		if current_menu_mode == MenuMode.INVENTORY:
			if is_in_tab_navigation:
				# Navigate between categories
				_navigate_categories_vertical(event.is_action("ui_down"))
			else:
				# Navigate vertically between items
				_navigate_attacks_vertical(event.is_action("ui_down"))
		else:
			# Navigate vertically between attacks
			_navigate_attacks_vertical(event.is_action("ui_down"))
	elif event is InputEventKey:
		# Handle WASD navigation in attack menu
		_handle_attack_wasd_input(event)

func _hide_attack_menu():
	attack_menu.visible = false
	command_box.visible = true
	attack_menu_active = false
	
	# Hide category selector
	category_selector.visible = false
	v_separator.visible = false
	
	# Reset navigation state
	is_in_tab_navigation = false

func _navigate_attacks_horizontal(go_right: bool):
	if go_right:
		current_attack_index = (current_attack_index + 1) % 2 + (current_attack_index / 2) * 2
	else:
		current_attack_index = (current_attack_index - 1) % 2 + (current_attack_index / 2) * 2
		if current_attack_index < 0:
			current_attack_index = 1 + (current_attack_index / 2) * 2
	_update_attack_selection()
	if current_menu_mode == MenuMode.INVENTORY:
		_update_inventory_selection()

func _navigate_attacks_vertical(go_down: bool):
	if go_down:
		current_attack_index = (current_attack_index + 2) % 4
	else:
		current_attack_index = (current_attack_index - 2) % 4
		if current_attack_index < 0:
			current_attack_index += 4
	_update_attack_selection()
	if current_menu_mode == MenuMode.INVENTORY:
		_update_inventory_selection()

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

func _select_inventory_item(item_index: int):
	if item_index < current_inventory_items.size():
		var selected_item = current_inventory_items[item_index]
		
		# Check if item is usable
		if not selected_item.usable:
			_show_battle_text(selected_item.name + " kann jetzt nicht verwendet werden!")
			return
		
		# Use the item
		_use_inventory_item(selected_item)

func _switch_inventory_category(go_right: bool):
	var categories = ["medizin", "fanggeraete", "kampf_boosts"]
	var current_index = categories.find(current_inventory_category)
	
	if go_right:
		current_index = (current_index + 1) % categories.size()
	else:
		current_index = (current_index - 1) % categories.size()
		if current_index < 0:
			current_index = categories.size() - 1
	
	current_inventory_category = categories[current_index]
	current_attack_index = 0  # Reset selection
	
	# Update display
	_update_inventory_menu_display()
	_update_attack_selection()

func _select_current_category():
	# Switch to the selected category
	var categories = ["medizin", "fanggeraete", "kampf_boosts"]
	if current_tab_index < categories.size():
		current_inventory_category = categories[current_tab_index]
		_update_inventory_menu_display()
		_update_tab_selection()

func _navigate_categories_vertical(go_down: bool):
	if go_down:
		current_tab_index = (current_tab_index + 1) % 3
	else:
		current_tab_index = (current_tab_index - 1) % 3
		if current_tab_index < 0:
			current_tab_index = 2
	
	_update_tab_selection()

func _use_inventory_item(item: Dictionary):
	var item_id = item.id
	var item_data = item.data
	
	# Hide menu
	_hide_attack_menu()
	
	# Use item based on category
	var category = item_data.get("category", "")
	match category:
		"fanggeraete":
			_attempt_catch_with_item(item_id)
		"medizin":
			_use_healing_item_in_battle(item_id, player_fighter_name)
		"kampf_boosts":
			_use_boost_item_in_battle(item_id, player_fighter_name)
		_:
			_show_battle_text("Dieses Item kann nicht verwendet werden!")

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
	
	# Step 1: Announce the attack with animation
	_play_attack_announcement(attack.name, is_player)
	battle_text.text = attacker_name + " setzt " + attack.name + " ein!"
	await get_tree().create_timer(1.0).timeout
	
	# Play attack animation based on type
	await _play_attack_animation(attack, is_player)
	
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
		# Visual hit effect with new effects system
		_play_enhanced_hit_animation(defender_hp_bar, is_critical, attack)
		
		# Apply damage
		var current_hp = defender_hp_bar.value
		var new_hp = max(0, current_hp - damage)
		
		# Animate HP bar change
		_animate_hp_change(defender_hp_bar, current_hp, new_hp)
		
		# Show damage number
		var defender_position = defender_hp_bar.global_position + Vector2(0, -20)
		if floating_text_manager:
			FloatingTextManager.damage(damage, defender_position, is_critical)
		elif particle_manager:
			particle_manager.show_damage_number(damage, defender_position, is_critical)
		
		# Update HP colors
		_update_hp_bar_colors()
		
		# Show damage feedback
		if is_critical:
			battle_text.text = "Ein kritischer Treffer!"
			if camera_effects:
				camera_effects.critical_hit_effect()
			# Play critical hit sound
			AudioManager.play_hit_sound(true)
			await get_tree().create_timer(1.2).timeout
		else:
			# Play normal hit sound
			AudioManager.play_hit_sound(false)
		
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
		await get_tree().create_timer(1.0).timeout
		
		# Play victory/defeat animations
		if not is_player: # Player wins
			await _play_victory_sequence()
		else: # Player loses
			await _play_defeat_sequence()
		
		_end_battle()
		return
	
	# Step 6: Apply status effects
	if attack.status_effect != "" and randf() < attack.status_chance:
		_add_status_effect(not is_player, attack.status_effect)
		battle_text.text = defender_name + " ist jetzt " + _get_status_german_description(attack.status_effect) + "!"
		
		# Show status effect floating text
		if floating_text_manager:
			var status_position = defender_hp_bar.global_position + Vector2(0, -40)
			FloatingTextManager.status(_get_status_german_name(attack.status_effect), status_position)
		
		await get_tree().create_timer(1.5).timeout
	
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
	
	# Apply status effect modifiers
	var attack_modifier = 1.0
	var defense_modifier = 1.0
	
	if is_player:
		# Player status effects
		if player_status_effects.has("angriff_hoch"):
			attack_modifier *= 1.5
		if player_status_effects.has("verteidigung_hoch"):
			defense_modifier *= 1.5
		if player_status_effects.has("verwirrt") and randf() < 0.3:
			# Confused players sometimes attack themselves
			attack_modifier *= 0.5
		if player_status_effects.has("betrunken"):
			# Drunk players are unpredictable
			attack_modifier *= randf_range(0.5, 1.5)
	else:
		# Enemy status effects (simplified)
		if enemy_status_effects.has("angriff_hoch"):
			attack_modifier *= 1.5
		if enemy_status_effects.has("verteidigung_hoch"):
			defense_modifier *= 1.5
	
	attack_stat *= attack_modifier
	defense_stat *= defense_modifier
	
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
# INVENTORY SYSTEM INTEGRATION
# ============================================================================

# Compact inventory is now integrated into the attack menu system

func _open_battle_inventory():
	# This is for outside-of-battle use (full screen inventory)
	if not battle_inventory_ui:
		return
	
	# Create battle context
	var battle_context = {
		"team_members": _get_team_members_data(),
		"is_trainer_battle": false,
		"current_enemy": enemy_fighter_name,
		"enemy_type": _get_enemy_type()
	}
	
	# Open battle inventory
	battle_inventory_ui.open_battle_inventory(battle_context)
	
	# Hide command box
	command_box.visible = false

func _get_team_members_data() -> Array:
	# Create mock team data - in a full implementation this would come from the party system
	var team_data = []
	
	# Add player's main fighter
	team_data.append({
		"name": player_fighter_name,
		"current_hp": int(player_hp_bar.value),
		"max_hp": int(player_hp_bar.max_value),
		"is_fainted": player_hp_bar.value <= 0,
		"status_effects": player_status_effects.keys()
	})
	
	# Add other team members (mock data)
	team_data.append({
		"name": "BACKUP-1",
		"current_hp": 80,
		"max_hp": 100,
		"is_fainted": false,
		"status_effects": []
	})
	
	team_data.append({
		"name": "BACKUP-2",
		"current_hp": 0,
		"max_hp": 120,
		"is_fainted": true,
		"status_effects": []
	})
	
	return team_data

# Compact inventory functions removed - now integrated into attack menu system

func _on_battle_inventory_closed():
	# Return to command selection (full screen inventory)
	command_box.visible = true
	_update_button_selection()

func _on_battle_item_selected(item_id: String, target_name: String):
	# Use the selected item in battle (full screen version)
	if not inventory_manager or not inventory_manager.has_item(item_id):
		_show_battle_text("Du hast dieses Item nicht!")
		return
	
	var item_data = inventory_manager._get_item_data(item_id)
	var category = item_data.get("category", "")
	
	match category:
		"fanggeraete":
			_attempt_catch_with_item(item_id)
		"medizin":
			_use_healing_item_in_battle(item_id, target_name)
		"kampf_boosts":
			_use_boost_item_in_battle(item_id, target_name)
		_:
			_show_battle_text("Dieses Item kann im Kampf nicht verwendet werden!")

func _use_healing_item_in_battle(item_id: String, target_name: String):
	if not inventory_manager.remove_item(item_id, 1):
		_show_battle_text("Du hast dieses Item nicht!")
		return
	
	var item_data = inventory_manager._get_item_data(item_id)
	var item_name = item_data.get("name", item_id)
	var heal_amount = item_data.get("heal_amount", 0)
	var cures_status = item_data.get("cures_status", [])
	var revive = item_data.get("revive", false)
	
	# Show usage message
	battle_text.text = "Du hast " + item_name + " bei " + target_name + " angewendet!"
	await get_tree().create_timer(1.0).timeout
	
	# Apply healing to player (for now, only heal player)
	if heal_amount > 0:
		var old_hp = player_hp_bar.value
		var new_hp = min(player_hp_bar.max_value, old_hp + heal_amount)
		
		# Animate healing
		_animate_hp_change(player_hp_bar, old_hp, new_hp)
		
		# Show healing effects
		var heal_position = player_hp_bar.global_position + Vector2(0, -20)
		if floating_text_manager:
			FloatingTextManager.heal(heal_amount, heal_position)
		elif particle_manager:
			particle_manager.show_healing_effect(heal_position, heal_amount)
		
		# Play healing sound
		AudioManager.play_heal_sound()
		
		# Update HP colors
		_update_hp_bar_colors()
		
		# Show healing message
		battle_text.text = target_name + " wurde um " + str(heal_amount) + " HP geheilt!"
		await get_tree().create_timer(1.5).timeout
	
	# Handle revive
	if revive and player_hp_bar.value <= 0:
		player_hp_bar.value = player_hp_bar.max_value / 2
		_update_hp_bar_colors()
		battle_text.text = target_name + " wurde wiederbelebt!"
		await get_tree().create_timer(1.5).timeout
	
	# Clear status effects
	if cures_status.size() > 0:
		# For now, just show the message (status effects would be cleared here)
		battle_text.text = target_name + " wurde von Statuseffekten geheilt!"
		await get_tree().create_timer(1.5).timeout
	
	# End turn after item usage
	_end_player_turn()

func _use_boost_item_in_battle(item_id: String, target_name: String):
	if not inventory_manager.remove_item(item_id, 1):
		_show_battle_text("Du hast dieses Item nicht!")
		return
	
	var item_data = inventory_manager._get_item_data(item_id)
	var item_name = item_data.get("name", item_id)
	var boost_stat = item_data.get("boost_stat", "")
	var boost_amount = item_data.get("boost_amount", 1)
	
	# Show usage message
	battle_text.text = "Du hast " + item_name + " bei " + target_name + " angewendet!"
	battle_text_box.visible = true
	command_box.visible = false
	
	await get_tree().create_timer(1.5).timeout
	
	# Apply boost effect and add to status effects
	var boost_effect = ""
	if boost_stat == "attack":
		boost_effect = "angriff_hoch"
		battle_text.text = target_name + " fühlt sich stärker! Angriff wurde erhöht!"
	elif boost_stat == "defense":
		boost_effect = "verteidigung_hoch"
		battle_text.text = target_name + " fühlt sich robuster! Verteidigung wurde erhöht!"
	elif boost_stat == "speed":
		boost_effect = "geschwindigkeit_hoch"
		battle_text.text = target_name + " fühlt sich schneller! Geschwindigkeit wurde erhöht!"
	elif boost_stat == "special_attack":
		boost_effect = "spezial_angriff_hoch"
		battle_text.text = target_name + " fühlt sich konzentrierter! Spezial-Angriff wurde erhöht!"
	else:
		boost_effect = "angriff_hoch"
		battle_text.text = target_name + " fühlt sich gestärkt! Angriff wurde erhöht!"
	
	# Add boost to status effects (for player)
	if target_name == player_fighter_name:
		if not player_status_effects.has(boost_effect):
			player_status_effects[boost_effect] = 5 # Duration in turns
			_update_status_display()
		
		# Show boost particle effect
		var boost_position = player_hp_bar.global_position + Vector2(0, -20)
		if floating_text_manager:
			FloatingTextManager.buff(_get_status_german_name(boost_effect), boost_position)
		elif particle_manager:
			particle_manager.show_status_effect(boost_position, boost_effect)
	
	await get_tree().create_timer(2.0).timeout
	
	# End player turn
	_end_player_turn()

func _end_player_turn():
	# Switch to enemy turn
	current_phase = BattlePhase.ENEMY_TURN
	_enemy_turn()

# ============================================================================
# FLUCHT-SYSTEM
# ============================================================================

func _attempt_escape():
	# Prüfe ob Flucht erlaubt ist
	if not is_wild_battle:
		_show_battle_text("Du kannst nicht vor einem Trainer-Kampf fliehen!")
		run_button.disabled = true
		return
	
	# Verstecke UI und zeige Flucht-Versuch
	command_box.visible = false
	battle_text_box.visible = true
	battle_text.text = "Du versuchst zu fliehen..."
	
	await get_tree().create_timer(1.0).timeout
	
	# Berechne Flucht-Chance
	var escape_chance = _calculate_escape_chance()
	
	# DEBUG: Zeige Flucht-Chance (kann später entfernt werden)
	var player_speed = _get_player_speed()
	var enemy_speed = _get_enemy_speed()
	var chance_percent = int(escape_chance * 100)
	
	print("Flucht-Versuch #", escape_attempts + 1, ":")
	print("  Spieler-Geschwindigkeit: ", player_speed)
	print("  Gegner-Geschwindigkeit: ", enemy_speed)
	print("  Flucht-Chance: ", chance_percent, "%")
	
	# Würfel für Erfolg
	var success = randf() < escape_chance
	
	if success:
		_escape_successful()
	else:
		_escape_failed()

func _calculate_escape_chance() -> float:
	# Vereinfachte Pokémon-Formel für Flucht-Wahrscheinlichkeit
	# F = ((Geschwindigkeit_Spieler * 32) / (Geschwindigkeit_Gegner mod 256)) + 30 * Anzahl_Fluchtversuche
	
	# Geschwindigkeits-Werte
	var player_speed = _get_player_speed()
	var enemy_speed = _get_enemy_speed()
	
	# Basis-Formel
	var f = ((player_speed * 32) / (enemy_speed % 256)) + 30 * escape_attempts
	
	# Konvertiere zu Wahrscheinlichkeit (0.0 bis 1.0)
	var escape_chance = f / 256.0
	
	# Garantierte Flucht bei sehr hohen Werten
	if f >= 256:
		escape_chance = 1.0
	
	# Mindest-Chance von 5%, Maximum 95%
	escape_chance = clamp(escape_chance, 0.05, 0.95)
	
	return escape_chance

func _get_player_speed() -> int:
	# Spieler-Geschwindigkeit: Base Speed + Level-Modifier
	var base_speed = 65  # FRIEDER's Base Speed
	var player_level = 9
	return base_speed + (player_level - 5) * 2

func _get_enemy_speed() -> int:
	# Gegner-Geschwindigkeit aus Datenbank
	if current_enemy_id in enemy_database:
		var enemy_data = enemy_database[current_enemy_id]
		var base_speed = enemy_data.get("base_speed", 60)  # Fallback: 60
		var enemy_level = enemy_data.get("fighter_level", 10)
		return base_speed + (enemy_level - 5) * 2
	else:
		# Fallback für unbekannte Gegner
		return 60 + (_get_enemy_level() - 5) * 2

func _escape_successful():
	# Erfolgreiche Flucht
	battle_text.text = "Du bist erfolgreich geflohen!"
	
	# Spiele Flucht-Animation
	_play_escape_animation()
	
	await get_tree().create_timer(2.0).timeout
	
	# Beende Kampf ohne Belohnungen
	_end_battle_escaped()

func _escape_failed():
	# Gescheiterte Flucht
	escape_attempts += 1
	
	# Zeige Fehlschlag-Nachricht
	var failure_messages = [
		"Du konntest nicht fliehen!",
		"Der wilde " + enemy_fighter_name + " versperrt dir den Weg!",
		"Kein Entkommen möglich!",
		enemy_fighter_name + " lässt dich nicht entkommen!"
	]
	
	battle_text.text = failure_messages[randi() % failure_messages.size()]
	
	await get_tree().create_timer(2.0).timeout
	
	# Runde ist verbraucht, Gegner ist dran
	_end_attack_sequence(true)

func _play_escape_animation():
	# Flucht-Animation: Spieler rennt weg
	# Erstelle einen visuellen Effekt mit der UI
	
	# Zuerst: Bildschirm wackelt leicht (Bewegung)
	var screen_shake_tween = create_tween()
	var ui_node = get_node("UI")
	var original_position = ui_node.position
	
	# Kleines Wackeln
	for i in range(6):
		var shake_offset = Vector2(randf_range(-2, 2), randf_range(-2, 2))
		screen_shake_tween.tween_property(ui_node, "position", original_position + shake_offset, 0.1)
		await screen_shake_tween.finished
	
	# Zurück zur ursprünglichen Position
	screen_shake_tween.tween_property(ui_node, "position", original_position, 0.1)
	await screen_shake_tween.finished
	
	# Dann: UI verschwindet mit Fade-Out
	var fade_tween = create_tween()
	fade_tween.tween_property(ui_node, "modulate", Color.TRANSPARENT, 0.8)
	
	# Gleichzeitig: Hintergrund wird dunkler (Flucht-Effekt)
	var background_tween = create_tween()
	var background_node = get_node("Background")
	background_tween.tween_property(background_node, "modulate", Color(0.3, 0.3, 0.3, 1.0), 0.8)

func _end_battle_escaped():
	# Kampf beendet durch Flucht
	if game_state_manager:
		game_state_manager.change_state(game_state_manager.GameState.EXPLORING)
		# Zurück zur Hauptszene
		get_tree().change_scene_to_file("res://scenes/main.tscn")

func set_battle_type(is_wild: bool):
	# Öffentliche Funktion zum Setzen des Kampf-Typs
	is_wild_battle = is_wild
	escape_attempts = 0
	
	# Aktiviere/Deaktiviere Flucht-Button basierend auf Kampf-Typ
	if run_button:
		run_button.disabled = not is_wild_battle
		
		if not is_wild_battle:
			# Grau aus für Trainer-Kämpfe
			run_button.modulate = Color(0.5, 0.5, 0.5, 1.0)
		else:
			# Normal für wilde Kämpfe
			run_button.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_bag_button_pressed():
	# Legacy function - redirect to new battle inventory
	_open_battle_inventory()

func _on_inventory_closed():
	# Legacy function - redirect to new battle inventory closed
	_on_battle_inventory_closed()

func _on_catching_item_selected(item_id: String):
	# Legacy function - redirect to new battle item system
	_on_battle_item_selected(item_id, "enemy")

func _attempt_catch_with_item(item_id: String):
	# Remove item from inventory
	if not inventory_manager.remove_item(item_id, 1):
		battle_text.text = "Du hast dieses Item nicht!"
		await get_tree().create_timer(2.0).timeout
		command_box.visible = true
		return
	
	# Show usage message
	var item_name = inventory_manager.get_item_display_name(item_id)
	battle_text.text = "Du hast " + item_name + " eingesetzt!"
	await get_tree().create_timer(2.0).timeout
	
	# Calculate catch chance
	var base_catch_rate = inventory_manager.get_catch_rate(item_id)
	var catch_chance = _calculate_catch_chance(base_catch_rate, item_id)
	
	# Animate catch attempt
	battle_text.text = "Das " + item_name + " wackelt..."
	await get_tree().create_timer(1.0).timeout
	
	# Determine success
	var success = randf() < catch_chance
	
	if success:
		battle_text.text = "Erfolgreich gefangen! " + enemy_fighter_name + " schließt sich dir an!"
		await get_tree().create_timer(3.0).timeout
		_end_battle()
	else:
		battle_text.text = "Oh nein! " + enemy_fighter_name + " ist entkommen!"
		await get_tree().create_timer(2.0).timeout
		# Continue battle
		command_box.visible = true

func _calculate_catch_chance(base_rate: float, item_id: String) -> float:
	var catch_chance = base_rate * 0.1  # Base formula
	
	# Enemy HP factor (lower HP = easier catch)
	# TODO: Replace with actual HP values from battle system
	var enemy_hp_percent = 0.8  # Placeholder - assume 80% HP
	catch_chance *= (2.0 - enemy_hp_percent)
	
	# First turn bonus
	if inventory_manager.has_first_turn_bonus(item_id):
		# TODO: Track if it's first turn
		catch_chance *= 1.5
	
	# Type bonus
	var type_bonus = inventory_manager.get_type_bonus(item_id)
	if type_bonus.size() > 0:
		var enemy_type = AttackType.keys()[_get_enemy_type()]
		if enemy_type in type_bonus:
			catch_chance *= 1.5
	
	# Status effect bonus
	if enemy_status_effects.size() > 0:
		catch_chance *= 1.3
	
	return clamp(catch_chance, 0.05, 0.95)

func _try_item_drop(attack_used: String):
	# Try to drop an item after enemy is hit
	if inventory_manager:
		var enemy_type = AttackType.keys()[_get_enemy_type()]
		var success = inventory_manager.try_drop_item(enemy_type, attack_used)
		
		if success:
			# Show drop message
			var dropped_item = inventory_manager.roll_item_drop(enemy_type, attack_used)
			if dropped_item != "":
				var item_name = inventory_manager.get_item_display_name(dropped_item)
				battle_text.text += "\n" + enemy_fighter_name + " hat " + item_name + " fallen gelassen!"

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