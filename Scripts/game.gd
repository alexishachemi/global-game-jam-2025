extends Node

signal game_state_changed(active: bool)

var portrait: Portrait
var player: Player
var progress_bar: ProgressBar

var game_started := false : set = _set_game_started

func _set_game_started(state):
	game_started = state
	game_state_changed.emit(state)
