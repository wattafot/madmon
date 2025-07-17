extends CharacterBody2D

@onready var interaction_area = $InteractionArea
@onready var label = $Label
var game_state_manager = null

var player_nearby = false
var is_interacting = false

# Human types for Menschenmon
enum HumanType {
	BENEDIKT,    # "der Mitteldicke"
	BOBO,        # "der Gemütliche" 
	FRIEDER      # "der Alkoholiker"
}

var human_type = HumanType.BENEDIKT
var human_name = "Wilder Benedikt"
var human_level = 5

func _ready():
	interaction_area.body_entered.connect(_on_player_entered)
	interaction_area.body_exited.connect(_on_player_exited)
	
	# Hide interaction indicator initially
	label.visible = false
	
	# Get reference to GameStateManager
	call_deferred("_get_game_state_manager")

func _get_game_state_manager():
	game_state_manager = get_node("/root/GameStateManager")
	if game_state_manager:
		print("GameStateManager found for wild human")
		# Connect to state changes to know when dialogue ends
		game_state_manager.state_changed.connect(_on_state_changed)

func _on_state_changed(old_state, new_state):
	# Reset interaction state when returning to exploration
	if new_state == game_state_manager.GameState.EXPLORING and is_interacting:
		is_interacting = false
		print("Encounter finished, resetting...")

func _on_player_entered(body):
	print("Body entered: ", body.name)
	if body.name == "Player":
		player_nearby = true
		label.visible = true
		print("Player can interact with ", human_name)

func _on_player_exited(body):
	print("Body exited: ", body.name)
	if body.name == "Player":
		player_nearby = false
		label.visible = false
		is_interacting = false

func _physics_process(_delta):
	# Check for interaction input when player is nearby and in exploration mode
	if player_nearby and game_state_manager and game_state_manager.get_current_state() == game_state_manager.GameState.EXPLORING:
		if Input.is_action_just_pressed("ui_accept"):
			print("Space key detected, starting encounter")
			start_encounter()

func start_encounter():
	print("start_encounter called!")
	if is_interacting or not game_state_manager:
		print("Already interacting or no game state manager, returning")
		return
		
	is_interacting = true
	print("Setting is_interacting to true")
	print("Ein wilder ", human_name, " ist erschienen!")
	print("Level: ", human_level)
	print("Typ: Gemütlich/Normal")
	
	# Use the new state management system
	var encounter_text = "Ein wilder " + human_name + " ist erschienen!"
	game_state_manager.start_dialogue(encounter_text)

