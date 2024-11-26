extends Node2D

@export var has_intro_animation: bool = true

@onready var anim_player = $AnimationPlayer

func _ready() -> void:
	#make all child node pausable
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if has_intro_animation:
		GlobalPauseManager.toggle_pause()
		
		anim_player.current_animation = 'level_entry_anim'
		anim_player.play()
		
		await anim_player.animation_finished
		GlobalPauseManager.toggle_pause()
