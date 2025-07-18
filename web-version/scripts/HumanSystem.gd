extends Node

# Human Collection and Management System for Menschenmon
# Handles catching, storing, and battling with humans

signal human_caught(human: HumanInstance)
signal human_released(human_id: String)
signal party_changed
signal active_human_changed(human: HumanInstance)

# Constants
const MAX_PARTY_SIZE = 6
const CATCH_ANIMATION_DURATION = 2.0
const CATCH_SUCCESS_CHANCE = 0.8

# Core components
var data_manager: Node = null
var save_manager: Node = null
var audio_manager: Node = null

# Human collection data
var collected_humans: Dictionary = {}  # human_id -> HumanInstance
var party: Array = []  # Array of human IDs in party
var active_human_id: String = ""  # Currently active human
var storage_system: HumanStorage

# Catch mechanics
var catch_in_progress: bool = false
var catch_target: Dictionary = {}

class HumanInstance:
	var id: String
	var species: String
	var level: int
	var experience: int
	var nickname: String
	var original_trainer: String
	var caught_date: String
	var caught_location: String
	var nature: String
	var personality: HumanPersonality
	var stats: HumanStats
	var moveset: Array = []  # Array of Attack instances
	var status_effects: Dictionary = {}
	var friendship: int = 0
	var is_shiny: bool = false
	var is_caught: bool = false
	var metadata: Dictionary = {}
	
	func _init(species_name: String, catch_level: int = 1):
		species = species_name
		level = catch_level
		experience = _calculate_experience_for_level(catch_level)
		nickname = species  # Default nickname is species name
		original_trainer = "Wild"
		caught_date = Time.get_datetime_string_from_system()
		caught_location = "Unknown"
		nature = _generate_random_nature()
		personality = HumanPersonality.new()
		stats = HumanStats.new()
		moveset = []
		friendship = 0
		is_shiny = randf() < 0.001  # 1/1000 chance for shiny
		is_caught = false
		metadata = {}
		
		# Generate unique ID
		id = species + "_" + str(Time.get_unix_time_from_system()) + "_" + str(randi() % 1000)
		
		# Initialize stats based on species and level
		_initialize_stats()
		
		# Initialize moveset
		_initialize_moveset()
	
	func _calculate_experience_for_level(target_level: int) -> int:
		# Experience formula: level^3 for simplicity
		return target_level * target_level * target_level
	
	func _generate_random_nature() -> String:
		var natures = [
			"Aggressiv", "Entspannt", "Chaotisch", "Ruhig", "Energisch",
			"Träge", "Gesellig", "Schüchtern", "Impulsiv", "Besonnen",
			"Fröhlich", "Pessimistisch", "Optimistisch", "Sarkastisch", "Freundlich"
		]
		return natures[randi() % natures.size()]
	
	func _initialize_stats():
		# Base stats that will be modified by species data
		stats.hp = 20 + randi_range(0, 10) + (level * 2)
		stats.attack = 15 + randi_range(0, 10) + level
		stats.defense = 15 + randi_range(0, 10) + level
		stats.speed = 15 + randi_range(0, 10) + level
		stats.current_hp = stats.hp
	
	func _initialize_moveset():
		# This will be expanded with species-specific moves
		moveset = []
	
	func gain_experience(amount: int):
		experience += amount
		var new_level = _calculate_level_from_experience(experience)
		
		if new_level > level:
			level_up(new_level)
	
	func level_up(new_level: int):
		var old_level = level
		level = new_level
		
		# Increase stats on level up
		stats.hp += randi_range(2, 5)
		stats.attack += randi_range(1, 3)
		stats.defense += randi_range(1, 3)
		stats.speed += randi_range(1, 3)
		
		# Heal to full HP on level up
		stats.current_hp = stats.hp
		
		print("Human ", nickname, " leveled up from ", old_level, " to ", level, "!")
	
	func _calculate_level_from_experience(exp: int) -> int:
		# Inverse of experience formula
		return int(round(pow(exp, 1.0/3.0)))
	
	func heal_to_full():
		stats.current_hp = stats.hp
		status_effects.clear()
	
	func is_fainted() -> bool:
		return stats.current_hp <= 0
	
	func can_battle() -> bool:
		return not is_fainted() and moveset.size() > 0

class HumanPersonality:
	var boldness: float = 0.5  # 0 = shy, 1 = bold
	var sociability: float = 0.5  # 0 = antisocial, 1 = social
	var energy: float = 0.5  # 0 = lazy, 1 = energetic
	var chaos: float = 0.5  # 0 = orderly, 1 = chaotic
	var humor: float = 0.5  # 0 = serious, 1 = funny
	
	func _init():
		# Generate random personality traits
		boldness = randf()
		sociability = randf()
		energy = randf()
		chaos = randf()
		humor = randf()
	
	func get_personality_description() -> String:
		var traits = []
		
		if boldness > 0.7:
			traits.append("mutig")
		elif boldness < 0.3:
			traits.append("schüchtern")
		
		if sociability > 0.7:
			traits.append("gesellig")
		elif sociability < 0.3:
			traits.append("einzelgängerisch")
		
		if energy > 0.7:
			traits.append("energisch")
		elif energy < 0.3:
			traits.append("träge")
		
		if chaos > 0.7:
			traits.append("chaotisch")
		elif chaos < 0.3:
			traits.append("ordentlich")
		
		if humor > 0.7:
			traits.append("witzig")
		elif humor < 0.3:
			traits.append("ernst")
		
		if traits.size() == 0:
			return "ausgeglichen"
		else:
			return " und ".join(traits)

class HumanStats:
	var hp: int = 20
	var attack: int = 15
	var defense: int = 15
	var speed: int = 15
	var current_hp: int = 20
	
	func _init():
		current_hp = hp
	
	func take_damage(damage: int):
		current_hp = max(0, current_hp - damage)
	
	func heal(amount: int):
		current_hp = min(hp, current_hp + amount)
	
	func get_stat_total() -> int:
		return hp + attack + defense + speed

class HumanStorage:
	var boxes: Array = []  # Array of Array
	var box_names: Array = []  # Array of String
	var current_box: int = 0
	
	func _init():
		# Create 12 storage boxes with 30 slots each
		for i in range(12):
			boxes.append([])
			box_names.append("Box " + str(i + 1))
			
			# Initialize empty slots
			for j in range(30):
				boxes[i].append(null)
	
	func store_human(human: HumanInstance) -> bool:
		for box_index in range(boxes.size()):
			for slot_index in range(boxes[box_index].size()):
				if boxes[box_index][slot_index] == null:
					boxes[box_index][slot_index] = human
					print("Stored ", human.nickname, " in Box ", box_index + 1, " slot ", slot_index + 1)
					return true
		
		print("No storage space available!")
		return false
	
	func retrieve_human(box_index: int, slot_index: int) -> HumanInstance:
		if box_index < 0 or box_index >= boxes.size():
			return null
		if slot_index < 0 or slot_index >= boxes[box_index].size():
			return null
		
		var human = boxes[box_index][slot_index]
		boxes[box_index][slot_index] = null
		return human
	
	func get_box_contents(box_index: int) -> Array:
		if box_index < 0 or box_index >= boxes.size():
			return []
		return boxes[box_index]
	
	func rename_box(box_index: int, new_name: String):
		if box_index >= 0 and box_index < box_names.size():
			box_names[box_index] = new_name

func _ready():
	# Initialize human system
	print("HumanSystem: Initializing...")
	
	# Get core managers
	data_manager = get_node_or_null("/root/DataManager")
	save_manager = get_node_or_null("/root/SaveManager")
	audio_manager = get_node_or_null("/root/AudioManager")
	
	# Initialize storage system
	storage_system = HumanStorage.new()
	
	# Connect to save manager if available
	if save_manager:
		save_manager.save_completed.connect(_on_save_completed)
		save_manager.load_completed.connect(_on_load_completed)
	
	print("HumanSystem: Ready")

func _on_save_completed(success: bool):
	if success:
		print("HumanSystem: Human data saved successfully")

func _on_load_completed(success: bool):
	if success:
		print("HumanSystem: Human data loaded successfully")
		# Load human data from save manager
		_load_human_data_from_save()

func _load_human_data_from_save():
	# This will be implemented when save system is fully integrated
	pass

# Public API - Human Management
func add_human_to_collection(human: HumanInstance):
	collected_humans[human.id] = human
	human_caught.emit(human)
	
	# Add to party if there's space
	if party.size() < MAX_PARTY_SIZE:
		add_to_party(human.id)
	else:
		# Store in storage system
		storage_system.store_human(human)
	
	print("Added ", human.nickname, " to collection!")

func remove_human_from_collection(human_id: String):
	if human_id in collected_humans:
		var human = collected_humans[human_id]
		collected_humans.erase(human_id)
		remove_from_party(human_id)
		human_released.emit(human_id)
		print("Released ", human.nickname, " from collection")

func get_human(human_id: String) -> HumanInstance:
	return collected_humans.get(human_id, null)

func get_collection_size() -> int:
	return collected_humans.size()

func get_collection_list() -> Array:
	return collected_humans.keys()

# Public API - Party Management
func add_to_party(human_id: String) -> bool:
	if human_id in collected_humans and party.size() < MAX_PARTY_SIZE:
		if human_id not in party:
			party.append(human_id)
			party_changed.emit()
			
			# Set as active human if no active human
			if active_human_id == "":
				set_active_human(human_id)
			
			print("Added ", collected_humans[human_id].nickname, " to party")
			return true
	return false

func remove_from_party(human_id: String) -> bool:
	if human_id in party:
		party.erase(human_id)
		
		# Clear active human if it was the removed one
		if active_human_id == human_id:
			active_human_id = ""
			if party.size() > 0:
				set_active_human(party[0])
		
		party_changed.emit()
		print("Removed human from party")
		return true
	return false

func get_party() -> Array:
	var party_humans: Array = []
	for human_id in party:
		if human_id in collected_humans:
			party_humans.append(collected_humans[human_id])
	return party_humans

func get_party_size() -> int:
	return party.size()

func swap_party_members(index1: int, index2: int):
	if index1 >= 0 and index1 < party.size() and index2 >= 0 and index2 < party.size():
		var temp = party[index1]
		party[index1] = party[index2]
		party[index2] = temp
		party_changed.emit()

func set_active_human(human_id: String):
	if human_id in collected_humans:
		active_human_id = human_id
		active_human_changed.emit(collected_humans[human_id])
		print("Set active human to ", collected_humans[human_id].nickname)

func get_active_human() -> HumanInstance:
	if active_human_id != "" and active_human_id in collected_humans:
		return collected_humans[active_human_id]
	return null

func get_first_battle_ready_human() -> HumanInstance:
	for human_id in party:
		var human = collected_humans[human_id]
		if human.can_battle():
			return human
	return null

# Public API - Catching System
func attempt_catch(enemy_data: Dictionary) -> bool:
	if catch_in_progress:
		return false
	
	catch_in_progress = true
	catch_target = enemy_data
	
	print("Attempting to catch ", enemy_data.get("species", "unknown"), "...")
	
	# Calculate catch chance based on various factors
	var catch_chance = _calculate_catch_chance(enemy_data)
	
	# Perform catch animation
	await _play_catch_animation()
	
	# Determine success
	var success = randf() < catch_chance
	
	if success:
		_catch_success(enemy_data)
	else:
		_catch_failure(enemy_data)
	
	catch_in_progress = false
	return success

func _calculate_catch_chance(enemy_data: Dictionary) -> float:
	var base_chance = CATCH_SUCCESS_CHANCE
	
	# Factors that affect catch chance:
	# - Enemy HP (lower HP = easier catch)
	var enemy_hp_percent = enemy_data.get("current_hp", 100) / float(enemy_data.get("max_hp", 100))
	base_chance += (1.0 - enemy_hp_percent) * 0.3
	
	# - Enemy level (higher level = harder catch)
	var enemy_level = enemy_data.get("level", 1)
	base_chance -= (enemy_level - 1) * 0.01
	
	# - Status effects (sleep, paralysis make catching easier)
	var status_effects = enemy_data.get("status_effects", {})
	if "sleep" in status_effects or "paralysis" in status_effects:
		base_chance += 0.2
	
	# - Player's active human level
	var active_human = get_active_human()
	if active_human:
		base_chance += (active_human.level - enemy_level) * 0.02
	
	# Clamp between 0.05 and 0.95
	return clamp(base_chance, 0.05, 0.95)

func _play_catch_animation():
	# Play catch animation and sound effects
	print("Playing catch animation...")
	
	if audio_manager:
		# Play catch sound effect
		pass
	
	# Wait for animation duration
	await get_tree().create_timer(CATCH_ANIMATION_DURATION).timeout

func _catch_success(enemy_data: Dictionary):
	print("Catch successful!")
	
	# Create new human instance
	var species = enemy_data.get("species", "unknown")
	var level = enemy_data.get("level", 1)
	var new_human = HumanInstance.new(species, level)
	
	# Set caught location and other metadata
	new_human.caught_location = enemy_data.get("location", "Unknown")
	new_human.is_caught = true
	
	# Copy current stats from enemy
	if enemy_data.has("stats"):
		var enemy_stats = enemy_data["stats"]
		new_human.stats.hp = enemy_stats.get("hp", 20)
		new_human.stats.attack = enemy_stats.get("attack", 15)
		new_human.stats.defense = enemy_stats.get("defense", 15)
		new_human.stats.speed = enemy_stats.get("speed", 15)
		new_human.stats.current_hp = enemy_stats.get("current_hp", new_human.stats.hp)
	
	# Add to collection
	add_human_to_collection(new_human)
	
	if audio_manager:
		# Play success sound
		pass

func _catch_failure(enemy_data: Dictionary):
	print("Catch failed!")
	
	if audio_manager:
		# Play failure sound
		pass

# Public API - Battle Integration
func get_human_for_battle(human_id: String) -> Dictionary:
	var human = get_human(human_id)
	if human == null:
		return {}
	
	# Convert human to battle-compatible format
	return {
		"id": human.id,
		"species": human.species,
		"nickname": human.nickname,
		"level": human.level,
		"stats": {
			"hp": human.stats.hp,
			"attack": human.stats.attack,
			"defense": human.stats.defense,
			"speed": human.stats.speed,
			"current_hp": human.stats.current_hp
		},
		"moveset": human.moveset,
		"status_effects": human.status_effects,
		"nature": human.nature,
		"personality": human.personality
	}

func update_human_after_battle(human_id: String, battle_data: Dictionary):
	var human = get_human(human_id)
	if human == null:
		return
	
	# Update stats after battle
	if battle_data.has("stats"):
		var stats = battle_data["stats"]
		human.stats.current_hp = stats.get("current_hp", human.stats.current_hp)
	
	# Update status effects
	if battle_data.has("status_effects"):
		human.status_effects = battle_data["status_effects"]
	
	# Give experience if won
	if battle_data.get("won", false):
		var exp_gained = battle_data.get("experience", 0)
		human.gain_experience(exp_gained)
	
	# Update friendship
	if battle_data.get("won", false):
		human.friendship = min(255, human.friendship + 2)
	else:
		human.friendship = max(0, human.friendship - 1)

# Public API - Storage System
func get_storage_system() -> HumanStorage:
	return storage_system

func move_to_storage(human_id: String) -> bool:
	if human_id in collected_humans:
		var human = collected_humans[human_id]
		remove_from_party(human_id)
		return storage_system.store_human(human)
	return false

func move_from_storage(box_index: int, slot_index: int) -> bool:
	var human = storage_system.retrieve_human(box_index, slot_index)
	if human != null:
		return add_to_party(human.id)
	return false

# Debug and testing functions
func create_test_human(species: String, level: int = 5) -> HumanInstance:
	var human = HumanInstance.new(species, level)
	human.nickname = "Test " + species
	human.caught_location = "Debug Area"
	return human

func add_test_humans():
	# Add some test humans for development
	var benedikt = create_test_human("Benedikt", 5)
	var felix = create_test_human("Felix", 7)
	var anna = create_test_human("Anna", 6)
	
	add_human_to_collection(benedikt)
	add_human_to_collection(felix)
	add_human_to_collection(anna)
	
	print("Added test humans to collection")

func get_system_info() -> Dictionary:
	return {
		"total_humans": collected_humans.size(),
		"party_size": party.size(),
		"active_human": active_human_id,
		"storage_boxes": storage_system.boxes.size(),
		"catch_in_progress": catch_in_progress
	}