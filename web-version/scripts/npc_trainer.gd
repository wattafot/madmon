extends CharacterBody2D

@onready var detection_area = $DetectionArea
@onready var exclamation_label = $ExclamationLabel
@onready var sprite = $Sprite2D

var player_detected = false
var game_state_manager = null
var player_ref = null
var approaching = false
var approach_speed = 90.0
var current_direction = "down"
var walk_frame = 0
var walk_timer = 0.0
var walk_frame_duration = 0.2

# Sprite regions for each direction and frame
var sprite_regions = {
	"down": [Rect2(0, 0, 32, 48), Rect2(32, 0, 32, 48), Rect2(64, 0, 32, 48), Rect2(96, 0, 32, 48)],
	"left": [Rect2(0, 48, 32, 48), Rect2(32, 48, 32, 48), Rect2(64, 48, 32, 48), Rect2(96, 48, 32, 48)],
	"right": [Rect2(0, 96, 32, 48), Rect2(32, 96, 32, 48), Rect2(64, 96, 32, 48), Rect2(96, 96, 32, 48)],
	"up": [Rect2(0, 144, 32, 48), Rect2(32, 144, 32, 48), Rect2(64, 144, 32, 48), Rect2(96, 144, 32, 48)]
}

func _ready():
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	
	# Get game state manager
	game_state_manager = get_node("/root/GameStateManager")
	
	print("Benedikt der Mitteldicke: Initialized at position: ", global_position)
	print("Benedikt der Mitteldicke: Sprite visible: ", $Sprite2D.visible)

func _physics_process(delta):
	if approaching and player_ref:
		var direction = (player_ref.global_position - global_position).normalized()
		var distance = global_position.distance_to(player_ref.global_position)
		
		if distance > 40:  # Stop when close enough
			# Update direction based on movement
			if abs(direction.x) > abs(direction.y):
				if direction.x > 0:
					current_direction = "right"
				else:
					current_direction = "left"
			else:
				if direction.y > 0:
					current_direction = "down"
				else:
					current_direction = "up"
			
			# Update walk animation
			walk_timer += delta
			if walk_timer >= walk_frame_duration:
				walk_timer = 0.0
				walk_frame = (walk_frame + 1) % 4
			
			# Update sprite region
			sprite.region_rect = sprite_regions[current_direction][walk_frame]
			
			velocity = direction * approach_speed
			move_and_slide()
		else:
			# Close enough, stop and start dialogue
			velocity = Vector2.ZERO
			approaching = false
			# Set to idle frame
			sprite.region_rect = sprite_regions[current_direction][0]
			if game_state_manager:
				_start_benedikt_dialogue()

func _on_detection_area_body_entered(body):
	if body.name == "Player" and not player_detected:
		player_detected = true
		player_ref = body
		print("Benedikt der Mitteldicke: Player detected!")
		
		# Disable player movement
		player_ref.set_movement_enabled(false)
		
		# Show exclamation mark
		exclamation_label.visible = true
		
		# Start approach after delay
		await get_tree().create_timer(0.5).timeout
		exclamation_label.visible = false
		approaching = true
		walk_frame = 0
		walk_timer = 0.0

func _start_benedikt_dialogue():
	# Die 5-stufige Benedikt-Sequenz
	var dialogue_lines = [
		"BENEDIKT: Was bist du denn für ein komisches kleines Vieh? Hat die Anna dich allein gelassen?",
		"BENEDIKT: Na, für dich hab ich was Schönes. Hör gut zu...",
		"BENEDIKT: Tüte, Tüte...",
		"BENEDIKT: ...eine kleine Tüte! Haha!",
		"BENEDIKT: Ich zeig dir mal, wie wir Menschen das hier regeln! Meine Jungs machen dich fertig!"
	]
	
	# Callback für nach dem Dialog - führt zum Kampf
	var callback = Callable(self, "_start_battle_transition")
	
	game_state_manager.start_multi_dialogue(dialogue_lines, callback)

func _start_battle_transition():
	print("Benedikt der Mitteldicke fordert heraus!")
	# Start battle transition with screen wipe effect
	if game_state_manager:
		game_state_manager.start_battle_transition()