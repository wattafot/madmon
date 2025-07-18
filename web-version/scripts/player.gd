extends CharacterBody2D

const SPEED = 300.0
var movement_enabled = true
var game_state_manager = null
var current_direction = "down"
var is_moving = false
var walk_frame = 0
var walk_timer = 0.0
var walk_frame_duration = 0.2

@onready var sprite = $Sprite2D

# Sprite regions for each direction and frame
var sprite_regions = {
	"down": [Rect2(0, 0, 32, 48), Rect2(32, 0, 32, 48), Rect2(64, 0, 32, 48), Rect2(96, 0, 32, 48)],
	"left": [Rect2(0, 48, 32, 48), Rect2(32, 48, 32, 48), Rect2(64, 48, 32, 48), Rect2(96, 48, 32, 48)],
	"right": [Rect2(0, 96, 32, 48), Rect2(32, 96, 32, 48), Rect2(64, 96, 32, 48), Rect2(96, 96, 32, 48)],
	"up": [Rect2(0, 144, 32, 48), Rect2(32, 144, 32, 48), Rect2(64, 144, 32, 48), Rect2(96, 144, 32, 48)]
}

func _ready():
	# Get reference to GameStateManager
	call_deferred("_get_game_state_manager")

func _get_game_state_manager():
	game_state_manager = get_node("/root/GameStateManager")
	if game_state_manager:
		# Connect to state changes
		game_state_manager.input_context_changed.connect(_on_input_context_changed)

func _input(event):
	# Handle inventory access
	if event.is_pressed() and event.is_action("ui_cancel"):  # ESC key
		if game_state_manager and game_state_manager.get_current_state() == game_state_manager.GameState.EXPLORING:
			game_state_manager.open_inventory()

func _physics_process(delta):
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
		current_direction = "left"
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		direction.x += 1
		current_direction = "right"
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		direction.y -= 1
		current_direction = "up"
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		direction.y += 1
		current_direction = "down"
	
	# Handle animation
	if direction != Vector2.ZERO:
		# Moving - animate walk cycle
		if not is_moving:
			is_moving = true
			walk_frame = 0
			walk_timer = 0.0
		
		# Update walk animation
		walk_timer += delta
		if walk_timer >= walk_frame_duration:
			walk_timer = 0.0
			walk_frame = (walk_frame + 1) % 4
		
		# Update sprite region
		sprite.region_rect = sprite_regions[current_direction][walk_frame]
		
		# Normalize diagonal movement
		direction = direction.normalized()
		velocity = direction * SPEED
	else:
		# Not moving - show idle frame
		if is_moving:
			is_moving = false
			sprite.region_rect = sprite_regions[current_direction][0]  # First frame is idle
		velocity = Vector2.ZERO
	
	move_and_slide()

func set_movement_enabled(enabled: bool):
	movement_enabled = enabled
	if not enabled:
		velocity = Vector2.ZERO
		is_moving = false
		sprite.region_rect = sprite_regions[current_direction][0]  # Set to idle frame

func _on_input_context_changed(old_context, new_context):
	# Update movement based on input context
	if new_context == game_state_manager.InputContext.EXPLORATION:
		set_movement_enabled(true)
	else:
		set_movement_enabled(false)
