#gun script

extends Node2D
 
const BULLET = preload("res://Scenes/bullet.tscn")

@onready var muzzle: Marker2D = $Canon
@onready var gun_player = $AnimationPlayer
@onready var gun_audio = $pop_audio
@onready var player = get_parent()

func _process(_delta: float) -> void:
	if not Game.game_started:
		return
	look_at(get_global_mouse_position())
 
	rotation_degrees = wrap(rotation_degrees, 0, 360)
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -1
	else:
		scale.y = 1

	if Input.is_action_just_pressed("shoot"):
		var bullet_instance = BULLET.instantiate()
		get_tree().root.add_child(bullet_instance)
		bullet_instance.global_position = muzzle.global_position
		bullet_instance.rotation = rotation
		gun_audio.play()
		gun_player.play("shot")
		player.take_damage(1)
