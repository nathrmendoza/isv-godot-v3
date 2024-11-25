extends Node

# PLAYER INPUTS
var player_is_grabbing: bool = false

func toggle_player_is_grabbing(is_grabbing: bool) -> void:
	player_is_grabbing = is_grabbing
