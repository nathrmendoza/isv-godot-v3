extends Node2D

@export var has_intro_animation: bool = true
@onready var anim_player = $AnimationPlayer
@onready var player_ui = $CartLayer/Cart/CartTop/PlayerUI

var player_health: float
var player_armor: float

func _ready() -> void:
	#make all child node pausable
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if has_intro_animation:
		GlobalPauseManager.toggle_pause()
		
		anim_player.current_animation = 'level_entry_anim'
		anim_player.play()
		
		await anim_player.animation_finished
		GlobalPauseManager.toggle_pause()
		
	#update player vars
	player_health = GlobalPlayerData._health
	player_armor = GlobalPlayerData._armor
	
	#update UI related
	player_ui._init_player_ui(player_health, player_armor)
	
	await get_tree().create_timer(3).timeout
	_player_take_damage(150)
	await get_tree().create_timer(1).timeout
	_player_take_damage(150)
	await get_tree().create_timer(4).timeout
	_player_take_damage(250)

func _player_take_damage(damage_amount: float) -> void:
	if player_armor > 0:
		player_armor -= damage_amount
		player_ui._set_armor(player_armor)
	else:
		player_health -= damage_amount
		player_ui._set_health(player_health)
