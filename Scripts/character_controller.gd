class_name Player
extends CharacterBody2D

# Movement speed
@export var speed: float = 200.0
@export var dim_scale: float = 0.02

#player animation variable
@onready var animations = $AnimatedSprite2D
var direction: String = "bot";

# health bar variable
@export var max_health: int = 300
var health: int
@export var health_bar: TextureProgressBar

# Reference to the 3D Position3D or Marker3D node
@export var camera_target_3d: NodePath

# Cached reference to the target node
var _target_3d: Node

# Get the viewport's rectangle
var viewport_rect: Rect2

# Calculate the center in 2D position
var screen_center_2d: Vector2

var _start_pos: Vector2

@export var dash_speed: float = 400.0
@export var dash_duration: float = 0.2
@export var double_tap_time: float = 0.3

var is_dashing = false
var dash_timer = 0.0
var last_tap_dir = Vector2.ZERO
var last_tap_time = 0.0
var prev_input_direction = Vector2.ZERO

func _ready() -> void:
	Game.player = self
	Game.level.ascension_finished.connect(_on_ascension_finished)
	if camera_target_3d:
		_target_3d = get_node(camera_target_3d)
	else:
		push_error("Camera target in 3D not set!")
	viewport_rect = get_viewport().get_visible_rect()
	screen_center_2d = viewport_rect.size / 2
	global_position = screen_center_2d
	_start_pos = global_position
	health = max_health
	update_health_bar()

func take_damage(amount: int):
	health -= amount
	health = max(health, 0)
	update_health_bar()
	Game.portrait.play_face("hurt", 0.3)
	if health <= 0:
		die()

func add_oxygen():
	health += 30
	health = min(health, max_health)
	update_health_bar()
	Game.portrait.play_face("happy", 0.3)

func update_health_bar():
	if health_bar:
		health_bar.value = health

func die():
	Game.portrait.set_face("hurt")
	Game.game_started = false
	$AnimatedSprite2D.visible = false
	$HUD/GameOver.visible = true
	$Gun/Sprite2D.visible = false

func playAnimation(in_velocity: Vector2) -> void:
	if in_velocity.length() != 0:
		if in_velocity.x < 0:
			direction = "side"
			animations.flip_h = true
		elif in_velocity.x > 0:
			direction = "side"
			animations.flip_h = false
		elif in_velocity.y < 0:
			direction = "top"
		else: direction = "bot"
		animations.play("walk-" + direction)
	else:
		animations.play("idle-" + direction)

func _physics_process(delta: float) -> void:
	if not Game.game_started:
		return

	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	input_direction = input_direction.normalized()

	# Detect new presses (transition from no input to some input)
	if input_direction != Vector2.ZERO and prev_input_direction == Vector2.ZERO:
		var now = Time.get_ticks_msec()
		if input_direction == last_tap_dir and float(now - last_tap_time) < double_tap_time * 1000.0:
			is_dashing = true
			dash_timer = dash_duration
		else:
			last_tap_dir = input_direction
			last_tap_time = now

	prev_input_direction = input_direction

	if is_dashing:
		velocity = last_tap_dir.normalized() * dash_speed
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
	else:
		velocity = input_direction * speed

	playAnimation(velocity)
	move_and_slide()

	# Update the 3D node, etc.
	if _target_3d:
		_target_3d.global_position = Vector3(
			(position.x - _start_pos.x) * dim_scale,
			_target_3d.global_position.y,
			(position.y - _start_pos.y) * dim_scale
		)

func _on_ascension_finished():
	$HUD/GameOver/text.text = "You Win !"
	Game.portrait.set_face("happy")
	Game.game_started = false
	$HUD/GameOver.visible = true
	$Gun/Sprite2D.visible = false
