extends Node3D

@export var min_interval_seconds: float = 15.0
@export var max_interval_seconds: float = 45.0

var animals: Array[AnimalPath]
@onready var timer = $Timer
var last_played: AnimalPath = null

func _ready():
	for child in get_children():
		if child is AnimalPath:
			child.finished.connect(_on_path_finished)
			animals.append(child)
	if min_interval_seconds > max_interval_seconds:
		var tmp := min_interval_seconds
		min_interval_seconds = max_interval_seconds
		max_interval_seconds = tmp
	start_timer()

func play():
	if animals.is_empty():
		return
	var tmp: Array[AnimalPath] = []
	for path in animals:
		if path != last_played:
			tmp.append(path)
	var picked: AnimalPath = tmp.pick_random()
	last_played = picked
	picked.play()

func start_timer():
	timer.start(randf_range(min_interval_seconds, max_interval_seconds))

func _on_timer_timeout():
	play()

func _on_path_finished():
	start_timer()
