class_name BackgroundAnimalsManager
extends Node3D

signal finished

@export var min_interval_seconds: float = 15.0
@export var max_interval_seconds: float = 45.0
@export var animator: AnimationPlayer

var animals: Array[AnimalPath]
@onready var timer = $Timer
var last_played: AnimalPath = null
var playing: bool = false
var fade_flag := false

func _ready():
	for child in get_children():
		if child is AnimalPath:
			child.finished.connect(_on_path_finished)
			animals.append(child)
			child.visible = false
	if min_interval_seconds > max_interval_seconds:
		var tmp := min_interval_seconds
		min_interval_seconds = max_interval_seconds
		max_interval_seconds = tmp
	start_timer()

func _process(_delta):
	if not last_played or not playing:
		return
	if last_played.follow.progress_ratio >= 0.8 and not fade_flag:
		animator.play("fade_out")
		fade_flag = true

func play():
	if animals.is_empty():
		return
	var tmp: Array[AnimalPath] = []
	for path in animals:
		if path != last_played:
			tmp.append(path)
	var picked: AnimalPath = tmp.pick_random()
	if picked == null:
		picked = last_played
	last_played = picked
	playing = true
	picked.visible = true
	fade_flag = false
	picked.play()
	animator.play("fade_in")

func start_timer():
	timer.start(randf_range(min_interval_seconds, max_interval_seconds))

func _on_timer_timeout():
	play()

func _on_path_finished():
	last_played.visible = false
	start_timer()
	playing = false
	finished.emit()
