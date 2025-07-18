extends Node

# Game States
enum GameState {
	EXPLORING,
	DIALOGUE,
	BATTLE_MENU,
	BATTLE,
	INVENTORY,
	PAUSED
}

# Input Contexts
enum InputContext {
	EXPLORATION,
	DIALOGUE,
	MENU_NAVIGATION,
	BATTLE
}

# Singleton instance
var current_state: GameState = GameState.EXPLORING
var current_input_context: InputContext = InputContext.EXPLORATION
var previous_state: GameState

# State change callbacks
var state_change_callbacks = {}

# UI References
var dialogue_ui: Control
var battle_menu: Control
var inventory_ui: Control
var player: CharacterBody2D

# Battle menu state
var selected_battle_option = 0
var battle_options = ["KÄMPFEN", "BEUTEL", "POKÉMON", "FLUCHT"]

# Multi-stage dialogue system
var dialogue_lines: Array = []
var current_dialogue_index = 0
var dialogue_callback_func: Callable

signal state_changed(old_state: GameState, new_state: GameState)
signal input_context_changed(old_context: InputContext, new_context: InputContext)

func _ready():
	# Set up as singleton
	if not Engine.has_singleton("GameStateManager"):
		Engine.register_singleton("GameStateManager", self)
	
	# Connect to UI elements (will be set by main scene)
	call_deferred("_find_ui_elements")

func _find_ui_elements():
	# Find UI elements in the scene tree
	var main_node = get_tree().get_first_node_in_group("main")
	if main_node:
		dialogue_ui = main_node.get_node("UI/DialogueBox")
		battle_menu = main_node.get_node("UI/BattleMenu")
		player = main_node.get_node("SmallTown/Player")
		
		# Create inventory UI if it doesn't exist
		_setup_inventory_ui()
		
		print("GameStateManager initialized with UI elements")

func _setup_inventory_ui():
	# Create inventory UI if not already created
	if not inventory_ui:
		var inventory_scene = preload("res://scenes/inventory.tscn")
		inventory_ui = inventory_scene.instantiate()
		get_tree().root.add_child(inventory_ui)
		
		# Connect signals
		inventory_ui.inventory_closed.connect(_on_inventory_closed)
		
		print("GameStateManager: Created inventory UI")

func change_state(new_state: GameState):
	var old_state = current_state
	
	# Exit current state
	_exit_state(current_state)
	
	# Change state
	previous_state = current_state
	current_state = new_state
	
	# Enter new state
	_enter_state(new_state)
	
	# Emit signal
	state_changed.emit(old_state, new_state)
	
	print("State changed from ", GameState.keys()[old_state], " to ", GameState.keys()[new_state])

func _exit_state(state: GameState):
	match state:
		GameState.EXPLORING:
			_exit_exploring()
		GameState.DIALOGUE:
			_exit_dialogue()
		GameState.BATTLE_MENU:
			_exit_battle_menu()
		GameState.BATTLE:
			_exit_battle()
		GameState.INVENTORY:
			_exit_inventory()

func _enter_state(state: GameState):
	match state:
		GameState.EXPLORING:
			_enter_exploring()
		GameState.DIALOGUE:
			_enter_dialogue()
		GameState.INVENTORY:
			_enter_inventory()
		GameState.BATTLE_MENU:
			_enter_battle_menu()
		GameState.BATTLE:
			_enter_battle()

func _enter_exploring():
	current_input_context = InputContext.EXPLORATION
	if player:
		player.set_movement_enabled(true)
	input_context_changed.emit(current_input_context, InputContext.EXPLORATION)

func _exit_exploring():
	if player:
		player.set_movement_enabled(false)

func _enter_dialogue():
	current_input_context = InputContext.DIALOGUE
	if player:
		player.set_movement_enabled(false)
	input_context_changed.emit(current_input_context, InputContext.DIALOGUE)

func _exit_dialogue():
	if dialogue_ui:
		dialogue_ui.visible = false

func _enter_battle_menu():
	current_input_context = InputContext.MENU_NAVIGATION
	selected_battle_option = 0
	if battle_menu:
		battle_menu.visible = true
		_update_battle_menu_selector()
	input_context_changed.emit(current_input_context, InputContext.MENU_NAVIGATION)

func _exit_battle_menu():
	if battle_menu:
		battle_menu.visible = false

func _enter_battle():
	current_input_context = InputContext.BATTLE
	input_context_changed.emit(current_input_context, InputContext.BATTLE)

func _exit_battle():
	pass

# Input handling for different contexts
func _unhandled_input(event):
	if not event.is_pressed():
		return
		
	match current_input_context:
		InputContext.EXPLORATION:
			_handle_exploration_input(event)
		InputContext.DIALOGUE:
			_handle_dialogue_input(event)
		InputContext.MENU_NAVIGATION:
			_handle_menu_navigation_input(event)
		InputContext.BATTLE:
			_handle_battle_input(event)

func _handle_exploration_input(event):
	# Exploration input is handled by the player directly
	pass

func _handle_dialogue_input(event):
	if event.is_action_pressed("ui_accept"):
		# Progress multi-stage dialogue
		if current_state == GameState.DIALOGUE:
			if dialogue_lines.size() > 0 and current_dialogue_index < dialogue_lines.size() - 1:
				# Special handling for dramatic pause in Benedikt dialogue
				if current_dialogue_index == 2 and dialogue_lines[2].contains("Tüte, Tüte..."):
					# Add dramatic pause before moving to next line
					_show_dramatic_pause()
					return
				
				# Move to next dialogue line
				current_dialogue_index += 1
				_show_current_dialogue()
			else:
				# End dialogue - call callback or go to battle menu
				if dialogue_callback_func.is_valid():
					dialogue_callback_func.call()
				else:
					change_state(GameState.BATTLE_MENU)
	# ESC key is disabled during dialogue to prevent accidental exits

func _handle_menu_navigation_input(event):
	if event.is_action_pressed("ui_right"):
		if selected_battle_option % 2 == 0:  # Left column
			selected_battle_option += 1
			_update_battle_menu_selector()
	elif event.is_action_pressed("ui_left"):
		if selected_battle_option % 2 == 1:  # Right column
			selected_battle_option -= 1
			_update_battle_menu_selector()
	elif event.is_action_pressed("ui_down"):
		if selected_battle_option < 2:  # Top row
			selected_battle_option += 2
			_update_battle_menu_selector()
	elif event.is_action_pressed("ui_up"):
		if selected_battle_option >= 2:  # Bottom row
			selected_battle_option -= 2
			_update_battle_menu_selector()
	elif event.is_action_pressed("ui_accept"):
		# Select battle option
		_select_battle_option(selected_battle_option)
	elif event.is_action_pressed("ui_cancel"):
		# Go back to dialogue or exploration
		change_state(GameState.EXPLORING)

func _handle_battle_input(event):
	# Battle input handling will be implemented later
	pass

func _update_battle_menu_selector():
	if not battle_menu:
		return
	
	# Hide all selectors first
	for i in range(4):
		var selector = _get_selector_node(i)
		if selector:
			selector.visible = false
	
	# Show the selected one
	var current_selector = _get_selector_node(selected_battle_option)
	if current_selector:
		current_selector.visible = true

func _get_selector_node(option_index: int) -> Label:
	if not battle_menu:
		return null
		
	match option_index:
		0:
			return battle_menu.get_node("Panel/VBoxContainer/Row1/Option1/Selector1")
		1:
			return battle_menu.get_node("Panel/VBoxContainer/Row1/Option2/Selector2")
		2:
			return battle_menu.get_node("Panel/VBoxContainer/Row2/Option3/Selector3")
		3:
			return battle_menu.get_node("Panel/VBoxContainer/Row2/Option4/Selector4")
		_:
			return null

func _select_battle_option(option: int):
	var option_name = battle_options[option]
	print("Selected battle option: ", option_name)
	
	match option:
		0:  # KÄMPFEN
			change_state(GameState.BATTLE)
		1:  # BEUTEL
			print("Opening bag...")
			# Let BattleManager handle battle inventory
			var battle_manager = get_tree().current_scene.get_node_or_null("Battle")
			if battle_manager and battle_manager.has_method("_on_bag_pressed"):
				battle_manager._on_bag_pressed()
			else:
				change_state(GameState.EXPLORING)
		2:  # POKÉMON
			print("Opening Pokemon menu...")
			# Let BattleManager handle team selection
			var battle_manager = get_tree().current_scene.get_node_or_null("Battle")
			if battle_manager and battle_manager.has_method("_on_humans_pressed"):
				battle_manager._on_humans_pressed()
			else:
				change_state(GameState.EXPLORING)
		3:  # FLUCHT
			print("Running away...")
			# Let BattleManager handle escape attempts
			var battle_manager = get_tree().current_scene.get_node_or_null("Battle")
			if battle_manager and battle_manager.has_method("_on_run_pressed"):
				battle_manager._on_run_pressed()
			else:
				change_state(GameState.EXPLORING)

# Public API for other scripts
func start_dialogue(dialogue_text: String):
	if current_state != GameState.EXPLORING:
		print("Cannot start dialogue - not in exploring state")
		return
	
	# Single dialogue (backward compatibility)
	dialogue_lines = [dialogue_text]
	current_dialogue_index = 0
	dialogue_callback_func = Callable()
	
	_show_current_dialogue()
	change_state(GameState.DIALOGUE)

func start_multi_dialogue(lines: Array, callback: Callable = Callable()):
	if current_state != GameState.EXPLORING:
		print("Cannot start dialogue - not in exploring state")
		return
	
	# Multi-stage dialogue
	dialogue_lines = lines
	current_dialogue_index = 0
	dialogue_callback_func = callback
	
	_show_current_dialogue()
	change_state(GameState.DIALOGUE)

func _show_current_dialogue():
	if dialogue_ui and current_dialogue_index < dialogue_lines.size():
		dialogue_ui.get_node("Panel/Text").text = dialogue_lines[current_dialogue_index]
		dialogue_ui.get_node("Panel/Arrow").visible = true
		dialogue_ui.visible = true

func _show_dramatic_pause():
	# Show current line with hidden arrow for dramatic effect
	if dialogue_ui:
		dialogue_ui.get_node("Panel/Text").text = dialogue_lines[current_dialogue_index]
		dialogue_ui.get_node("Panel/Arrow").visible = false
		dialogue_ui.visible = true
	
	# Wait for dramatic pause, then auto-advance
	await get_tree().create_timer(1.5).timeout
	
	# Move to next line automatically
	current_dialogue_index += 1
	_show_current_dialogue()

func is_in_dialogue() -> bool:
	return current_state == GameState.DIALOGUE or current_state == GameState.BATTLE_MENU

func get_current_state() -> GameState:
	return current_state

func get_current_input_context() -> InputContext:
	return current_input_context

# Inventory system integration
func open_inventory():
	if current_state == GameState.EXPLORING:
		change_state(GameState.INVENTORY)

func _enter_inventory():
	current_input_context = InputContext.MENU_NAVIGATION
	if inventory_ui:
		inventory_ui.open_inventory(false, null)

func _exit_inventory():
	current_input_context = InputContext.EXPLORATION
	if inventory_ui:
		inventory_ui.close_inventory()

func _on_inventory_closed():
	if current_state == GameState.INVENTORY:
		change_state(GameState.EXPLORING)

# Battle transition system
func start_battle_transition():
	print("Starting battle transition...")
	# Stop overworld music (if implemented)
	
	# Start transition effect
	_play_transition_effect()

func _play_transition_effect():
	# Create spiral/wipe transition effect
	var overlay = ColorRect.new()
	overlay.color = Color.BLACK
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Add to scene tree
	var main_scene = get_tree().current_scene
	main_scene.add_child(overlay)
	
	# Create spiral wipe effect using a circular mask
	var center = Vector2(640, 360)  # Screen center
	var max_radius = 800.0  # Large enough to cover screen
	
	# Start with full black screen, then reveal the current scene
	overlay.modulate.a = 1.0
	
	# Wait a moment for dramatic effect
	await get_tree().create_timer(0.2).timeout
	
	# Quick spiral wipe effect - shrink the black overlay
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade out overlay
	tween.tween_property(overlay, "modulate:a", 0.0, 0.8)
	
	# Add rotation for spiral effect
	tween.tween_property(overlay, "rotation", PI * 2, 0.8)
	
	await tween.finished
	
	# Brief pause before scene change
	await get_tree().create_timer(0.1).timeout
	
	# Switch to battle scene
	get_tree().change_scene_to_file("res://scenes/battle.tscn")