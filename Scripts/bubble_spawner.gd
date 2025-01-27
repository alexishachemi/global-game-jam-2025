extends Node3D

# Variables to set spawn interval and bubble velocity
@export var spawn_interval: float = 5.0
@export var bubble_velocity: Vector3 = Vector3(0, 50, 0)

# Reference to the bubble scene
@export var bubble_scene: PackedScene

# Timer for spawning bubbles
var spawn_timer: Timer

func _ready():
	# Initialize the spawn timer
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.autostart = true
	spawn_timer.one_shot = false
	add_child(spawn_timer)
	spawn_timer.start()
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout():
	# Spawn a new bubble instance
	if bubble_scene:
		var bubble_instance: Node3D = bubble_scene.instantiate()
		get_parent().get_parent().add_child(bubble_instance)
		# Apply the velocity
		bubble_instance.global_position = global_position
		bubble_instance.linear_velocity = bubble_velocity
	else:
		print("Bubble scene not assigned!")
