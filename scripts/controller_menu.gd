extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interactables: Array = [
	$CanvasLayer/CenterScreen/ButtonsContainer/PlayButton, 
	$CanvasLayer/CenterScreen/ButtonsContainer/QuitButton
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_disable_interactions()
	animation_player.play('menu_start_animate')
	await animation_player.animation_finished
	_enable_interactions()

func _transition_to_intro() -> void:
	_disable_interactions()
	animation_player.play('menu_exit_animate')
	await animation_player.animation_finished
	get_tree().change_scene_to_file("res://scenes/levels/prototype_intro_v2.tscn")

func _quit_game() -> void:
	get_tree().quit()

func _disable_interactions() -> void:
	for i in interactables:
		i.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _enable_interactions() -> void:
	for i in interactables:
		i.mouse_filter = Control.MOUSE_FILTER_STOP
