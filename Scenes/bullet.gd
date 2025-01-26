extends Area2D

const SPEED: int = 300

func _process(delta: float) -> void:
	position += transform.x * SPEED * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_body_entered(body: Node2D):
	if body.has_method("take_damage"):
		body.take_damage(1)
	queue_free()
