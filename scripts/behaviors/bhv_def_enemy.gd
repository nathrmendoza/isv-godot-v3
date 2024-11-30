extends CoreEnemy
signal _on_take_damage(new_health: float)
signal _on_does_action(action: EnemyActions)

@export var enemy_data: Enemy

@onready var enemy_name: Label = $AnimatedSprite2D/EnemyUI/EnemyName
@onready var enemy_title: Label = $AnimatedSprite2D/EnemyUI/EnemyTitle

@onready var health_bar_ui: TextureProgressBar = $AnimatedSprite2D/EnemyUI/EnemyBars/HealthBarUI
@onready var action_timer_ui: TextureProgressBar = $AnimatedSprite2D/EnemyUI/EnemyBars/ActionTimerUI

var health: float = 100.0
var enemy_actions: Array

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	super._ready()
	
	# CONNECT IMPORTANT SIGNALS
	GlobalPauseManager.pause_state_changed.connect(_on_pause_state_changed)
	_on_take_damage.connect(health_bar_ui._set_health)
	
	# SET UP ENEMY
	health = enemy_data.health
	action_timer_ui._init_timer(enemy_data.speed)
	enemy_actions = enemy_data.actions
	
	# SET UP UI
	enemy_name.text = enemy_data.enemy_name.to_upper() if enemy_data.enemy_name else "NO NAME"
	enemy_title.text = enemy_data.enemy_title if enemy_data.enemy_title else ""
	health_bar_ui._init_health(health)
	
	await get_tree().create_timer(5).timeout
	_take_damage(200)
	await get_tree().create_timer(1).timeout
	_take_damage(150)
	

func _take_damage(amount: float) -> void:
	# PAUSE ACTION TIMER
	action_timer_ui._pause_action_timer()
	
	health -= amount
	# SIGNAL TO HEALTHBAR NODE, PASS ALONG HEALTH
	_on_take_damage.emit(health)
	shake(15, 0.6)
	sprite.play('hurt')
	
	if health <= 0:
		sprite.play('death')
		await sprite.animation_finished
		_die()
	
	await sprite.animation_finished
	sprite.play('idle')
	
	# RESUME ACTION TIMER
	action_timer_ui._resume_action_timer()

func _do_action() -> void:
	var the_action = _enemy_action_logic()
	if the_action == null: return
	
	sprite.play(the_action.animation_state)
	await sprite.animation_finished
	
	_on_does_action.emit(the_action)
	
	sprite.play('idle')
	
	action_timer_ui._reset_action_timer()

# FOR NOW AI FOR ENEMY ACTIONS IS RANDOM PICKING
func _enemy_action_logic() -> EnemyActions:
	if enemy_actions.size() > 0:
		var random_index = randi() % enemy_actions.size()
		return enemy_actions[random_index]
	return null

func _die() -> void:
	# EMIT SIGNAL TO PASS ON ENEMY DEATH
	queue_free()

func shake(intensity: float = 2.0, duration: float = 0.2):
	var shake_tween = create_tween()
	var start_pos = position
	
	# Shake back and forth a few times
	for i in range(10):
		var random_offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		shake_tween.tween_property(self, "position", start_pos + random_offset, duration/10)
		
	# Return to original position
	shake_tween.tween_property(self, "position", start_pos, duration/10)

func _on_pause_state_changed(paused: bool) -> void:
	print_debug('Signal works from actual script')
