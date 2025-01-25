extends Camera3D

# Smoothing factor for camera movement
@export var smooth_speed: float = 5.0

# Reference to the 3D target (Position3D/Marker3D)
@export var target: NodePath


# Cached reference to the target node
var _target_node: Node


func _ready() -> void:
	if target:
		_target_node = get_node(target)
	else:
		push_error("Target node for camera not set!")

func _process(delta: float) -> void:
	if _target_node:
		#Smoothly follow the target and apply the height adjustment
		var target_position = _target_node.global_position
		global_position = global_position.lerp(target_position, delta * smooth_speed)
