extends Node

# Comprehensive Save/Load System for Menschenmon
# Handles player progress, human collection, and game state persistence

signal save_completed(success: bool)
signal load_completed(success: bool)
signal auto_save_triggered

# Save file configuration
const SAVE_FILE_PATH = "user://savegame.save"
const BACKUP_FILE_PATH = "user://savegame.backup"
const SAVE_FILE_VERSION = "1.0"

# Auto-save settings
var auto_save_enabled: bool = true
var auto_save_interval: float = 300.0  # 5 minutes
var auto_save_timer: Timer

# Current save data
var save_data: SaveData

class SaveData:
	var version: String = SAVE_FILE_VERSION
	var timestamp: String
	var player_data: PlayerData
	var world_state: WorldState
	var game_statistics: GameStatistics
	
	func _init():
		timestamp = Time.get_datetime_string_from_system()
		player_data = PlayerData.new()
		world_state = WorldState.new()
		game_statistics = GameStatistics.new()

class PlayerData:
	var name: String = "Player"
	var level: int = 1
	var experience: int = 0
	var money: int = 0
	var current_location: String = "small_town"
	var position: Vector2 = Vector2.ZERO
	var facing_direction: int = 0
	
	# Human collection system
	var human_collection: HumanCollection
	var party: Array[String] = []  # IDs of humans in party
	var active_human: String = ""  # Currently active human ID
	
	func _init():
		human_collection = HumanCollection.new()

class HumanCollection:
	var collected_humans: Dictionary = {}  # human_id -> HumanInstance
	var total_caught: int = 0
	var total_seen: int = 0
	var storage_boxes: Array[Array] = []  # Array of storage boxes
	
	func _init():
		# Initialize storage boxes (6 boxes with 30 slots each)
		for i in range(6):
			storage_boxes.append([])

class HumanInstance:
	var id: String
	var species: String
	var level: int
	var experience: int
	var nickname: String
	var caught_date: String
	var caught_location: String
	var nature: String
	var stats: HumanStats
	var moveset: Array[String]  # Attack IDs
	var status_effects: Dictionary = {}
	var friendship: int = 0
	var is_shiny: bool = false
	
	func _init(species_name: String, catch_level: int = 1):
		species = species_name
		level = catch_level
		experience = _get_experience_for_level(catch_level)
		nickname = species  # Default nickname
		caught_date = Time.get_datetime_string_from_system()
		caught_location = "unknown"
		nature = _generate_random_nature()
		stats = HumanStats.new()
		moveset = []
		friendship = 0
		is_shiny = randf() < 0.001  # 1/1000 chance
		
		# Generate unique ID
		id = species + "_" + str(randi() % 10000).pad_zeros(4)
	
	func _get_experience_for_level(target_level: int) -> int:
		# Simple experience formula: level^3
		return target_level * target_level * target_level
	
	func _generate_random_nature() -> String:
		var natures = ["Hardy", "Lonely", "Brave", "Adamant", "Naughty", "Bold", "Docile", "Relaxed", "Impish", "Lax"]
		return natures[randi() % natures.size()]

class HumanStats:
	var hp: int = 0
	var attack: int = 0
	var defense: int = 0
	var speed: int = 0
	var current_hp: int = 0
	
	func _init():
		# Generate random stats (base stats will be added from species data)
		hp = randi_range(10, 30)
		attack = randi_range(10, 30)
		defense = randi_range(10, 30)
		speed = randi_range(10, 30)
		current_hp = hp

class WorldState:
	var npcs_defeated: Array[String] = []
	var items_collected: Array[String] = []
	var locations_visited: Array[String] = []
	var story_flags: Dictionary = {}
	var current_time: float = 0.0
	var play_time: float = 0.0

class GameStatistics:
	var battles_won: int = 0
	var battles_lost: int = 0
	var humans_caught: int = 0
	var humans_seen: int = 0
	var steps_taken: int = 0
	var money_earned: int = 0
	var money_spent: int = 0
	var start_time: String
	var total_play_time: float = 0.0
	
	func _init():
		start_time = Time.get_datetime_string_from_system()

func _ready():
	# Initialize save system
	print("SaveManager: Initializing...")
	save_data = SaveData.new()
	
	# Setup auto-save timer
	_setup_auto_save()
	
	# Connect to game events
	_connect_to_game_events()
	
	print("SaveManager: Ready")

func _setup_auto_save():
	if auto_save_enabled:
		auto_save_timer = Timer.new()
		auto_save_timer.wait_time = auto_save_interval
		auto_save_timer.timeout.connect(_on_auto_save_triggered)
		auto_save_timer.autostart = true
		add_child(auto_save_timer)

func _connect_to_game_events():
	# Connect to various game events for auto-updating save data
	# This will be expanded as more systems are implemented
	pass

func _on_auto_save_triggered():
	if auto_save_enabled:
		print("SaveManager: Auto-save triggered")
		auto_save_triggered.emit()
		save_game()

func save_game() -> bool:
	print("SaveManager: Saving game...")
	
	# Update save data with current game state
	_update_save_data()
	
	# Create backup of existing save
	_create_backup()
	
	# Save to file
	var success = _write_save_file()
	
	save_completed.emit(success)
	
	if success:
		print("SaveManager: Game saved successfully")
	else:
		print("SaveManager: Failed to save game")
	
	return success

func load_game() -> bool:
	print("SaveManager: Loading game...")
	
	var success = _read_save_file()
	
	if success:
		# Apply loaded data to game state
		_apply_save_data()
		print("SaveManager: Game loaded successfully")
	else:
		print("SaveManager: Failed to load game")
	
	load_completed.emit(success)
	return success

func _update_save_data():
	# Update timestamp
	save_data.timestamp = Time.get_datetime_string_from_system()
	
	# Update player data from current game state
	_update_player_data()
	
	# Update world state
	_update_world_state()
	
	# Update statistics
	_update_statistics()

func _update_player_data():
	# This will be expanded as player systems are implemented
	var game_state_manager = get_node_or_null("/root/GameStateManager")
	if game_state_manager:
		# Update current state info
		pass

func _update_world_state():
	# Update world state information
	save_data.world_state.current_time = Time.get_unix_time_from_system()

func _update_statistics():
	# Update play time
	save_data.game_statistics.total_play_time += get_process_delta_time()

func _create_backup():
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var dir = DirAccess.open("user://")
		if dir:
			dir.copy(SAVE_FILE_PATH, BACKUP_FILE_PATH)
			print("SaveManager: Backup created")

func _write_save_file() -> bool:
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file == null:
		print("SaveManager: Failed to open save file for writing")
		return false
	
	# Convert save data to JSON
	var json_string = JSON.stringify(_save_data_to_dict())
	file.store_string(json_string)
	file.close()
	
	return true

func _read_save_file() -> bool:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("SaveManager: No save file found")
		return false
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file == null:
		print("SaveManager: Failed to open save file for reading")
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	# Parse JSON
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		print("SaveManager: Failed to parse save file JSON")
		return false
	
	# Convert back to save data
	_save_data_from_dict(json.data)
	return true

func _save_data_to_dict() -> Dictionary:
	return {
		"version": save_data.version,
		"timestamp": save_data.timestamp,
		"player_data": _player_data_to_dict(),
		"world_state": _world_state_to_dict(),
		"game_statistics": _game_statistics_to_dict()
	}

func _player_data_to_dict() -> Dictionary:
	return {
		"name": save_data.player_data.name,
		"level": save_data.player_data.level,
		"experience": save_data.player_data.experience,
		"money": save_data.player_data.money,
		"current_location": save_data.player_data.current_location,
		"position": {"x": save_data.player_data.position.x, "y": save_data.player_data.position.y},
		"facing_direction": save_data.player_data.facing_direction,
		"human_collection": _human_collection_to_dict(),
		"party": save_data.player_data.party,
		"active_human": save_data.player_data.active_human
	}

func _human_collection_to_dict() -> Dictionary:
	var humans_dict = {}
	for human_id in save_data.player_data.human_collection.collected_humans.keys():
		var human = save_data.player_data.human_collection.collected_humans[human_id]
		humans_dict[human_id] = _human_instance_to_dict(human)
	
	return {
		"collected_humans": humans_dict,
		"total_caught": save_data.player_data.human_collection.total_caught,
		"total_seen": save_data.player_data.human_collection.total_seen,
		"storage_boxes": save_data.player_data.human_collection.storage_boxes
	}

func _human_instance_to_dict(human: HumanInstance) -> Dictionary:
	return {
		"id": human.id,
		"species": human.species,
		"level": human.level,
		"experience": human.experience,
		"nickname": human.nickname,
		"caught_date": human.caught_date,
		"caught_location": human.caught_location,
		"nature": human.nature,
		"stats": {
			"hp": human.stats.hp,
			"attack": human.stats.attack,
			"defense": human.stats.defense,
			"speed": human.stats.speed,
			"current_hp": human.stats.current_hp
		},
		"moveset": human.moveset,
		"status_effects": human.status_effects,
		"friendship": human.friendship,
		"is_shiny": human.is_shiny
	}

func _world_state_to_dict() -> Dictionary:
	return {
		"npcs_defeated": save_data.world_state.npcs_defeated,
		"items_collected": save_data.world_state.items_collected,
		"locations_visited": save_data.world_state.locations_visited,
		"story_flags": save_data.world_state.story_flags,
		"current_time": save_data.world_state.current_time,
		"play_time": save_data.world_state.play_time
	}

func _game_statistics_to_dict() -> Dictionary:
	return {
		"battles_won": save_data.game_statistics.battles_won,
		"battles_lost": save_data.game_statistics.battles_lost,
		"humans_caught": save_data.game_statistics.humans_caught,
		"humans_seen": save_data.game_statistics.humans_seen,
		"steps_taken": save_data.game_statistics.steps_taken,
		"money_earned": save_data.game_statistics.money_earned,
		"money_spent": save_data.game_statistics.money_spent,
		"start_time": save_data.game_statistics.start_time,
		"total_play_time": save_data.game_statistics.total_play_time
	}

func _save_data_from_dict(data: Dictionary):
	save_data = SaveData.new()
	save_data.version = data.get("version", "1.0")
	save_data.timestamp = data.get("timestamp", "")
	
	# Load player data
	if data.has("player_data"):
		_player_data_from_dict(data["player_data"])
	
	# Load world state
	if data.has("world_state"):
		_world_state_from_dict(data["world_state"])
	
	# Load statistics
	if data.has("game_statistics"):
		_game_statistics_from_dict(data["game_statistics"])

func _player_data_from_dict(data: Dictionary):
	save_data.player_data.name = data.get("name", "Player")
	save_data.player_data.level = data.get("level", 1)
	save_data.player_data.experience = data.get("experience", 0)
	save_data.player_data.money = data.get("money", 0)
	save_data.player_data.current_location = data.get("current_location", "small_town")
	
	var pos_data = data.get("position", {"x": 0, "y": 0})
	save_data.player_data.position = Vector2(pos_data.x, pos_data.y)
	save_data.player_data.facing_direction = data.get("facing_direction", 0)
	
	save_data.player_data.party = data.get("party", [])
	save_data.player_data.active_human = data.get("active_human", "")
	
	# Load human collection
	if data.has("human_collection"):
		_human_collection_from_dict(data["human_collection"])

func _human_collection_from_dict(data: Dictionary):
	save_data.player_data.human_collection.total_caught = data.get("total_caught", 0)
	save_data.player_data.human_collection.total_seen = data.get("total_seen", 0)
	save_data.player_data.human_collection.storage_boxes = data.get("storage_boxes", [])
	
	# Load collected humans
	var humans_data = data.get("collected_humans", {})
	for human_id in humans_data.keys():
		var human_data = humans_data[human_id]
		var human = _human_instance_from_dict(human_data)
		save_data.player_data.human_collection.collected_humans[human_id] = human

func _human_instance_from_dict(data: Dictionary) -> HumanInstance:
	var human = HumanInstance.new(data.get("species", "unknown"))
	human.id = data.get("id", "")
	human.level = data.get("level", 1)
	human.experience = data.get("experience", 0)
	human.nickname = data.get("nickname", "")
	human.caught_date = data.get("caught_date", "")
	human.caught_location = data.get("caught_location", "")
	human.nature = data.get("nature", "Hardy")
	human.moveset = data.get("moveset", [])
	human.status_effects = data.get("status_effects", {})
	human.friendship = data.get("friendship", 0)
	human.is_shiny = data.get("is_shiny", false)
	
	# Load stats
	var stats_data = data.get("stats", {})
	human.stats.hp = stats_data.get("hp", 10)
	human.stats.attack = stats_data.get("attack", 10)
	human.stats.defense = stats_data.get("defense", 10)
	human.stats.speed = stats_data.get("speed", 10)
	human.stats.current_hp = stats_data.get("current_hp", human.stats.hp)
	
	return human

func _world_state_from_dict(data: Dictionary):
	save_data.world_state.npcs_defeated = data.get("npcs_defeated", [])
	save_data.world_state.items_collected = data.get("items_collected", [])
	save_data.world_state.locations_visited = data.get("locations_visited", [])
	save_data.world_state.story_flags = data.get("story_flags", {})
	save_data.world_state.current_time = data.get("current_time", 0.0)
	save_data.world_state.play_time = data.get("play_time", 0.0)

func _game_statistics_from_dict(data: Dictionary):
	save_data.game_statistics.battles_won = data.get("battles_won", 0)
	save_data.game_statistics.battles_lost = data.get("battles_lost", 0)
	save_data.game_statistics.humans_caught = data.get("humans_caught", 0)
	save_data.game_statistics.humans_seen = data.get("humans_seen", 0)
	save_data.game_statistics.steps_taken = data.get("steps_taken", 0)
	save_data.game_statistics.money_earned = data.get("money_earned", 0)
	save_data.game_statistics.money_spent = data.get("money_spent", 0)
	save_data.game_statistics.start_time = data.get("start_time", "")
	save_data.game_statistics.total_play_time = data.get("total_play_time", 0.0)

func _apply_save_data():
	# Apply loaded save data to current game state
	# This will be expanded as more systems are implemented
	print("SaveManager: Applying save data...")

# Public API
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)

func delete_save_file() -> bool:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var dir = DirAccess.open("user://")
		if dir:
			dir.remove(SAVE_FILE_PATH)
			return true
	return false

func get_save_info() -> Dictionary:
	if not has_save_file():
		return {}
	
	# Quick load of save file info without full loading
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file == null:
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		return {}
	
	var data = json.data
	return {
		"version": data.get("version", "Unknown"),
		"timestamp": data.get("timestamp", "Unknown"),
		"player_name": data.get("player_data", {}).get("name", "Unknown"),
		"player_level": data.get("player_data", {}).get("level", 1),
		"location": data.get("player_data", {}).get("current_location", "Unknown"),
		"play_time": data.get("game_statistics", {}).get("total_play_time", 0.0)
	}

func set_auto_save_enabled(enabled: bool):
	auto_save_enabled = enabled
	if auto_save_timer:
		auto_save_timer.paused = not enabled

func set_auto_save_interval(interval: float):
	auto_save_interval = interval
	if auto_save_timer:
		auto_save_timer.wait_time = interval