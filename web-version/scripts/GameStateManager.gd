extends Node

# Game States
enum GameState {
	EXPLORING,
	DIALOGUE,
	BATTLE_MENU,
	BATTLE,
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
var player: CharacterBody2D

# Battle menu state
var selected_battle_option = 0
var battle_options = ["KÄMPFEN", "BEUTEL", "POKÉMON", "FLUCHT"]

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
		
		print("GameStateManager initialized with UI elements")

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

func _enter_state(state: GameState):
	match state:
		GameState.EXPLORING:
			_enter_exploring()
		GameState.DIALOGUE:
			_enter_dialogue()
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
		# Progress dialogue or transition to battle menu
		if current_state == GameState.DIALOGUE:
			change_state(GameState.BATTLE_MENU)
	elif event.is_action_pressed("ui_cancel"):
		# Cancel dialogue and return to exploration
		change_state(GameState.EXPLORING)

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
			change_state(GameState.EXPLORING)
		2:  # POKÉMON
			print("Opening Pokemon menu...")
			change_state(GameState.EXPLORING)
		3:  # FLUCHT
			print("Running away...")
			change_state(GameState.EXPLORING)

# Public API for other scripts
func start_dialogue(dialogue_text: String):
	if current_state != GameState.EXPLORING:
		print("Cannot start dialogue - not in exploring state")
		return
	
	if dialogue_ui:
		dialogue_ui.get_node("Panel/Text").text = dialogue_text
		dialogue_ui.get_node("Panel/Arrow").visible = true
		dialogue_ui.visible = true
	
	change_state(GameState.DIALOGUE)

func is_in_dialogue() -> bool:
	return current_state == GameState.DIALOGUE or current_state == GameState.BATTLE_MENU

func get_current_state() -> GameState:
	return current_state

func get_current_input_context() -> InputContext:
	return current_input_context