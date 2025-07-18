extends Control

# Compact Battle Inventory - Replaces command buttons during item selection
# Shows 6 items at a time in a 2x3 grid, with tabs at top for category switching

signal item_selected(item_id: String)
signal inventory_closed

# UI References
@onready var category_tabs = $CategoryTabs
@onready var tab_medizin = $CategoryTabs/TabMedizin
@onready var tab_fanggeraete = $CategoryTabs/TabFanggeraete
@onready var tab_boosts = $CategoryTabs/TabBoosts
@onready var back_button = $CategoryTabs/BackButton
@onready var item_grid = $ItemGrid

# Item slot references
var item_slots: Array = []

# Current state
var current_category: String = "medizin"
var current_page: int = 0
var items_per_page: int = 6
var current_items: Array = []
var selected_slot: int = 0
var battle_context: Dictionary = {}

# References
var inventory_manager: Node = null
var battle_manager: Node = null

func _ready():
	# Get references
	inventory_manager = get_node_or_null("/root/InventoryManager")
	battle_manager = get_parent()
	
	# Get item slot references
	for i in range(6):
		var slot = item_grid.get_child(i)
		item_slots.append(slot)
		slot.pressed.connect(_on_item_slot_pressed.bind(i))
	
	# Connect tab buttons
	tab_medizin.pressed.connect(func(): _switch_category("medizin"))
	tab_fanggeraete.pressed.connect(func(): _switch_category("fanggeraete"))
	tab_boosts.pressed.connect(func(): _switch_category("kampf_boosts"))
	back_button.pressed.connect(_on_back_pressed)
	
	# Apply styling
	_setup_styling()

func _setup_styling():
	# Style the tabs
	for tab in [tab_medizin, tab_fanggeraete, tab_boosts]:
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
		
		var selected_style = StyleBoxFlat.new()
		selected_style.bg_color = Color("#FFF4E0")
		selected_style.border_color = Color("#FF8C00")
		selected_style.border_width_left = 2
		selected_style.border_width_right = 2
		selected_style.border_width_top = 2
		selected_style.border_width_bottom = 2
		selected_style.corner_radius_top_left = 6
		selected_style.corner_radius_top_right = 6
		selected_style.corner_radius_bottom_left = 6
		selected_style.corner_radius_bottom_right = 6
		tab.add_theme_stylebox_override("pressed", selected_style)
	
	# Style item slots
	for slot in item_slots:
		var slot_style = StyleBoxFlat.new()
		slot_style.bg_color = Color("#F5F5F5")
		slot_style.border_color = Color("#CCCCCC")
		slot_style.border_width_left = 1
		slot_style.border_width_right = 1
		slot_style.border_width_top = 1
		slot_style.border_width_bottom = 1
		slot_style.corner_radius_top_left = 4
		slot_style.corner_radius_top_right = 4
		slot_style.corner_radius_bottom_left = 4
		slot_style.corner_radius_bottom_right = 4
		slot.add_theme_stylebox_override("normal", slot_style)
		
		var selected_style = StyleBoxFlat.new()
		selected_style.bg_color = Color("#FFFACD")
		selected_style.border_color = Color("#FF4500")
		selected_style.border_width_left = 3
		selected_style.border_width_right = 3
		selected_style.border_width_top = 3
		selected_style.border_width_bottom = 3
		selected_style.corner_radius_top_left = 4
		selected_style.corner_radius_top_right = 4
		selected_style.corner_radius_bottom_left = 4
		selected_style.corner_radius_bottom_right = 4
		slot.add_theme_stylebox_override("pressed", selected_style)

func open_battle_inventory(context: Dictionary):
	battle_context = context
	current_page = 0
	
	# Update tab availability based on context
	var is_trainer_battle = context.get("is_trainer_battle", false)
	tab_fanggeraete.disabled = is_trainer_battle
	if is_trainer_battle:
		tab_fanggeraete.modulate = Color(0.5, 0.5, 0.5, 1.0)
	else:
		tab_fanggeraete.modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	# Switch to default category
	_switch_category("medizin")
	
	# Show the inventory
	visible = true
	
	# Update selection
	selected_slot = 0
	_update_selection()

func close_battle_inventory():
	visible = false
	inventory_closed.emit()

func _switch_category(category: String):
	current_category = category
	current_page = 0
	_update_tab_selection()
	_populate_items()

func _update_tab_selection():
	# Update visual selection
	tab_medizin.button_pressed = (current_category == "medizin")
	tab_fanggeraete.button_pressed = (current_category == "fanggeraete")
	tab_boosts.button_pressed = (current_category == "kampf_boosts")

func _populate_items():
	if not inventory_manager:
		return
	
	# Get items for current category
	var category_enum = _get_category_enum(current_category)
	var items = inventory_manager.get_inventory_by_category(category_enum)
	
	# Convert to array and sort
	current_items = []
	for item_id in items:
		var item_data = items[item_id]
		current_items.append({
			"id": item_id,
			"name": item_data["data"]["name"],
			"quantity": item_data["quantity"],
			"data": item_data["data"],
			"usable": _is_item_usable(item_id, item_data["data"])
		})
	
	# Sort by name
	current_items.sort_custom(func(a, b): return a.name < b.name)
	
	# Update display
	_update_item_display()

func _is_item_usable(item_id: String, item_data: Dictionary) -> bool:
	var category = item_data.get("category", "")
	var team_members = battle_context.get("team_members", [])
	
	match category:
		"fanggeraete":
			return not battle_context.get("is_trainer_battle", false)
		
		"medizin":
			var heal_amount = item_data.get("heal_amount", 0)
			var cures_status = item_data.get("cures_status", [])
			var revive = item_data.get("revive", false)
			
			# Check if any team member can benefit
			for member in team_members:
				if revive and member.get("is_fainted", false):
					return true
				if heal_amount > 0 and member.get("current_hp", 100) < member.get("max_hp", 100):
					return true
				if cures_status.size() > 0:
					var member_status = member.get("status_effects", [])
					for status in cures_status:
						if status in member_status:
							return true
			return false
		
		"kampf_boosts":
			return true
	
	return false

func _update_item_display():
	var start_index = current_page * items_per_page
	
	for i in range(items_per_page):
		var slot = item_slots[i]
		var item_index = start_index + i
		
		if item_index < current_items.size():
			var item = current_items[item_index]
			slot.text = item.name + " x" + str(item.quantity)
			slot.visible = true
			slot.disabled = not item.usable
			
			# Gray out unusable items
			if not item.usable:
				slot.modulate = Color(0.5, 0.5, 0.5, 1.0)
			else:
				slot.modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			slot.text = ""
			slot.visible = false
			slot.disabled = true
	
	# Update selection
	_update_selection()

func _update_selection():
	# Reset all slots
	for i in range(item_slots.size()):
		var slot = item_slots[i]
		if i == selected_slot and slot.visible and not slot.disabled:
			slot.button_pressed = true
		else:
			slot.button_pressed = false

func _on_item_slot_pressed(slot_index: int):
	if slot_index >= current_items.size():
		return
	
	var start_index = current_page * items_per_page
	var item_index = start_index + slot_index
	
	if item_index < current_items.size():
		var item = current_items[item_index]
		if item.usable:
			selected_slot = slot_index
			_use_item(item.id)

func _use_item(item_id: String):
	# Check if item needs target selection
	var item_data = inventory_manager._get_item_data(item_id)
	var category = item_data.get("category", "")
	
	if category == "fanggeraete":
		# Use directly on enemy
		item_selected.emit(item_id)
		close_battle_inventory()
	elif category == "medizin" or category == "kampf_boosts":
		# Need target selection - for now, use on player
		item_selected.emit(item_id)
		close_battle_inventory()

func _on_back_pressed():
	close_battle_inventory()

func _get_category_enum(category: String) -> int:
	match category:
		"fanggeraete":
			return 0  # InventoryManager.ItemCategory.FANGGERAETE
		"medizin":
			return 1  # InventoryManager.ItemCategory.MEDIZIN
		"kampf_boosts":
			return 2  # InventoryManager.ItemCategory.KAMPF_BOOSTS
		_:
			return 3  # InventoryManager.ItemCategory.BASIS_ITEMS

func _input(event):
	if not visible:
		return
	
	if event.is_pressed():
		if event.is_action("ui_cancel"):
			close_battle_inventory()
		elif event.is_action("ui_accept"):
			_use_current_item()
		elif event.is_action("ui_left"):
			_navigate_horizontal(-1)
		elif event.is_action("ui_right"):
			_navigate_horizontal(1)
		elif event.is_action("ui_up"):
			_navigate_vertical(-1)
		elif event.is_action("ui_down"):
			_navigate_vertical(1)

func _navigate_horizontal(direction: int):
	var new_slot = selected_slot + direction
	if new_slot >= 0 and new_slot < items_per_page:
		if item_slots[new_slot].visible:
			selected_slot = new_slot
			_update_selection()

func _navigate_vertical(direction: int):
	var new_slot = selected_slot + (direction * 2)  # 2 columns
	if new_slot >= 0 and new_slot < items_per_page:
		if item_slots[new_slot].visible:
			selected_slot = new_slot
			_update_selection()

func _use_current_item():
	if selected_slot < item_slots.size():
		var slot = item_slots[selected_slot]
		if slot.visible and not slot.disabled:
			_on_item_slot_pressed(selected_slot)