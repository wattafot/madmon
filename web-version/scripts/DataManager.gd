extends Node

# Centralized Data Management System for Menschenmon
# Handles loading, caching, and validation of all game data

signal data_loaded
signal data_load_failed(error: String)

# Cache for loaded data
var enemy_database: Dictionary = {}
var human_database: Dictionary = {}
var attack_database: Dictionary = {}
var loaded_files: Array[String] = []

# Data validation flags
var data_validated: bool = false
var validation_errors: Array[String] = []

func _ready():
	# Initialize data manager
	print("DataManager: Initializing...")
	_load_all_data()

func _load_all_data():
	# Load all game data files
	await _load_enemy_data()
	await _load_human_data()
	await _load_attack_data()
	
	# Validate loaded data
	_validate_all_data()
	
	if validation_errors.size() > 0:
		print("DataManager: Validation errors found:")
		for error in validation_errors:
			print("  - " + error)
		data_load_failed.emit("Validation failed")
	else:
		print("DataManager: All data loaded and validated successfully")
		data_loaded.emit()

func _load_enemy_data():
	var file_path = "res://data/enemies.json"
	var file_content = await _load_json_file(file_path)
	
	if file_content != null:
		enemy_database = file_content.get("enemies", {})
		loaded_files.append("enemies.json")
		print("DataManager: Loaded ", enemy_database.size(), " enemies")
	else:
		validation_errors.append("Failed to load enemies.json")

func _load_human_data():
	# Placeholder for future human data
	var file_path = "res://data/humans.json"
	var file_content = await _load_json_file(file_path)
	
	if file_content != null:
		human_database = file_content.get("humans", {})
		loaded_files.append("humans.json")
		print("DataManager: Loaded ", human_database.size(), " human types")
	else:
		# Not an error yet, as this file doesn't exist
		human_database = {}
		print("DataManager: humans.json not found, using empty database")

func _load_attack_data():
	# Placeholder for future attack data
	var file_path = "res://data/attacks.json"
	var file_content = await _load_json_file(file_path)
	
	if file_content != null:
		attack_database = file_content.get("attacks", {})
		loaded_files.append("attacks.json")
		print("DataManager: Loaded ", attack_database.size(), " attack definitions")
	else:
		# Not an error yet, as this file doesn't exist
		attack_database = {}
		print("DataManager: attacks.json not found, using empty database")

func _load_json_file(file_path: String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		print("DataManager: File not found: ", file_path)
		return {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("DataManager: Failed to open file: ", file_path)
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		print("DataManager: JSON parse error in ", file_path, ": ", json.get_error_message())
		return {}
	
	return json.data

func _validate_all_data():
	# Validate enemy data
	_validate_enemy_database()
	
	# Validate human data (when implemented)
	_validate_human_database()
	
	# Validate attack data (when implemented)
	_validate_attack_database()
	
	data_validated = true

func _validate_enemy_database():
	for enemy_id in enemy_database.keys():
		var enemy_data = enemy_database[enemy_id]
		
		# Required fields validation
		var required_fields = ["trainer_name", "fighter_name", "fighter_level", "attacks"]
		for field in required_fields:
			if not enemy_data.has(field):
				validation_errors.append("Enemy " + enemy_id + " missing required field: " + field)
		
		# Attack validation
		if enemy_data.has("attacks"):
			var attacks = enemy_data["attacks"]
			if not attacks is Array:
				validation_errors.append("Enemy " + enemy_id + " attacks must be an Array")
			else:
				for i in range(attacks.size()):
					_validate_attack_data(attacks[i], enemy_id + ".attacks[" + str(i) + "]")

func _validate_human_database():
	# Placeholder for future human data validation
	pass

func _validate_attack_database():
	# Placeholder for future attack data validation
	pass

func _validate_attack_data(attack_data: Dictionary, context: String):
	var required_fields = ["name", "type", "category", "base_power", "accuracy", "max_ap"]
	
	for field in required_fields:
		if not attack_data.has(field):
			validation_errors.append(context + " missing required field: " + field)
	
	# Validate ranges
	if attack_data.has("accuracy") and (attack_data["accuracy"] < 0 or attack_data["accuracy"] > 100):
		validation_errors.append(context + " accuracy must be between 0 and 100")
	
	if attack_data.has("base_power") and attack_data["base_power"] < 0:
		validation_errors.append(context + " base_power cannot be negative")

# Public API functions
func get_enemy_data(enemy_id: String) -> Dictionary:
	if enemy_id in enemy_database:
		return enemy_database[enemy_id]
	else:
		print("DataManager: Enemy ID not found: ", enemy_id)
		return {}

func get_human_data(human_id: String) -> Dictionary:
	if human_id in human_database:
		return human_database[human_id]
	else:
		print("DataManager: Human ID not found: ", human_id)
		return {}

func get_attack_data(attack_id: String) -> Dictionary:
	if attack_id in attack_database:
		return attack_database[attack_id]
	else:
		print("DataManager: Attack ID not found: ", attack_id)
		return {}

func get_enemy_list() -> Array:
	return enemy_database.keys()

func get_human_list() -> Array:
	return human_database.keys()

func is_data_loaded() -> bool:
	return data_validated and validation_errors.size() == 0

func get_validation_errors() -> Array[String]:
	return validation_errors

func reload_data():
	# Clear current data
	enemy_database.clear()
	human_database.clear()
	attack_database.clear()
	loaded_files.clear()
	validation_errors.clear()
	data_validated = false
	
	# Reload all data
	_load_all_data()