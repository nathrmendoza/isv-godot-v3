extends Node2D
class_name CoreEnemy

#for general entry and exit animations
@onready var anim_player: AnimationPlayer = $AnimationPlayer
#for actual enemy state animations
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var enemy_ui: Control = $AnimatedSprite2D/EnemyUI

var health: float

func _ready() -> void:
	_hide_seeable()
	
	#connect signals
	GlobalPauseManager.pause_state_changed.connect(on_pause_state_changed)
	
	#animations
	anim_player.current_animation = 'enemy_entry_anim'
	anim_player.play()
	
	sprite.animation = 'idle'
	
	await anim_player.animation_finished
	sprite.play()

func _take_damage(amount: float) -> void:
	health -= amount
	if health <= 0:
		_die()

func _die() -> void:
	queue_free()

func _hide_seeable() -> void:
	sprite.modulate = Color(1,1,1,0)
	enemy_ui.modulate = Color(1,1,1,0)

func on_pause_state_changed(is_paused: bool) -> void:
	if is_paused:
		anim_player.pause()
		sprite.pause()
	else:
		anim_player.play()
		sprite.play()
