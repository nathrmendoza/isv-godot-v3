extends Node

signal pause_state_changed(is_paused: bool)

var is_paused: bool = false

func toggle_pause() -> void:
	is_paused = !is_paused
	pause_state_changed.emit(is_paused)
	get_tree().paused = is_paused
