extends CharacterBody2D

@export var speed = 100 
var player_position
var target_position

@export var hit_sound: AudioStream
@onready var enemy_audio = $AudioStreamPlayer2D
@onready var animation_player = $AnimationPlayer
@onready var death_audio = $enemy_death_audio

var player_path = "/root/Level/CharacterView/CharacterBody2D"
@onready var player = get_parent().get_node(player_path)

@export var damage: int = 10

@export var max_health: int = 10
var health: int

func _ready():
	health = max_health
	if hit_sound:
		enemy_audio.stream = hit_sound

func _physics_process(delta):
	if not player:
		return
	
	player_position = player.position
	target_position = (player_position - position).normalized()
	
	if position.distance_to(player_position) > 3:
		velocity = target_position * speed
		animation_player.play("move")
		move_and_slide()
		look_at(player_position)

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider == player and collider.has_method("take_damage"):
			if not enemy_audio.playing:
				enemy_audio.play()
			collider.take_damage(damage)

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		death_audio.play()
		await death_audio.finished
		die()

func die():
	queue_free()
