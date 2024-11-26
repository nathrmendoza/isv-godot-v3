extends Node2D

@onready var main_anim_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#disables interactions
	set_process_input(false)
	
	main_anim_player.current_animation = 'scene_fade_in'
	main_anim_player.play()
	
	await main_anim_player.animation_finished
	
	main_anim_player.current_animation = 'enemy_popup'
	main_anim_player.play()

	await main_anim_player.animation_finished
	
	set_process_input(true)
