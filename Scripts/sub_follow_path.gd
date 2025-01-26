extends PathFollow3D

@export var speed: float = 0.1
@export var started: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var _inverted: bool = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not started:
		return

	if _inverted:
		progress_ratio -= speed * delta
	else:
		progress_ratio += speed * delta

	if progress_ratio >= 1.0:
		progress_ratio = 1.0
		_inverted = true
	elif progress_ratio <= 0.0:
		progress_ratio = 0.0
		_inverted = false
