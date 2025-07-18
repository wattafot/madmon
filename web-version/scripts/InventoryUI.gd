extends Control

# BEUTEL (Inventory) UI System
# Provides Pokemon-style tabbed inventory interface

signal inventory_closed
signal item_selected(item_id: String)
signal item_used(item_id: String, target: Node)

# UI Components
@onready var item_list = $Background/MainContainer/ContentContainer/ItemListPanel/ItemList
@onready var item_description = $Background/MainContainer/ContentContainer/DetailsPanel/ItemDescription
@onready var item_icon = $Background/MainContainer/ContentContainer/DetailsPanel/ItemIcon
@onready var money_label = $Background/MainContainer/HeaderContainer/MoneyLabel
@onready var use_button = $Background/MainContainer/ButtonContainer/UseButton
@onready var close_button = $Background/MainContainer/ButtonContainer/CloseButton

# Tab buttons
@onready var tab_fanggeraete = $Background/MainContainer/ContentContainer/CategoryPanel/CategoryButtons/TabFanggeraete
@onready var tab_medizin = $Background/MainContainer/ContentContainer/CategoryPanel/CategoryButtons/TabMedizin
@onready var tab_kampf_boosts = $Background/MainContainer/ContentContainer/CategoryPanel/CategoryButtons/TabKampfBoosts
@onready var tab_basis_items = $Background/MainContainer/ContentContainer/CategoryPanel/CategoryButtons/TabBasisItems

# Core systems
var inventory_manager: Node = null
var audio_manager: Node = null
var game_state_manager: Node = null

# UI State
var current_category: int = 0
var current_selection: int = 0
var current_items: Array = []
var in_battle: bool = false
var battle_target: Node = null

# Tab styling
var tab_colors = {
	"active": Color("#1976D2"),
	"inactive": Color("#424242"),
	"hover": Color("#1E88E5")
}

func _ready():
	# Get core managers
	inventory_manager = get_node("/root/InventoryManager")
	audio_manager = get_node_or_null("/root/AudioManager")
	game_state_manager = get_node_or_null("/root/GameStateManager")
	
	# Setup UI
	_setup_ui()
	_setup_tabs()
	_setup_input_handling()
	
	# Hide initially
	visible = false
	
	print("InventoryUI: Ready")

func _setup_ui():
	# Create main background with Pokemon-style design
	var background = StyleBoxFlat.new()
	background.bg_color = Color("#F5F5F5")  # Light gray background
	background.border_width_left = 3
	background.border_width_right = 3  
	background.border_width_top = 3
	background.border_width_bottom = 3
	background.border_color = Color("#1976D2")  # Blue border
	background.corner_radius_top_left = 12
	background.corner_radius_top_right = 12
	background.corner_radius_bottom_left = 12
	background.corner_radius_bottom_right = 12
	
	# Apply to main panel
	var main_panel = get_node("Background")
	if main_panel:
		main_panel.add_theme_stylebox_override("panel", background)
	
	# Setup title
	var title_label = get_node("Background/MainContainer/HeaderContainer/Title")
	if title_label:
		title_label.add_theme_color_override("font_color", Color("#1976D2"))
		title_label.add_theme_font_size_override("font_size", 24)
	
	# Setup money label
	if money_label:
		money_label.add_theme_color_override("font_color", Color("#1976D2"))
		money_label.add_theme_font_size_override("font_size", 16)
	
	# Setup item list with better styling
	if item_list:
		item_list.add_theme_color_override("font_color", Color.BLACK)
		item_list.add_theme_color_override("font_color_selected", Color.WHITE)
		item_list.add_theme_color_override("font_color_hovered", Color("#1976D2"))
		
		var list_style = StyleBoxFlat.new()
		list_style.bg_color = Color.WHITE
		list_style.border_width_left = 2
		list_style.border_width_right = 2
		list_style.border_width_top = 2
		list_style.border_width_bottom = 2
		list_style.border_color = Color("#1976D2")
		list_style.corner_radius_top_left = 8
		list_style.corner_radius_top_right = 8
		list_style.corner_radius_bottom_left = 8
		list_style.corner_radius_bottom_right = 8
		item_list.add_theme_stylebox_override("panel", list_style)
		
		# Selection style
		var selection_style = StyleBoxFlat.new()
		selection_style.bg_color = Color("#1976D2")
		selection_style.corner_radius_top_left = 4
		selection_style.corner_radius_top_right = 4
		selection_style.corner_radius_bottom_left = 4
		selection_style.corner_radius_bottom_right = 4
		item_list.add_theme_stylebox_override("selected", selection_style)
	
	# Setup description panel
	if item_description:
		item_description.add_theme_color_override("font_color", Color.BLACK)
		item_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		var desc_style = StyleBoxFlat.new()
		desc_style.bg_color = Color.WHITE
		desc_style.border_width_left = 2
		desc_style.border_width_right = 2
		desc_style.border_width_top = 2
		desc_style.border_width_bottom = 2
		desc_style.border_color = Color("#1976D2")
		desc_style.corner_radius_top_left = 8
		desc_style.corner_radius_top_right = 8
		desc_style.corner_radius_bottom_left = 8
		desc_style.corner_radius_bottom_right = 8
		item_description.add_theme_stylebox_override("normal", desc_style)
	
	# Setup buttons
	_setup_button_styling()

func _setup_button_styling():
	var buttons = [use_button, close_button]
	
	for button in buttons:
		if button:
			button.add_theme_color_override("font_color", Color.WHITE)
			button.add_theme_color_override("font_color_hover", Color.WHITE)
			button.add_theme_color_override("font_color_pressed", Color.WHITE)
			button.add_theme_font_size_override("font_size", 16)
			
			var button_style = StyleBoxFlat.new()
			button_style.bg_color = Color("#1976D2")
			button_style.border_width_left = 2
			button_style.border_width_right = 2
			button_style.border_width_top = 2
			button_style.border_width_bottom = 2
			button_style.border_color = Color("#0D47A1")
			button_style.corner_radius_top_left = 8
			button_style.corner_radius_top_right = 8
			button_style.corner_radius_bottom_left = 8
			button_style.corner_radius_bottom_right = 8
			
			var button_hover = button_style.duplicate()
			button_hover.bg_color = Color("#1E88E5")
			
			var button_pressed = button_style.duplicate()
			button_pressed.bg_color = Color("#0D47A1")
			
			button.add_theme_stylebox_override("normal", button_style)
			button.add_theme_stylebox_override("hover", button_hover)
			button.add_theme_stylebox_override("pressed", button_pressed)

func _setup_tabs():
	var tabs = [tab_fanggeraete, tab_medizin, tab_kampf_boosts, tab_basis_items]
	
	for i in range(tabs.size()):
		var tab = tabs[i]
		if tab:
			tab.add_theme_color_override("font_color", Color.WHITE)
			tab.add_theme_color_override("font_color_hover", Color.WHITE)
			tab.add_theme_color_override("font_color_pressed", Color.WHITE)
			tab.add_theme_font_size_override("font_size", 14)
			
			# Connect signals
			tab.pressed.connect(_on_tab_selected.bind(i))
			
			_style_tab(tab, i == current_category)

func _style_tab(tab: Button, is_active: bool):
	var tab_style = StyleBoxFlat.new()
	tab_style.bg_color = tab_colors["active"] if is_active else tab_colors["inactive"]
	tab_style.border_width_left = 2
	tab_style.border_width_right = 2
	tab_style.border_width_top = 2
	tab_style.border_width_bottom = 2
	tab_style.border_color = Color("#0D47A1")
	tab_style.corner_radius_top_left = 8
	tab_style.corner_radius_top_right = 8
	tab_style.corner_radius_bottom_left = 8
	tab_style.corner_radius_bottom_right = 8
	
	var tab_hover = tab_style.duplicate()
	tab_hover.bg_color = tab_colors["hover"]
	
	var tab_pressed = tab_style.duplicate()
	tab_pressed.bg_color = tab_colors["active"]
	
	tab.add_theme_stylebox_override("normal", tab_style)
	tab.add_theme_stylebox_override("hover", tab_hover)
	tab.add_theme_stylebox_override("pressed", tab_pressed)

func _setup_input_handling():
	# Connect signals
	if use_button:
		use_button.pressed.connect(_on_use_pressed)
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	
	if item_list:
		item_list.item_selected.connect(_on_item_selected)

func _input(event):
	if not visible:
		return
		
	if event.is_pressed():
		if event.is_action("ui_cancel"):
			_close_inventory()
		elif event.is_action("ui_accept"):
			_use_current_item()
		elif event.is_action("ui_left"):
			_navigate_tabs(-1)
		elif event.is_action("ui_right"):
			_navigate_tabs(1)
		elif event.is_action("ui_up"):
			_navigate_items(-1)
		elif event.is_action("ui_down"):
			_navigate_items(1)

func _navigate_tabs(direction: int):
	var new_category = current_category + direction
	new_category = clamp(new_category, 0, 3)
	
	if new_category != current_category:
		_switch_category(new_category)
		if audio_manager:
			audio_manager.play_ui_select()

func _navigate_items(direction: int):
	if current_items.size() == 0:
		return
	
	var new_selection = current_selection + direction
	new_selection = clamp(new_selection, 0, current_items.size() - 1)
	
	if new_selection != current_selection:
		current_selection = new_selection
		item_list.select(current_selection)
		_update_item_display()
		if audio_manager:
			audio_manager.play_ui_select()

# Public API
func open_inventory(battle_mode: bool = false, target: Node = null):
	in_battle = battle_mode
	battle_target = target
	
	_refresh_inventory()
	
	# In battle mode, start with catching items, otherwise start with medicine
	_switch_category(0 if battle_mode else 1)  
	
	visible = true
	
	if audio_manager:
		audio_manager.play_ui_confirm()
	
	print("InventoryUI: Opened (battle mode: ", battle_mode, ")")

func close_inventory():
	_close_inventory()

func _close_inventory():
	visible = false
	inventory_closed.emit()
	
	if audio_manager:
		audio_manager.play_ui_cancel()

func _refresh_inventory():
	# Update money display
	if money_label and inventory_manager:
		money_label.text = "Geld: " + str(inventory_manager.get_money()) + " €"

func _switch_category(category: int):
	current_category = category
	current_selection = 0
	
	# Update tab styling
	var tabs = [tab_fanggeraete, tab_medizin, tab_kampf_boosts, tab_basis_items]
	for i in range(tabs.size()):
		if tabs[i]:
			_style_tab(tabs[i], i == current_category)
	
	# Load category items
	_load_category_items()
	
	# Update item display
	_update_item_display()

func _load_category_items():
	current_items.clear()
	
	if not inventory_manager:
		return
	
	var category_items = inventory_manager.get_inventory_by_category(current_category)
	
	# Sort items by name
	var sorted_items = category_items.keys()
	sorted_items.sort_custom(func(a, b): return inventory_manager.get_item_display_name(a) < inventory_manager.get_item_display_name(b))
	
	# Populate item list
	item_list.clear()
	for item_id in sorted_items:
		var item_data = category_items[item_id]
		var display_name = inventory_manager.get_item_display_name(item_id)
		var quantity = item_data.quantity
		
		# Format item display Pokemon-style with proper spacing
		var padded_name = display_name
		while padded_name.length() < 20:
			padded_name += " "
		var list_text = padded_name + "x" + str(quantity)
		item_list.add_item(list_text)
		current_items.append(item_id)
	
	# Select first item if available
	if current_items.size() > 0:
		item_list.select(0)
		current_selection = 0

func _update_item_display():
	if current_items.size() == 0 or current_selection >= current_items.size():
		_clear_item_display()
		return
	
	var item_id = current_items[current_selection]
	
	# Update description
	if item_description:
		item_description.text = inventory_manager.get_item_description(item_id)
	
	# Update use button
	if use_button:
		var item_data = inventory_manager._get_item_data(item_id)
		var is_key_item = item_data.get("key_item", false)
		
		if in_battle:
			# In battle, only show usable items
			var category = item_data.get("category", "")
			use_button.visible = category in ["fanggeraete", "medizin", "kampf_boosts"]
			use_button.text = "Benutzen"
		else:
			# In overworld, show appropriate text
			use_button.visible = true
			if is_key_item:
				use_button.text = "Verwenden"
			else:
				use_button.text = "Benutzen"

func _clear_item_display():
	if item_description:
		item_description.text = "Keine Items in dieser Kategorie."
	
	if use_button:
		use_button.visible = false

# Signal handlers
func _on_tab_selected(tab_index: int):
	_switch_category(tab_index)
	if audio_manager:
		audio_manager.play_ui_select()

func _on_item_selected(index: int):
	current_selection = index
	_update_item_display()
	if audio_manager:
		audio_manager.play_ui_select()

func _on_use_pressed():
	_use_current_item()

func _on_close_pressed():
	_close_inventory()

func _use_current_item():
	if current_items.size() == 0 or current_selection >= current_items.size():
		return
	
	var item_id = current_items[current_selection]
	
	if not inventory_manager:
		return
	
	var item_data = inventory_manager._get_item_data(item_id)
	var category = item_data.get("category", "")
	
	# Handle different item types
	match category:
		"fanggeraete":
			if in_battle:
				# Use catching item in battle
				item_selected.emit(item_id)
				_close_inventory()
			else:
				# Can't use catching items outside battle
				if audio_manager:
					audio_manager.play_ui_error()
		
		"medizin":
			if in_battle and battle_target:
				# Use on battle target
				inventory_manager.use_item(item_id, battle_target)
				_refresh_after_use()
			else:
				# Show party selection (TODO: implement party selection)
				print("InventoryUI: Need to implement party selection")
		
		"kampf_boosts":
			if in_battle and battle_target:
				# Use boost on battle target
				inventory_manager.use_item(item_id, battle_target)
				_refresh_after_use()
			else:
				# Show party selection (TODO: implement party selection)
				print("InventoryUI: Need to implement party selection")
		
		"basis_items":
			# Use key item or basic item
			inventory_manager.use_item(item_id, battle_target)
			_refresh_after_use()
	
	if audio_manager:
		audio_manager.play_ui_confirm()

func _refresh_after_use():
	# Refresh the inventory display
	_refresh_inventory()
	_load_category_items()
	
	# Adjust selection if needed
	if current_selection >= current_items.size():
		current_selection = max(0, current_items.size() - 1)
	
	if current_items.size() > 0:
		item_list.select(current_selection)
	
	_update_item_display()

# Category name getters
func get_category_name(category: int) -> String:
	match category:
		0: return "Fanggeräte"
		1: return "Medizin"
		2: return "Kampf-Boosts"
		3: return "Basis-Items"
	return "Unbekannt"