extends CharacterBody2D

const SPEED = 300.0
var movement_enabled = true
var game_state_manager = null

func _ready():
	# Get reference to GameStateManager
	call_deferred("_get_game_state_manager")

func _get_game_state_manager():
	game_state_manager = get_node("/root/GameStateManager")
	if game_state_manager:
		# Connect to state changes
		game_state_manager.input_context_changed.connect(_on_input_context_changed)

func _physics_process(_delta):
	# Only process movement in exploration context
	if not movement_enabled:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# Check if we're in the right input context
	if game_state_manager and game_state_manager.get_current_input_context() != game_state_manager.InputContext.EXPLORATION:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# Get input direction
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		direction.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		direction.x += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		direction.y -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		direction.y += 1
	
	# Normalize diagonal movement
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func set_movement_enabled(enabled: bool):
	movement_enabled = enabled
	if not enabled:
		velocity = Vector2.ZERO

func _on_input_context_changed(old_context, new_context):
	# Update movement based on input context
	if new_context == game_state_manager.InputContext.EXPLORATION:
		set_movement_enabled(true)
	else:
		set_movement_enabled(false)
