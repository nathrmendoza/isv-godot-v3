extends Node2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var main_control: Control = $CanvasLayer/MainControl
@onready var node_background = $CanvasLayer/MainControl/TransitioningBackground

var is_background_changing: bool = false
var is_scrolling_finished: bool = false
var is_story_finished: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	anim_player.current_animation = 'intro_entry_anim'
	anim_player.play()
	await anim_player.animation_finished
	main_control.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_main_control_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if is_scrolling_finished and is_background_changing == false:
			node_background._transition_textures()

func _on_bg_transition_start() -> void:
	is_background_changing = true

func _on_bg_transition_finish() -> void:
	is_background_changing = false

func _on_text_panel_running() -> void:
	is_scrolling_finished = false

func _on_text_panel_stopped() -> void:
	is_scrolling_finished = true

func _on_story_finished() -> void:
	anim_player.current_animation = 'intro_exit_anim'
	anim_player.play()
	await anim_player.animation_finished
	get_tree().change_scene_to_file('res://scenes/levels/prototype_level.tscn')
