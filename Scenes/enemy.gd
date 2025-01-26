extends CharacterBody2D

# Movement speed
@export var speed = 100 
var player_position
var target_position

# Sound effect for hitting the player
@export var hit_sound: AudioStream
@onready var audio_player = $AudioStreamPlayer2D
@onready var animation_player = $AnimationPlayer
var player_path = "/root/Level/CharacterView/CharacterBody2D"

# Reference to the player (assign this in the Inspector or ensure the path is correct)
@onready var player = get_parent().get_node(player_path)

# Damage dealt to the player on collision
@export var damage: int = 10

func _ready():
	if hit_sound:
		audio_player.stream = hit_sound
	
	# Debug: Check if player is found
	if player:
		print("Player found: ", player.name)
	else:
		print("Player not found!")

func _physics_process(delta):
	# Exit if player is not found
	if not player:
		return
	
	player_position = player.position
	target_position = (player_position - position).normalized()
	
	# Debug: Print positions
	print("Player position: ", player_position)
	print("Enemy position: ", position)
	print("Target position: ", target_position)
	
	if position.distance_to(player_position) > 3:
		velocity = target_position * speed
		animation_player.play("move")
		move_and_slide()
		look_at(player_position)

	# Check for collisions with the player
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Ensure the collider is the player and has the take_damage method
		if collider == player and collider.has_method("take_damage"):
			if not audio_player.playing:
				audio_player.play()
			collider.take_damage(damage)
