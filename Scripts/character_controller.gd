extends CharacterBody2D

# Movement speed
@export var speed: float = 2000.0
@export var dim_scale: float = 0.02

#player animation variable
@onready var animations = $AnimatedSprite2D
var direction: String = "bot";

# health bar variable
@export var max_health: int = 100
var health: int
@onready var health_bar = $HealthBar

# Reference to the 3D Position3D or Marker3D node
@export var camera_target_3d: NodePath

# Cached reference to the target node
var _target_3d: Node

# Get the viewport's rectangle
var viewport_rect: Rect2

# Calculate the center in 2D position
var screen_center_2d: Vector2

var _start_pos: Vector2

func _ready() -> void:
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
	if health <= 0:
		die()

func update_health_bar():
	if health_bar:
		health_bar.value = health

func die():
	print("Player has died!")
	#please add the logic of the game afterwards,
	#in the sense that do we restart or respawn, please El Grande Pineau tell us

func playAnimation(velocity: Vector2) -> void:
	if velocity.length() != 0:
		if velocity.x < 0:
			direction = "side"
			animations.flip_h = true
		elif velocity.x > 0:
			direction = "side"
			animations.flip_h = false
		elif velocity.y < 0:
			direction = "top"
		else: direction = "bot"
		animations.play("walk-" + direction)
	else:
		animations.play("idle-" + direction)

func _physics_process(_delta: float) -> void:
	# Handle 2D input
	var input_direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		input_direction.x += 1
	if Input.is_action_pressed("ui_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_direction.y += 1
	if Input.is_action_pressed("ui_up"):
		input_direction.y -= 1

	input_direction = input_direction.normalized()

	# Apply movement and update velocity
	velocity = input_direction * speed
	playAnimation(velocity)
	move_and_slide()
