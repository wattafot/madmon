class_name ItemDisplayComponent
extends BaseUIComponent

# Reusable component for displaying inventory items
# Provides consistent styling and behavior for item UI elements

# =============================================================================
# SIGNALS
# =============================================================================

signal item_selected(item_id: String)
signal item_activated(item_id: String)
signal item_hovered(item_id: String)

# =============================================================================
# PROPERTIES
# =============================================================================

@export var item_id: String = ""
@export var show_quantity: bool = true
@export var show_icon: bool = true
@export var show_name: bool = true
@export var show_description: bool = false
@export var enable_interactions: bool = true
@export var compact_mode: bool = false

# =============================================================================
# UI NODES
# =============================================================================

@onready var container: HBoxContainer
@onready var icon: TextureRect
@onready var info_container: VBoxContainer
@onready var name_label: Label
@onready var quantity_label: Label
@onready var description_label: Label
@onready var background: Panel
@onready var button: Button

# =============================================================================
# PRIVATE VARIABLES
# =============================================================================

var _item_data: Dictionary = {}
var _quantity: int = 0
var _is_selected: bool = false
var _is_hovered: bool = false

# =============================================================================
# INITIALIZATION
# =============================================================================

func _initialize():
	"""Initialize the item display component."""
	_create_ui_structure()
	_setup_interactions()

func _create_ui_structure():
	"""Create the UI structure programmatically."""
	# Create background panel
	background = Panel.new()
	background.name = "Background"
	add_child(background)
	
	# Create interactive button
	button = Button.new()
	button.name = "InteractionButton"
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	add_child(button)
	
	# Create main container
	container = HBoxContainer.new()
	container.name = "Container"
	add_child(container)
	
	# Create icon
	icon = TextureRect.new()
	icon.name = "Icon"
	icon.custom_minimum_size = Vector2(32, 32)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	container.add_child(icon)
	
	# Create info container
	info_container = VBoxContainer.new()
	info_container.name = "InfoContainer"
	info_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(info_container)
	
	# Create name label
	name_label = Label.new()
	name_label.name = "NameLabel"
	name_label.add_theme_font_size_override("font_size", 12)
	info_container.add_child(name_label)
	
	# Create quantity label
	quantity_label = Label.new()
	quantity_label.name = "QuantityLabel"
	quantity_label.add_theme_font_size_override("font_size", 10)
	quantity_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	info_container.add_child(quantity_label)
	
	# Create description label
	description_label = Label.new()
	description_label.name = "DescriptionLabel"
	description_label.add_theme_font_size_override("font_size", 10)
	description_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_container.add_child(description_label)
	
	# Set initial visibility
	_update_visibility()

func _setup_interactions():
	"""Setup interaction events."""
	if enable_interactions and button:
		button.pressed.connect(_on_button_pressed)
		button.mouse_entered.connect(_on_mouse_entered)
		button.mouse_exited.connect(_on_mouse_exited)

func _update_visibility():
	"""Update visibility of UI elements based on settings."""
	if icon:
		icon.visible = show_icon
	
	if name_label:
		name_label.visible = show_name
	
	if quantity_label:
		quantity_label.visible = show_quantity
	
	if description_label:
		description_label.visible = show_description
	
	# Adjust layout for compact mode
	if compact_mode:
		if icon:
			icon.custom_minimum_size = Vector2(24, 24)
		if name_label:
			name_label.add_theme_font_size_override("font_size", 10)
		if container:
			container.add_theme_constant_override("separation", 4)

# =============================================================================
# ITEM DATA MANAGEMENT
# =============================================================================

func set_item_data(new_item_id: String, quantity: int = 1):
	"""Set the item data for this component."""
	item_id = new_item_id
	_quantity = quantity
	
	# Get item data from inventory manager
	var inventory_manager = ServiceLocator.get_service_safe("InventoryManager")
	if inventory_manager:
		_item_data = inventory_manager._get_item_data(item_id)
		if _item_data.is_empty():
			ErrorHandler.log_warning("No item data found for: %s" % item_id)
			_item_data = _get_placeholder_data()
	else:
		_item_data = _get_placeholder_data()
	
	# Update display
	_update_display()

func _get_placeholder_data() -> Dictionary:
	"""Get placeholder data for missing items."""
	return {
		"name": "Unknown Item",
		"description": "Item data not found",
		"category": "unknown",
		"icon": ""
	}

func _update_display():
	"""Update the visual display with current item data."""
	if not _item_data:
		return
	
	# Update name
	if name_label:
		name_label.text = _item_data.get("name", "Unknown")
	
	# Update quantity
	if quantity_label:
		if _quantity > 1:
			quantity_label.text = "x%d" % _quantity
		else:
			quantity_label.text = ""
	
	# Update description
	if description_label:
		description_label.text = _item_data.get("description", "")
	
	# Update icon
	if icon:
		var icon_path = _item_data.get("icon", "")
		if icon_path != "":
			var texture = ErrorHandler.try_call(func(): return load(icon_path))
			if texture:
				icon.texture = texture
			else:
				icon.texture = _get_placeholder_icon()
		else:
			icon.texture = _get_placeholder_icon()
	
	# Apply category-specific styling
	_apply_category_styling()

func _get_placeholder_icon() -> Texture2D:
	"""Get placeholder icon for missing textures."""
	# Create a simple colored rectangle as placeholder
	var image = Image.create(32, 32, false, Image.FORMAT_RGB8)
	image.fill(Color(0.5, 0.5, 0.5))
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	return texture

func _apply_category_styling():
	"""Apply styling based on item category."""
	if not background:
		return
	
	var category = _item_data.get("category", "unknown")
	var style = StyleBoxFlat.new()
	
	match category:
		"medizin":
			style.bg_color = Color(0.2, 0.8, 0.2, 0.3)
			style.border_color = Color(0.2, 0.8, 0.2)
		"fanggeraete":
			style.bg_color = Color(0.8, 0.2, 0.2, 0.3)
			style.border_color = Color(0.8, 0.2, 0.2)
		"sonstiges":
			style.bg_color = Color(0.8, 0.8, 0.2, 0.3)
			style.border_color = Color(0.8, 0.8, 0.2)
		_:
			style.bg_color = Color(0.5, 0.5, 0.5, 0.3)
			style.border_color = Color(0.5, 0.5, 0.5)
	
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	
	background.add_theme_stylebox_override("panel", style)

# =============================================================================
# INTERACTION HANDLING
# =============================================================================

func _on_button_pressed():
	"""Handle button press."""
	set_selected(true)
	item_selected.emit(item_id)
	
	# Double-click detection for activation
	var current_time = Time.get_time_dict_from_system()
	if _is_double_click(current_time):
		item_activated.emit(item_id)

func _on_mouse_entered():
	"""Handle mouse hover."""
	if not _is_hovered:
		_is_hovered = true
		item_hovered.emit(item_id)
		_update_hover_state()

func _on_mouse_exited():
	"""Handle mouse exit."""
	if _is_hovered:
		_is_hovered = false
		_update_hover_state()

var _last_click_time: Dictionary = {}

func _is_double_click(current_time: Dictionary) -> bool:
	"""Check if this is a double-click."""
	var time_diff = (current_time.hour * 3600 + current_time.minute * 60 + current_time.second) - \
					(_last_click_time.get("hour", 0) * 3600 + _last_click_time.get("minute", 0) * 60 + _last_click_time.get("second", 0))
	
	_last_click_time = current_time
	return time_diff < 1  # 1 second threshold

func _update_hover_state():
	"""Update visual state for hover."""
	if not background:
		return
	
	var style = background.get_theme_stylebox("panel")
	if style is StyleBoxFlat:
		if _is_hovered:
			style.bg_color = style.bg_color.lightened(0.1)
		else:
			_apply_category_styling()

# =============================================================================
# SELECTION MANAGEMENT
# =============================================================================

func set_selected(selected: bool):
	"""Set selection state."""
	if _is_selected != selected:
		_is_selected = selected
		_update_selection_state()

func is_selected() -> bool:
	"""Check if item is selected."""
	return _is_selected

func _update_selection_state():
	"""Update visual state for selection."""
	if not background:
		return
	
	if _is_selected:
		animate_highlight()
		# Add selection border
		var style = background.get_theme_stylebox("panel")
		if style is StyleBoxFlat:
			style.border_color = Color.WHITE
			style.border_width_left = 3
			style.border_width_right = 3
			style.border_width_top = 3
			style.border_width_bottom = 3
	else:
		_apply_category_styling()

# =============================================================================
# VIRTUAL METHODS OVERRIDE
# =============================================================================

func configure(config: Dictionary):
	"""Configure the component with settings."""
	if config.has("show_quantity"):
		show_quantity = config.show_quantity
	
	if config.has("show_icon"):
		show_icon = config.show_icon
	
	if config.has("show_name"):
		show_name = config.show_name
	
	if config.has("show_description"):
		show_description = config.show_description
	
	if config.has("compact_mode"):
		compact_mode = config.compact_mode
	
	if config.has("enable_interactions"):
		enable_interactions = config.enable_interactions
	
	_update_visibility()

func refresh():
	"""Refresh the component display."""
	_update_display()

func reset():
	"""Reset the component to initial state."""
	set_selected(false)
	_is_hovered = false
	_update_hover_state()

func serialize() -> Dictionary:
	"""Serialize component state."""
	var data = super.serialize()
	data.merge({
		"item_id": item_id,
		"quantity": _quantity,
		"is_selected": _is_selected
	})
	return data

func deserialize(data: Dictionary):
	"""Deserialize component state."""
	super.deserialize(data)
	
	if data.has("item_id") and data.has("quantity"):
		set_item_data(data.item_id, data.quantity)
	
	if data.has("is_selected"):
		set_selected(data.is_selected)

# =============================================================================
# UTILITY METHODS
# =============================================================================

func get_item_info() -> Dictionary:
	"""Get complete item information."""
	return {
		"item_id": item_id,
		"item_data": _item_data,
		"quantity": _quantity,
		"is_selected": _is_selected,
		"is_hovered": _is_hovered
	}

func update_quantity(new_quantity: int):
	"""Update item quantity display."""
	_quantity = new_quantity
	if quantity_label:
		if _quantity > 1:
			quantity_label.text = "x%d" % _quantity
		else:
			quantity_label.text = ""

func set_interactive(interactive: bool):
	"""Enable or disable interactions."""
	enable_interactions = interactive
	if button:
		button.disabled = not interactive
		button.mouse_filter = Control.MOUSE_FILTER_PASS if interactive else Control.MOUSE_FILTER_IGNORE