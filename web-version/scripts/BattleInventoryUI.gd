extends Control

# Battle Inventory UI - Tactical overlay for in-battle item usage
# Implements the compact, overlay-based inventory system described in the design

signal inventory_closed
signal item_selected(item_id: String, target_character: String)

# UI References
@onready var overlay_background = $OverlayBackground
@onready var inventory_panel = $InventoryPanel
@onready var close_button = $InventoryPanel/MainContainer/HeaderContainer/CloseButton
@onready var tab_fanggeraete = $InventoryPanel/MainContainer/ContentContainer/CategoryPanel/CategoryButtons/TabFanggeraete
@onready var tab_medizin = $InventoryPanel/MainContainer/ContentContainer/CategoryPanel/CategoryButtons/TabMedizin
@onready var tab_kampf_boosts = $InventoryPanel/MainContainer/ContentContainer/CategoryPanel/CategoryButtons/TabKampfBoosts
@onready var item_list = $InventoryPanel/MainContainer/ContentContainer/ItemListPanel/ItemList
@onready var item_description = $InventoryPanel/MainContainer/ContentContainer/DetailsPanel/ItemDescription
@onready var use_button = $InventoryPanel/MainContainer/ContentContainer/DetailsPanel/UseButton

# References to battle system
var battle_manager: Node = null
var inventory_manager: Node = null
var current_team_members: Array = []

# Current state
var current_category: String = "medizin"
var current_item_id: String = ""
var selected_item_index: int = 0
var tab_index: int = 1  # Start with Medizin tab (most common in battle)
var in_target_selection: bool = false
var target_index: int = 0

# Tab buttons for navigation
var tab_buttons: Array = []

# Category configuration for battle context
var battle_categories = {
	"fanggeraete": {
		"name": "Fangen",
		"icon": "🎯",
		"button": null,
		"enabled": true  # Will be set based on battle context
	},
	"medizin": {
		"name": "Medizin",
		"icon": "💊",
		"button": null,
		"enabled": true
	},
	"kampf_boosts": {
		"name": "Boost",
		"icon": "⚡",
		"button": null,
		"enabled": true
	}
}

func _ready():
	# Get managers
	battle_manager = get_node_or_null("/root/BattleManager")
	inventory_manager = get_node_or_null("/root/InventoryManager")
	
	# Setup tab buttons
	tab_buttons = [tab_fanggeraete, tab_medizin, tab_kampf_boosts]
	battle_categories["fanggeraete"]["button"] = tab_fanggeraete
	battle_categories["medizin"]["button"] = tab_medizin
	battle_categories["kampf_boosts"]["button"] = tab_kampf_boosts
	
	# Connect signals
	close_button.pressed.connect(_on_close_pressed)
	use_button.pressed.connect(_on_use_pressed)
	
	# Connect tab buttons
	tab_fanggeraete.pressed.connect(func(): _switch_category("fanggeraete"))
	tab_medizin.pressed.connect(func(): _switch_category("medizin"))
	tab_kampf_boosts.pressed.connect(func(): _switch_category("kampf_boosts"))
	
	# Connect item list
	item_list.item_selected.connect(_on_item_selected)
	
	# Apply battle-specific styling
	_setup_battle_styling()
	
	# Hide initially
	visible = false

func _setup_battle_styling():
	# Create overlay style with transparency
	overlay_background.color = Color(0, 0, 0, 0.7)
	
	# Style the main panel with rounded corners
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color("#F5F5F5")
	panel_style.border_color = Color("#333333")
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.corner_radius_top_left = 12
	panel_style.corner_radius_top_right = 12
	panel_style.corner_radius_bottom_left = 12
	panel_style.corner_radius_bottom_right = 12
	inventory_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Style tab buttons
	_style_tab_buttons()
	
	# Style item list
	_style_item_list()

func _style_tab_buttons():
	for i in range(tab_buttons.size()):
		var button = tab_buttons[i]
		
		# Normal state
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
		
		# Selected state
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
		button.add_theme_stylebox_override("pressed", selected_style)
		
		# Text color
		button.add_theme_color_override("font_color", Color("#000000"))

func _style_item_list():
	# Style item list with alternating colors
	var list_style = StyleBoxFlat.new()
	list_style.bg_color = Color("#FFFFFF")
	list_style.border_color = Color("#CCCCCC")
	list_style.border_width_left = 1
	list_style.border_width_right = 1
	list_style.border_width_top = 1
	list_style.border_width_bottom = 1
	list_style.corner_radius_top_left = 4
	list_style.corner_radius_top_right = 4
	list_style.corner_radius_bottom_left = 4
	list_style.corner_radius_bottom_right = 4
	item_list.add_theme_stylebox_override("panel", list_style)

func open_battle_inventory(battle_context: Dictionary):
	# Set up battle context
	current_team_members = battle_context.get("team_members", [])
	var is_trainer_battle = battle_context.get("is_trainer_battle", false)
	
	# Disable catching items in trainer battles
	battle_categories["fanggeraete"]["enabled"] = not is_trainer_battle
	
	# Update tab button states
	_update_tab_states()
	
	# Show the overlay
	visible = true
	
	# Switch to default category (Medizin)
	_switch_category("medizin")
	
	# Focus on the overlay
	grab_focus()

func close_battle_inventory():
	visible = false
	in_target_selection = false
	inventory_closed.emit()

func _update_tab_states():
	# Update tab button availability based on battle context
	for category in battle_categories:
		var button = battle_categories[category]["button"]
		var enabled = battle_categories[category]["enabled"]
		
		if button:
			button.disabled = not enabled
			if not enabled:
				button.modulate = Color(0.5, 0.5, 0.5, 1.0)
			else:
				button.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _switch_category(category: String):
	current_category = category
	_update_tab_selection()
	_populate_item_list()

func _update_tab_selection():
	# Update visual selection of tabs
	for category in battle_categories:
		var button = battle_categories[category]["button"]
		if button:
			if category == current_category:
				button.button_pressed = true
			else:
				button.button_pressed = false

func _populate_item_list():
	if not inventory_manager:
		return
	
	item_list.clear()
	
	# Get items for current category
	var category_enum = _get_category_enum(current_category)
	var items = inventory_manager.get_inventory_by_category(category_enum)
	
	var item_index = 0
	for item_id in items:
		var item_data = items[item_id]
		var quantity = item_data["quantity"]
		var item_info = item_data["data"]
		
		# Check if item is usable in current battle context
		var is_usable = _is_item_usable_in_battle(item_id, item_info)
		
		# Create item text
		var item_text = item_info["name"] + " x" + str(quantity)
		
		# Add to list
		item_list.add_item(item_text)
		
		# Gray out unusable items
		if not is_usable:
			item_list.set_item_disabled(item_index, true)
			item_list.set_item_custom_fg_color(item_index, Color(0.5, 0.5, 0.5, 1.0))
		
		# Store item ID as metadata
		item_list.set_item_metadata(item_index, item_id)
		
		item_index += 1
	
	# Select first usable item
	_select_first_usable_item()

func _is_item_usable_in_battle(item_id: String, item_info: Dictionary) -> bool:
	var category = item_info.get("category", "")
	
	match category:
		"fanggeraete":
			# Only usable if catching is enabled (not in trainer battles)
			return battle_categories["fanggeraete"]["enabled"]
		
		"medizin":
			# Check if any team member can benefit from this item
			var heal_amount = item_info.get("heal_amount", 0)
			var cures_status = item_info.get("cures_status", [])
			var revive = item_info.get("revive", false)
			
			# Always usable if it's a revival item and someone is fainted
			if revive:
				for member in current_team_members:
					if member.get("is_fainted", false):
						return true
			
			# Usable if someone is injured or has status effects
			if heal_amount > 0:
				for member in current_team_members:
					if member.get("current_hp", 100) < member.get("max_hp", 100):
						return true
			
			if cures_status.size() > 0:
				for member in current_team_members:
					var member_status = member.get("status_effects", [])
					for status in cures_status:
						if status in member_status:
							return true
			
			return false
		
		"kampf_boosts":
			# Always usable in battle
			return true
	
	return false

func _select_first_usable_item():
	# Find first non-disabled item
	for i in range(item_list.get_item_count()):
		if not item_list.is_item_disabled(i):
			item_list.select(i)
			selected_item_index = i
			_on_item_selected(i)
			return
	
	# If no usable items, select first item anyway
	if item_list.get_item_count() > 0:
		item_list.select(0)
		selected_item_index = 0
		_on_item_selected(0)

func _on_item_selected(index: int):
	selected_item_index = index
	current_item_id = item_list.get_item_metadata(index)
	
	# Update item description
	_update_item_description()
	
	# Enable/disable use button
	use_button.disabled = item_list.is_item_disabled(index)

func _update_item_description():
	if not inventory_manager or current_item_id == "":
		item_description.text = "Wähle ein Item aus..."
		return
	
	var item_info = inventory_manager._get_item_data(current_item_id)
	if item_info.is_empty():
		item_description.text = "Item-Information nicht verfügbar."
		return
	
	var description = item_info.get("description", "Keine Beschreibung verfügbar.")
	
	# Add tactical information for battle context
	var tactical_info = _get_tactical_info(current_item_id, item_info)
	if tactical_info != "":
		description += "\n\n" + tactical_info
	
	item_description.text = description

func _get_tactical_info(item_id: String, item_info: Dictionary) -> String:
	var category = item_info.get("category", "")
	
	match category:
		"fanggeraete":
			var catch_rate = item_info.get("catch_rate", 1.0)
			var type_bonus = item_info.get("type_bonus", [])
			var info = "Fangrate: " + str(int(catch_rate * 100)) + "%"
			if type_bonus.size() > 0:
				info += "\nBonus gegen: " + str(type_bonus)
			return info
		
		"medizin":
			var heal_amount = item_info.get("heal_amount", 0)
			var cures_status = item_info.get("cures_status", [])
			var revive = item_info.get("revive", false)
			
			var info = ""
			if heal_amount > 0:
				if heal_amount == 999:
					info += "Heilt vollständig"
				else:
					info += "Heilt " + str(heal_amount) + " HP"
			if cures_status.size() > 0:
				if info != "":
					info += "\n"
				info += "Heilt: " + str(cures_status)
			if revive:
				if info != "":
					info += "\n"
				info += "Belebt wieder"
			return info
		
		"kampf_boosts":
			var boost_stat = item_info.get("boost_stat", "")
			var boost_amount = item_info.get("boost_amount", 1)
			if boost_stat != "":
				return "Verstärkt " + boost_stat + " um " + str(boost_amount) + " Stufe(n)"
			return ""
	
	return ""

func _on_use_pressed():
	if current_item_id == "" or not inventory_manager:
		return
	
	var item_info = inventory_manager._get_item_data(current_item_id)
	var category = item_info.get("category", "")
	
	# Handle different item types
	match category:
		"fanggeraete":
			# Use directly on enemy (no target selection needed)
			item_selected.emit(current_item_id, "enemy")
			close_battle_inventory()
		
		"medizin", "kampf_boosts":
			# Need target selection
			_start_target_selection()
		
		_:
			# Unknown category - use directly
			item_selected.emit(current_item_id, "")
			close_battle_inventory()

func _start_target_selection():
	in_target_selection = true
	target_index = 0
	
	# Update UI to show target selection
	_update_target_selection_display()

func _update_target_selection_display():
	if current_team_members.size() == 0:
		return
	
	# Update description to show target selection
	var target_info = "Ziel auswählen:\n\n"
	
	for i in range(current_team_members.size()):
		var member = current_team_members[i]
		var name = member.get("name", "Unbekannt")
		var current_hp = member.get("current_hp", 100)
		var max_hp = member.get("max_hp", 100)
		var is_fainted = member.get("is_fainted", false)
		
		var marker = " > " if i == target_index else "   "
		var status = ""
		
		if is_fainted:
			status = " (K.O.)"
		elif current_hp < max_hp:
			status = " (" + str(current_hp) + "/" + str(max_hp) + " HP)"
		
		target_info += marker + name + status + "\n"
	
	target_info += "\n[↑↓]: Ziel wählen  [Enter]: Bestätigen  [ESC]: Abbrechen"
	
	item_description.text = target_info

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

func _on_close_pressed():
	close_battle_inventory()

func _input(event):
	if not visible:
		return
	
	if event.is_pressed():
		if in_target_selection:
			_handle_target_selection_input(event)
		else:
			_handle_main_input(event)

func _handle_main_input(event):
	if event.is_action("ui_cancel"):
		close_battle_inventory()
	elif event.is_action("ui_accept"):
		_on_use_pressed()
	elif event.is_action("ui_left"):
		_navigate_tabs(-1)
	elif event.is_action("ui_right"):
		_navigate_tabs(1)
	elif event.is_action("ui_up"):
		_navigate_items(-1)
	elif event.is_action("ui_down"):
		_navigate_items(1)

func _handle_target_selection_input(event):
	if event.is_action("ui_cancel"):
		# Cancel target selection
		in_target_selection = false
		_update_item_description()
	elif event.is_action("ui_accept"):
		# Confirm target selection
		if current_team_members.size() > target_index:
			var target_name = current_team_members[target_index].get("name", "")
			item_selected.emit(current_item_id, target_name)
			close_battle_inventory()
	elif event.is_action("ui_up"):
		target_index = max(0, target_index - 1)
		_update_target_selection_display()
	elif event.is_action("ui_down"):
		target_index = min(current_team_members.size() - 1, target_index + 1)
		_update_target_selection_display()

func _navigate_tabs(direction: int):
	var current_tab_index = -1
	var enabled_tabs = []
	
	# Find enabled tabs
	for i in range(tab_buttons.size()):
		if not tab_buttons[i].disabled:
			enabled_tabs.append(i)
			var category = _get_category_by_index(i)
			if category == current_category:
				current_tab_index = enabled_tabs.size() - 1
	
	if enabled_tabs.size() <= 1:
		return
	
	# Navigate to next/previous enabled tab
	var new_tab_index = (current_tab_index + direction) % enabled_tabs.size()
	if new_tab_index < 0:
		new_tab_index = enabled_tabs.size() - 1
	
	var new_category = _get_category_by_index(enabled_tabs[new_tab_index])
	_switch_category(new_category)

func _navigate_items(direction: int):
	if item_list.get_item_count() == 0:
		return
	
	var new_index = selected_item_index + direction
	new_index = clamp(new_index, 0, item_list.get_item_count() - 1)
	
	if new_index != selected_item_index:
		item_list.select(new_index)
		_on_item_selected(new_index)

func _get_category_by_index(index: int) -> String:
	match index:
		0:
			return "fanggeraete"
		1:
			return "medizin"
		2:
			return "kampf_boosts"
		_:
			return "medizin"