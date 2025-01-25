extends CharacterBody2D

# Movement speed
@export var speed = 100 
var player_position
var target_position

@export var hit_sound: AudioStream
@onready var audio_player = $AudioStreamPlayer2D
@onready var animation_player = $AnimationPlayer
@onready var player = get_parent().get_node("Player")

func _ready():
	if hit_sound:
		audio_player.stream = hit_sound

func _physics_process(delta):
	player_position = player.position
	
	target_position = (player_position - position).normalized()
	
	if position.distance_to(player_position) > 3:
		velocity = target_position * speed
		animation_player.play("move")
		move_and_slide()
		look_at(player_position)

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() == player:
			if not audio_player.playing:
				audio_player.play()
