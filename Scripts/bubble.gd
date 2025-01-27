extends RigidBody3D

# Optional: Handle the lifetime of the bubble (e.g., despawn after a certain time)
@export var lifespan: float = 60.0
var life_timer: float = 0.0

func _physics_process(delta: float):
	# Increment timer and check lifespan
	life_timer += delta
	if life_timer > lifespan:
		queue_free()
