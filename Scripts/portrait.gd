class_name Portrait
extends TextureRect

@export var faces: Array[Face]
@onready var timer := $Timer
var target_face: Face

func _ready():
	Game.portrait = self

func _get_face(face_name: StringName) -> Face:
	for face in faces:
		if face.nickname == face_name:
			return face
	return null

func play_face(face_name: StringName, seconds: float = 1.0):
	var face := _get_face(face_name)
	if face == null:
		return
	texture = face.texture
	timer.start(seconds)

func reset_face():
	texture = target_face.texture

func set_face(face_name: StringName):
	var face := _get_face(face_name)
	if face == null:
		return
	target_face = face
	reset_face()

func _on_timer_timeout():
	reset_face()
