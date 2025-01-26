extends Node3D

signal ascension_stopped
signal ascension_finished

@export var environment: MapEnvironment

@export_group("Fog")
@export var fog_intensity_speed: float = 0.001
@export var fog_intensity_increase_interval_seconds: float = 0.01

@export_group("Ascension")
@export var ascension_speed: float = 1.0
@export var end: float = 500
@export var stops: Array[float] = [0, 100, 220, 350]

var interval: float = 0.0
var ascending := true
var distance: float

func resume_ascension():
	Game.portrait.set_face("happy")
	ascending = true

func stop_ascending():
	Game.portrait.set_face("neutral")
	ascending = false

func update_ascension(delta):
	if not ascending:
		return
	if interval >= fog_intensity_increase_interval_seconds:
		environment.env.volumetric_fog_density += fog_intensity_speed * delta
		interval = 0
	interval += delta
	environment.position.y -= ascension_speed * delta
	distance = abs(environment.global_position.y)
	if distance >= end:
		ascension_finished.emit()
		stop_ascending()
	var current: float
	for i in range(stops.size()):
		current = stops[i]
		if (current - ascension_speed) <= distance and distance <= (current + ascension_speed):
			stop_ascending()
			stops.remove_at(i)
			ascension_stopped.emit()
			break
	Game.progress_bar.value = (distance * 100) / end

func _process(delta):
	update_ascension(delta)
	if not ascending and Input.is_action_pressed("ui_accept"):
		resume_ascension()
