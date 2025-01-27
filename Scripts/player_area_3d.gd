extends Area3D

@export var player: Node2D

# Called when the node enters the scene tree for the first time.
func add_oxygen():
	player.add_oxygen()

func _on_body_entered(body: Node3D) -> void:
	player.add_oxygen()
	body.queue_free()
	$AudioStreamPlayer.play()
