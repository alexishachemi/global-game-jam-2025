@tool
extends ProgressBar

@export var icon: TextureRect
@export var icon_initial_position: Vector2
@export var max_height: float = 587

func _ready():
	Game.progress_bar = self
	connect("value_changed", _on_value_changed)

func _on_value_changed(_value):
	icon.position.x = icon_initial_position.x + (max_height * value) / max_value
