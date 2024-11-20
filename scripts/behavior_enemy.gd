extends CoreEnemy

@export var enemy_data: Enemy

@onready var enemy_name: Label = $AnimatedSprite2D/EnemyUI/EnemyName
@onready var enemy_title: Label = $AnimatedSprite2D/EnemyUI/EnemyTitle

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	super._ready()
	
	#connect signal
	GlobalPauseManager.pause_state_changed.connect(_on_pause_state_changed)
	
	enemy_name.text = enemy_data.enemy_name.to_upper() if enemy_data.enemy_name else "NO NAME"
	enemy_title.text = enemy_data.enemy_title if enemy_data.enemy_title else ""

func _on_pause_state_changed(paused: bool) -> void:
	print_debug('Signal works from actual script')
