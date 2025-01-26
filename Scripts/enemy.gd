extends CharacterBody2D

@export var speed = 100 
@export var rush_speed = 200  # Speed when rushing
@export var tremble_duration = 1.0  # Time to tremble before rushing
@export var tremble_intensity = 5.0  # How much the enemy shakes

var player_position
var target_position
var is_trembling = false
var is_rushing = false
var tremble_timer = 0.0
var is_alive = true  # Track if the enemy is alive

@export var hit_sound: AudioStream
@onready var enemy_audio = $AudioStreamPlayer2D
@onready var animation_player = $AnimationPlayer
@onready var death_audio = $enemy_death_audio

var player_path = "/root/Level/CharacterView/CharacterBody2D"
@onready var player = get_parent().get_node(player_path)

@export var damage: int = 2  # Reduced damage to 2
@export var max_health: int = 10
var health: int

func _ready():
	health = max_health
	if hit_sound:
		enemy_audio.stream = hit_sound
		Game.portrait.play_face("hurt", 0.3)
	start_tremble()

func start_tremble():
	if not is_alive:
		return  # Don't start trembling if the enemy is dead
	is_trembling = true
	is_rushing = false
	tremble_timer = 0.0

func start_rush():
	if not is_alive:
		return  # Don't start rushing if the enemy is dead
	is_trembling = false
	is_rushing = true

func _physics_process(delta):
	if not player or not is_alive:
		return  # Exit if player is not found or enemy is dead
	
	player_position = player.position
	target_position = (player_position - position).normalized()
	
	if is_trembling:
		# Tremble behavior (shake randomly)
		tremble_timer += delta
		if tremble_timer >= tremble_duration:
			start_rush()  # Transition to rushing after trembling
		else:
			# Apply random shaking
			var shake_offset = Vector2(randf_range(-tremble_intensity, tremble_intensity), randf_range(-tremble_intensity, tremble_intensity))
			position += shake_offset * delta
	
	elif is_rushing:
		# Rush toward the player
		velocity = target_position * rush_speed
		move_and_slide()
		look_at(player_position)
		
		# Check for collisions with the player
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			if collider == player and collider.has_method("take_damage"):
				if not enemy_audio.playing:
					enemy_audio.play()
				collider.take_damage(damage)
				start_tremble()  # Reset to trembling after attacking

func take_damage(amount: int):
	if not is_alive:
		return  # Don't take damage if already dead
	
	health -= amount
	if health <= 0:
		is_alive = false  # Mark the enemy as dead
		death_audio.play()
		await death_audio.finished  # Wait for the death sound to finish
		die()

func die():
	queue_free()  # Remove the enemy from the scene
