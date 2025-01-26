extends Node2D

@export var sprite_3d: NodePath
@export var animator: AnimationPlayer
@onready var sprite_3d_node = get_node(sprite_3d)
@onready var home_sprite: Node2D = $Sprite2D

var screen_center_2d: Vector2

func _ready() -> void:
	var viewport_rect = get_viewport().get_visible_rect()
	screen_center_2d = viewport_rect.size / 2
	global_position = screen_center_2d
	animator.play("title")

func _process(_delta: float):
	if not sprite_3d_node:
		return

	# Get the global position of the 3D sprite
	var sprite_3d_position = sprite_3d_node.global_transform.origin

	# Convert it to screen space
	var viewport_rect = get_viewport().get_visible_rect()
	var camera = get_viewport().get_camera_3d()
	var screen_position = camera.unproject_position(sprite_3d_position)

	# Adjust for screen center offset
	var screen_size = viewport_rect.size
	var adjusted_position = screen_position - (Vector2(screen_size) / 2)

	# Update the Particles2D position
	$GPUParticles2D.global_position = adjusted_position + global_position

	# Calculate scale factor based on distance to the camera
	var camera_position = camera.global_transform.origin
	var distance = camera_position.distance_to(sprite_3d_position)
	var base_distance = 4.0  # Reference distance at which scale is 1.0
	var scale_factor = 1.0 / max(distance / base_distance, 0.001)  # Prevent division by zero

	# Apply scale to GPUParticles2D
	$GPUParticles2D.scale = Vector2(scale_factor, scale_factor)

	# Calculate rotation for GPUParticles2D
	var sprite_3d_transform = sprite_3d_node.global_transform
	var forward_vector = sprite_3d_transform.basis.z.normalized()  # Forward direction in 3D

	# Transform forward vector into camera space
	var camera_transform = camera.global_transform
	var camera_transform_inverse = camera_transform.affine_inverse()
	var forward_in_camera_space = camera_transform_inverse.basis * forward_vector

	# Project the forward vector onto the 2D plane
	var projected_forward = Vector2(forward_in_camera_space.x, -forward_in_camera_space.z).normalized()

	# Get the angle in 2D space from the projected forward direction
	var angle = atan2(projected_forward.y, projected_forward.x)

	# Apply correction to match 2D orientation (adjust as needed)
	var corrected_angle = angle + deg_to_rad(90)  # Rotate by 90 degrees to align

	# Apply the rotation to GPUParticles2D
	$GPUParticles2D.rotation = corrected_angle
