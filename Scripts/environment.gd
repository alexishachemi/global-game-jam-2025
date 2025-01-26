class_name MapEnvironment
extends Node3D

@export var target: Node3D
@export var target_limit_y: float = 400
@export var max_height: float = 200
@export var UNDER_OFFSET: float = 400
@export var OVER_OFFSET: float = 500

@onready var env: Environment = $WorldEnvironment.environment
@onready var animals: BackgroundAnimalsManager = $BackgroundAnimals
@onready var animator: AnimationPlayer = $AnimationPlayer

func _process(_delta):
	if Game.game_started and not $SurfaceLight.visible:
		$SurfaceLight.visible = true
		target = get_parent().get_node("CharacterView")
	if not target:
		return
	if target.position.y - position.y >= target_limit_y:
		if not animals.playing:
			animals.global_position.y = target.global_position.y - UNDER_OFFSET
			animals.position.y = clampf(animals.position.y, 0, max_height)
	else:
		animals.global_position.y = target.global_position.y + OVER_OFFSET
