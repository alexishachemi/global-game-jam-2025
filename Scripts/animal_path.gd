class_name AnimalPath
extends Path3D

signal finished

@export var animator: AnimationPlayer
@export var follow: PathFollow3D
@export var speed: float = 1.0

var playing := false

func _ready():
	follow.loop = false

func play():
	follow.progress_ratio = 0.0
	animator.play("animate")
	playing = true

func _process(delta):
	if not playing:
		return
	follow.progress_ratio += speed * delta
	if follow.progress_ratio >= 1.0:
		playing = false
		finished.emit()
