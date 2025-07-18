extends Node

# BEUTEL (Inventory) Management System for Menschenmon
# Handles all item management, usage, and drop mechanics

signal item_added(item_id: String, quantity: int)
signal item_removed(item_id: String, quantity: int)
signal item_used(item_id: String, target: Node)
signal inventory_full(item_id: String)

# Core inventory data
var inventory: Dictionary = {}  # item_id -> quantity
var item_database: Dictionary = {}
var player_money: int = 1000

# Inventory limits - now using GameConstants
# const MAX_INVENTORY_SLOTS = 300  # Now using GameConstants.MAX_INVENTORY_SLOTS
# const MAX_MONEY = 999999  # Now using GameConstants.MAX_MONEY

# Item categories for UI organization
enum ItemCategory {
	FANGGERAETE,
	MEDIZIN,
	KAMPF_BOOSTS,
	BASIS_ITEMS
}

# Item rarity levels
enum ItemRarity {
	COMMON,
	UNCOMMON,
	RARE,
	LEGENDARY,
	KEY
}

# Core managers
var data_manager: Node = null
var game_state_manager: Node = null
var audio_manager: Node = null

func _ready():
	# Initialize inventory system
	print("InventoryManager: Initializing...")
	
	# Get core managers
	data_manager = get_node_or_null("/root/DataManager")
	game_state_manager = get_node_or_null("/root/GameStateManager") 
	audio_manager = get_node_or_null("/root/AudioManager")
	
	# Load item database
	await _load_item_database()
	
	# Initialize with starting items
	_initialize_starting_inventory()
	
	print("InventoryManager: Ready with ", inventory.size(), " item types")

func _load_item_database():
	# Load items from JSON file with error handling
	var file_path = GameConstants.ITEMS_DATABASE_PATH
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file == null:
		item_database = ErrorHandler.handle_file_load_error(file_path, _get_fallback_item_database())
		if item_database == null:
			item_database = _get_fallback_item_database()
		return
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result != OK:
		ErrorHandler.log_error("Error parsing items.json: %s" % json.error_string, ErrorHandler.ErrorType.FILE_IO)
		item_database = _get_fallback_item_database()
		return
	
	item_database = json.data
	EventBus.log_event("items_loaded", {"count": _count_total_items()})

func _get_fallback_item_database() -> Dictionary:
	"""Provide fallback item database in case of loading failure."""
	return {
		"medizin": {
			"potion": {
				"name": "Heiltrank",
				"description": "Heilt 20 HP",
				"category": "medizin",
				"heal_amount": 20,
				"icon": "res://assets/items/potion.png"
			}
		},
		"fanggeraete": {
			"pokeball": {
				"name": "Pokéball",
				"description": "Zum Fangen von Pokémon",
				"category": "fanggeraete",
				"catch_rate": 1.0,
				"icon": "res://assets/items/pokeball.png"
			}
		},
		"sonstiges": {}
	}

func _count_total_items() -> int:
	var count = 0
	for category in item_database:
		if category != "drop_tables":
			count += item_database[category].size()
	return count

func _initialize_starting_inventory():
	# Give player some starting items
	add_item("smartphone", 1)
	add_item("wg_schluessel", 1)
	add_item("geldbeutel", 1)
	add_item("bierdeckel", 5)
	add_item("freundschaftsanfrage", 3)
	add_item("kaffee", 2)
	add_item("pizza_stueck", 1)

# Public API - Item Management
func add_item(item_id: String, quantity: int = 1) -> bool:
	"""Add an item to the inventory with error handling and events."""
	if not _is_valid_item(item_id):
		ErrorHandler.log_warning("Invalid item ID: %s" % item_id, {"item_id": item_id})
		return false
	
	var item_data = _get_item_data(item_id)
	if item_data == null:
		ErrorHandler.log_error("Could not retrieve item data for: %s" % item_id, ErrorHandler.ErrorType.GENERIC)
		return false
	
	# Check if inventory is full for new items
	if not has_item(item_id) and inventory.size() >= GameConstants.MAX_INVENTORY_SLOTS:
		inventory_full.emit(item_id)
		EventBus.notify_warning("Inventory full, cannot add item: %s" % item_id)
		return false
	
	# Check stack size limit
	var current_amount = inventory.get(item_id, 0)
	var max_stack = item_data.get("stack_size", GameConstants.DEFAULT_STACK_SIZE)
	var space_available = max_stack - current_amount
	
	if space_available <= 0:
		inventory_full.emit(item_id)
		EventBus.notify_warning("Stack full for item: %s" % item_id)
		return false
	
	# Add what we can
	var amount_to_add = min(quantity, space_available)
	inventory[item_id] = current_amount + amount_to_add
	
	# Emit events
	item_added.emit(item_id, amount_to_add)
	EventBus.notify_item_action("added", item_id, amount_to_add)
	
	return amount_to_add == quantity

func remove_item(item_id: String, quantity: int = 1) -> bool:
	if not has_item(item_id):
		return false
	
	var current_amount = inventory[item_id]
	if current_amount < quantity:
		return false
	
	inventory[item_id] = current_amount - quantity
	
	# Remove from inventory if quantity reaches 0
	if inventory[item_id] <= 0:
		inventory.erase(item_id)
	
	item_removed.emit(item_id, quantity)
	return true

func has_item(item_id: String) -> bool:
	return inventory.has(item_id) and inventory[item_id] > 0

func get_item_count(item_id: String) -> int:
	return inventory.get(item_id, 0)

func get_inventory_by_category(category: ItemCategory) -> Dictionary:
	var category_items = {}
	var category_name = _get_category_name(category)
	
	for item_id in inventory:
		var item_data = _get_item_data(item_id)
		if item_data != null and item_data.get("category") == category_name:
			category_items[item_id] = {
				"quantity": inventory[item_id],
				"data": item_data
			}
	
	return category_items

func get_total_inventory_count() -> int:
	return inventory.size()

func get_money() -> int:
	return player_money

func add_money(amount: int):
	player_money = GameConstants.clamp_money(player_money + amount)

func spend_money(amount: int) -> bool:
	if player_money >= amount:
		player_money -= amount
		return true
	return false

# Public API - Item Usage
func use_item(item_id: String, target: Node = null) -> bool:
	if not has_item(item_id):
		return false
	
	var item_data = _get_item_data(item_id)
	if item_data == null:
		return false
	
	# Don't consume key items
	if item_data.get("key_item", false):
		_use_key_item(item_id, target)
		return true
	
	# Apply item effects
	var success = _apply_item_effects(item_id, item_data, target)
	
	if success:
		remove_item(item_id, 1)
		item_used.emit(item_id, target)
		
		# Play usage sound
		if audio_manager:
			audio_manager.play_sfx("item_use")
	
	return success

func _use_key_item(item_id: String, target: Node):
	# Handle key item usage (smartphone, keys, etc.)
	match item_id:
		"smartphone":
			# Open Menschendex or map
			print("InventoryManager: Opening smartphone...")
		"wg_schluessel":
			# Teleport to WG or unlock WG
			print("InventoryManager: Using WG key...")
		"fahrrad":
			# Enable bike mode
			print("InventoryManager: Getting on bike...")

func _apply_item_effects(item_id: String, item_data: Dictionary, target: Node) -> bool:
	var category = item_data.get("category", "")
	
	match category:
		"fanggeraete":
			return _use_catching_item(item_id, item_data, target)
		"medizin":
			return _use_healing_item(item_id, item_data, target)
		"kampf_boosts":
			return _use_boost_item(item_id, item_data, target)
		"basis_items":
			return _use_basic_item(item_id, item_data, target)
	
	return false

func _use_catching_item(item_id: String, item_data: Dictionary, target: Node) -> bool:
	# This will be called from battle system
	print("InventoryManager: Using catching item ", item_data.name)
	return true

func _use_healing_item(item_id: String, item_data: Dictionary, target: Node) -> bool:
	if target == null:
		return false
	
	# Heal target
	var heal_amount = item_data.get("heal_amount", 0)
	if heal_amount > 0:
		if heal_amount == 999:  # Full heal
			target.heal_to_full()
		else:
			target.heal(heal_amount)
	
	# Cure status effects
	if item_data.get("cures_all_status", false):
		target.cure_all_status()
	elif item_data.has("cures_status"):
		for status in item_data["cures_status"]:
			target.cure_status(status)
	
	# Handle revival
	if item_data.get("revive", false):
		if target.is_fainted():
			target.revive(item_data.get("revive_hp_percent", 0.5))
	
	print("InventoryManager: Used healing item ", item_data.name, " on ", target.name)
	return true

func _use_boost_item(item_id: String, item_data: Dictionary, target: Node) -> bool:
	if target == null:
		return false
	
	# Apply stat boost
	var boost_stat = item_data.get("boost_stat", "")
	var boost_amount = item_data.get("boost_amount", 1)
	var boost_duration = item_data.get("boost_duration", "battle")
	
	if boost_stat != "":
		target.apply_stat_boost(boost_stat, boost_amount, boost_duration)
	
	print("InventoryManager: Used boost item ", item_data.name, " on ", target.name)
	return true

func _use_basic_item(item_id: String, item_data: Dictionary, target: Node) -> bool:
	# Handle basic items like bottles
	if item_id == "leere_flaschen":
		# Convert to money
		var sell_value = item_data.get("sell_value", 0)
		add_money(sell_value)
		print("InventoryManager: Sold bottles for ", sell_value, " credits")
		return true
	
	return false

# Public API - Item Drops
func roll_item_drop(enemy_type: String, attack_used: String = "") -> String:
	# Get drop table for enemy type
	var drop_tables = item_database.get("drop_tables", {})
	var enemy_drops = drop_tables.get(enemy_type, {})
	
	if enemy_drops.size() == 0:
		return ""
	
	# Roll for rarity first
	var rarity_roll = randf()
	var rarity = ""
	
	if rarity_roll < 0.05:  # 5% rare
		rarity = "rare"
	elif rarity_roll < 0.20:  # 15% uncommon
		rarity = "uncommon"
	else:  # 80% common
		rarity = "common"
	
	# Get items for this rarity
	var rarity_items = enemy_drops.get(rarity, [])
	if rarity_items.size() == 0:
		return ""
	
	# Roll for specific item
	var total_chance = 0.0
	for item_entry in rarity_items:
		total_chance += item_entry.get("chance", 0.0)
	
	if total_chance <= 0.0:
		return ""
	
	var item_roll = randf() * total_chance
	var current_chance = 0.0
	
	for item_entry in rarity_items:
		current_chance += item_entry.get("chance", 0.0)
		if item_roll <= current_chance:
			return item_entry.get("item", "")
	
	return ""

func try_drop_item(enemy_type: String, attack_used: String = "") -> bool:
	var dropped_item = roll_item_drop(enemy_type, attack_used)
	
	if dropped_item != "":
		add_item(dropped_item, 1)
		return true
	
	return false

# Helper functions
func _is_valid_item(item_id: String) -> bool:
	return _get_item_data(item_id) != null

func _get_item_data(item_id: String) -> Dictionary:
	# Search through all categories
	for category in item_database:
		if category != "drop_tables":
			var category_items = item_database[category]
			if category_items.has(item_id):
				return category_items[item_id]
	
	return {}

func _get_category_name(category: ItemCategory) -> String:
	match category:
		ItemCategory.FANGGERAETE:
			return "fanggeraete"
		ItemCategory.MEDIZIN:
			return "medizin"
		ItemCategory.KAMPF_BOOSTS:
			return "kampf_boosts"
		ItemCategory.BASIS_ITEMS:
			return "basis_items"
	
	return ""

func get_item_display_name(item_id: String) -> String:
	var item_data = _get_item_data(item_id)
	return item_data.get("name", item_id)

func get_item_description(item_id: String) -> String:
	var item_data = _get_item_data(item_id)
	return item_data.get("description", "")

func get_item_icon(item_id: String) -> String:
	var item_data = _get_item_data(item_id)
	return item_data.get("icon", "default_item")

func get_item_rarity(item_id: String) -> String:
	var item_data = _get_item_data(item_id)
	return item_data.get("rarity", "common")

func get_catch_rate(item_id: String) -> float:
	var item_data = _get_item_data(item_id)
	return item_data.get("catch_rate", 1.0)

func has_first_turn_bonus(item_id: String) -> bool:
	var item_data = _get_item_data(item_id)
	return item_data.get("first_turn_bonus", false)

func get_type_bonus(item_id: String) -> Array:
	var item_data = _get_item_data(item_id)
	return item_data.get("type_bonus", [])

# Save/Load system integration
func get_save_data() -> Dictionary:
	return {
		"inventory": inventory,
		"money": player_money
	}

func load_save_data(data: Dictionary):
	inventory = data.get("inventory", {})
	player_money = data.get("money", 1000)
	print("InventoryManager: Loaded save data with ", inventory.size(), " item types")

# Debug functions
func give_all_items():
	print("InventoryManager: Giving all items for testing...")
	for category in item_database:
		if category != "drop_tables":
			for item_id in item_database[category]:
				var item_data = item_database[category][item_id]
				if not item_data.get("key_item", false):
					add_item(item_id, 5)
	print("InventoryManager: Debug items added")

func print_inventory():
	print("InventoryManager: Current inventory:")
	for item_id in inventory:
		var item_data = _get_item_data(item_id)
		var name = item_data.get("name", item_id)
		print("  ", name, " x", inventory[item_id])
	print("  Money: ", player_money)