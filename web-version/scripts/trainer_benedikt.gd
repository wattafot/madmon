extends CharacterBody2D

@onready var sight_line = $SightLine
@onready var sight_collision = $SightLine/SightCollision
@onready var exclamation_mark = $ExclamationMark
@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer

var game_state_manager = null
var player_ref = null

# Trainer state
enum TrainerState {
	WAITING,
	SPOTTED_PLAYER,
	APPROACHING,
	DIALOGUE,
	BATTLE
}

var current_state = TrainerState.WAITING
var sight_direction = Vector2.RIGHT  # Default facing right
var sight_distance = 96  # 3 tiles at 32px each
var approach_speed = 150.0
var target_position = Vector2.ZERO
var has_battled = false

# Dialogue lines
var dialogue_lines = [
	"Na, sieh mal einer an! Anna lässt ihr Schoßhündchen von der Leine.",
	"Da hab ich eine kleine Nachricht für sie...",
	"Tüte, Tüte...",
	"...eine kleine Tüte!",
	"Mal sehen, ob du darauf eine Antwort hast! Los geht's!"
]

func _ready():
	# Set up sight line collision shape
	_setup_sight_line()
	
	# Connect signals
	sight_line.body_entered.connect(_on_sight_line_body_entered)
	
	# Set initial animation (idle, facing down - visible frame)
	animated_sprite.frame = 0  # Down-facing idle frame (row 1, frame 1)
	# animation_player.play("idle_right")
	
	# Get references
	call_deferred("_get_references")

func _get_references():
	game_state_manager = get_node("/root/GameStateManager")
	player_ref = get_node("/root/Main/SmallTown/Player")
	
	if game_state_manager:
		print("Trainer Benedikt: GameStateManager found")
	if player_ref:
		print("Trainer Benedikt: Player reference found")
	
	print("Trainer Benedikt: Position = ", global_position)
	print("Trainer Benedikt: Frame = ", animated_sprite.frame)
	print("Trainer Benedikt: Visible = ", animated_sprite.visible)

func _setup_sight_line():
	# Create rectangular collision shape for sight line
	var shape = RectangleShape2D.new()
	shape.size = Vector2(sight_distance, 32)  # 3 tiles wide, 1 tile high
	sight_collision.shape = shape
	
	# Position the sight line in front of the trainer
	sight_collision.position = Vector2(sight_distance / 2, 0)
	
	print("Trainer Benedikt: Sight line set up - distance: ", sight_distance, " direction: ", sight_direction)

func _physics_process(_delta):
	match current_state:
		TrainerState.APPROACHING:
			_handle_approach(_delta)

func _handle_approach(_delta):
	if not player_ref:
		return
		
	var direction = (target_position - global_position).normalized()
	var distance = global_position.distance_to(target_position)
	
	if distance > 5.0:  # Still approaching
		velocity = direction * approach_speed
		move_and_slide()
		
		# Play walking animation
		if animation_player.current_animation != "walk_right":
			animation_player.play("walk_right")
	else:
		# Arrived at player
		velocity = Vector2.ZERO
		current_state = TrainerState.DIALOGUE
		
		# Return to idle animation
		animation_player.play("idle_right")
		
		_start_dialogue()

func _on_sight_line_body_entered(body):
	if body.name == "Player" and current_state == TrainerState.WAITING and not has_battled:
		print("Trainer Benedikt: Player spotted!")
		_spot_player()

func _spot_player():
	if not player_ref:
		return
		
	# Change state
	current_state = TrainerState.SPOTTED_PLAYER
	
	# Show exclamation mark
	exclamation_mark.visible = true
	
	# Block player movement
	if game_state_manager:
		game_state_manager.change_state(game_state_manager.GameState.DIALOGUE)
	
	# Calculate approach target (stop 1 tile in front of player)
	var player_pos = player_ref.global_position
	var approach_offset = Vector2(-32, 0)  # 1 tile to the left of player
	target_position = player_pos + approach_offset
	
	# Start approaching after a brief delay
	await get_tree().create_timer(0.5).timeout
	exclamation_mark.visible = false
	current_state = TrainerState.APPROACHING
	
	print("Trainer Benedikt: Starting approach to position: ", target_position)

func _start_dialogue():
	if not game_state_manager:
		return
		
	print("Trainer Benedikt: Starting dialogue sequence")
	
	# Start dialogue sequence
	for line in dialogue_lines:
		game_state_manager.start_dialogue(line)
		
		# Wait for dialogue to complete
		await game_state_manager.state_changed
		
		# Add pause for "Tüte, Tüte..." line
		if line == "Tüte, Tüte...":
			await get_tree().create_timer(1.0).timeout
	
	# After dialogue, transition to battle
	_start_battle()

func _start_battle():
	print("Trainer Benedikt: Starting battle!")
	has_battled = true
	current_state = TrainerState.BATTLE
	
	# TODO: Implement battle transition
	# For now, just return to exploration
	if game_state_manager:
		game_state_manager.change_state(game_state_manager.GameState.EXPLORING)

func set_facing_direction(direction: Vector2):
	sight_direction = direction.normalized()
	_setup_sight_line()
	
	# Update sight line position based on direction
	if sight_direction == Vector2.RIGHT:
		sight_collision.position = Vector2(sight_distance / 2, 0)
	elif sight_direction == Vector2.LEFT:
		sight_collision.position = Vector2(-sight_distance / 2, 0)
	elif sight_direction == Vector2.UP:
		sight_collision.position = Vector2(0, -sight_distance / 2)
		sight_collision.shape.size = Vector2(32, sight_distance)
	elif sight_direction == Vector2.DOWN:
		sight_collision.position = Vector2(0, sight_distance / 2)
		sight_collision.shape.size = Vector2(32, sight_distance)