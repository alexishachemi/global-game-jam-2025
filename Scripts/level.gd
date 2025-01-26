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

@export_group("Enemy Waves")
const enemy_scene = preload("res://Scenes/enemy.tscn")
@export var spawn_interval: float = 10
@export var enemies_per_wave_increase: int = 1
var current_wave: int = 0
var enemies_to_spawn: int = 1
var killed: int = 0

var interval: float = 0.0
var ascending := true
var distance: float
var spawn_timer: float = 0.0

func start_wave():
	for i in range(enemies_to_spawn):
		spawn_enemy()
	current_wave += 1
	enemies_to_spawn += enemies_per_wave_increase
	spawn_timer = 0.0

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	get_parent().add_child.call_deferred(enemy)
	var screen_width = get_viewport().get_visible_rect().size.x
	var screen_height = get_viewport().get_visible_rect().size.y
	var spawn_edge = randi() % 4
	match spawn_edge:
		0:
			enemy.global_position = Vector2(randf_range(0, screen_width), -50)
		1:
			enemy.global_position = Vector2(screen_width + 50, randf_range(0, screen_height))
		2:
			enemy.global_position = Vector2(randf_range(0, screen_width), screen_height + 50)
		3:
			enemy.global_position = Vector2(-50, randf_range(0, screen_height))

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
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		start_wave()

func _process(delta):
	if not Game.game_started:
		return
	if not $AudioStreamPlayer.playing:
		$AudioStreamPlayer.play()
	update_ascension(delta)
	if not ascending and Input.is_action_pressed("ui_accept"):
		resume_ascension()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _ready() -> void:
	Game.game_started = false
