extends Area2D

const SPEED: int = 300
const IMPACT_PARTICLES_SCENE = preload("res://Scenes/impact_particles.tscn")
const IMPACT_SOUND: AudioStream = preload("res://Assets/sound/slap2.mp3")

func _process(delta: float) -> void:
	position += transform.x * SPEED * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_body_entered(body: Node2D):
	if body.has_method("take_damage"):
		body.take_damage(1)
	
	spawn_impact_particles()
	play_impact_sound()
	queue_free()

func spawn_impact_particles():
	var impact_particles = IMPACT_PARTICLES_SCENE.instantiate()
	get_parent().add_child(impact_particles)
	impact_particles.global_position = global_position
	impact_particles.emitting = true

func play_impact_sound():
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = IMPACT_SOUND
	audio_player.volume_db = -10
	audio_player.autoplay = true
	audio_player.connect("finished", Callable(audio_player, "queue_free"))
	get_parent().add_child(audio_player)
