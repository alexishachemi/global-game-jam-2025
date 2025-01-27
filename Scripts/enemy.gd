class_name Enemy
extends CharacterBody2D

signal dead

@export var speed = 100 
@export var rush_speed = 300  # Speed when rushing
@export var tremble_duration = 1.0  # Time to tremble before rushing
@export var tremble_intensity = 5.0  # How much the enemy shakes

var player_position
var target_position
var is_trembling = false
var is_rushing = false
var tremble_timer = 0.0
var is_alive = true

@export var hit_sound: AudioStream
@onready var enemy_audio = $AudioStreamPlayer2D
@onready var animation_player = $AnimationPlayer
@onready var death_audio = $enemy_death_audio
@onready var sprite = $Sprite2D  # Reference to the Sprite2D node
@onready var explode_particules = $GPUParticles2D

var player_path = "/root/Level/CharacterView/CharacterBody2D"
@onready var player = get_parent().get_node(player_path)

@export var damage: int = 10
@export var max_health: int = 10
var health: int

@export var turn_speed: float = 2.0

func _ready():
	health = max_health
	if hit_sound:
		enemy_audio.stream = hit_sound
		Game.portrait.play_face("hurt", 0.3)
	start_tremble()

func start_tremble():
	if not is_alive:
		return
	is_trembling = true
	is_rushing = false
	tremble_timer = 0.0

func start_rush():
	if not is_alive:
		return
	is_trembling = false
	is_rushing = true

func _physics_process(delta):
	if not player or not is_alive or not Game.game_started:
		return
	
	player_position = player.global_position
	target_position = (player_position - global_position).normalized()
	
	#sprite.flip_h = target_position.x > 0
	
	if is_trembling:
		tremble_timer += delta
		if tremble_timer >= tremble_duration:
			start_rush()
		else:
			var shake_offset = Vector2(randf_range(-tremble_intensity, tremble_intensity), randf_range(-tremble_intensity, tremble_intensity))
			position += shake_offset * delta
	
	elif is_rushing:
		velocity = Vector2.RIGHT.rotated(rotation) * rush_speed
		move_and_slide()
		var desired_angle = (player_position - global_position).angle()
		rotation = lerp_angle(rotation, desired_angle, turn_speed * delta)
		#look_at(player_position)
		
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			if collider == player and collider.has_method("take_damage"):
				if not enemy_audio.playing:
					enemy_audio.play()
				collider.take_damage(damage)
				start_tremble()

func take_damage(amount: int):
	if not is_alive:
		return
	
	health -= amount
	if health <= 0:
		is_alive = false
		death_audio.play()
		$CollisionShape2D.set_deferred("disabled", true)
		sprite.visible = false
		explode_particules.emitting = true
		await death_audio.finished
		die()

func _process(_delta):
	visible = Game.game_started

func die():
	dead.emit()
	queue_free()
