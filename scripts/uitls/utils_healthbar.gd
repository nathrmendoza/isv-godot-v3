extends TextureProgressBar

@export var catchup_timer: float = 1.2
@onready var red_bar: TextureProgressBar = $HealthBarFill

var health: float = 0

func _set_health(new_health: float) -> void:
	var prev_health = health
	health = min(max_value, new_health)
	var tween_red_bar = create_tween()
	tween_red_bar.tween_property(red_bar, "value", health, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	if health < prev_health:
		await get_tree().create_timer(catchup_timer).timeout
		var tween_progress_bar = create_tween()
		tween_progress_bar.tween_property(self, "value", health, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _init_health(new_health: float) -> void:
	health = new_health
	
	max_value = new_health
	value = health
	
	red_bar.max_value = health	
	red_bar.value = health
