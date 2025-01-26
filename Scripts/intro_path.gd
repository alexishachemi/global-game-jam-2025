extends PathFollow3D

@onready var first_music: AudioStreamPlayer = $MusicIntroPlayer
@onready var second_music: AudioStreamPlayer = $BoomPlayer

@export var explosion_particules: GPUParticles2D
@export var submarine_sprite: Sprite3D
@export var submarine_pathfollow: PathFollow3D
@onready var player_controller: PackedScene = preload("res://Scenes/character_view.tscn")
@export var watershader: Node
@export var homesprite: Sprite2D
var homespritespeed: float = 100.0

@export var lvl: Node3D

var first_done = false

var started = false
var ongoing = false

func _ready() -> void:
	$HomeSongPlayer.play()
	lvl = get_parent().get_parent().get_parent()
	var viewport_rect: Rect2 = get_viewport().get_visible_rect()
	var screen_center_2d: Vector2 = viewport_rect.size / 2
	get_node("Camera3D/Camera2D").global_position = screen_center_2d

func _process(delta: float) -> void:
	
	if first_done:
		if not second_music.playing:
			get_parent().get_parent().queue_free()
		return
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		started = true
	
	if started and not first_music.playing and not ongoing:
		first_music.play()
		submarine_pathfollow.started = true
		ongoing = true
		$HomeSongPlayer.stop()

	if not started:
		return
	
	homesprite.position.y -= delta * homespritespeed

	if first_music.playing:
		progress_ratio = first_music.get_playback_position() / first_music.stream.get_length()
	else:
		first_done = true
		progress_ratio = 1.0
		second_music.play()
		explosion_particules.restart()
		explosion_particules.emitting = true
		submarine_sprite.visible = false
		var pnode = player_controller.instantiate()
		lvl.add_child(pnode)
		pnode.position = Vector3(0, 300, 0)
		#var new_cam: Camera2D = pnode.get_node("CharacterBody2D/Camera2D")
		#new_cam.make_current()
		watershader.visible = false
		Game.game_started = true
	
