extends TextureProgressBar

@onready var action_timer = $ActionTimer

func _init_timer(action_time: float) -> void:
	max_value = action_time
	action_timer.wait_time = action_time
	action_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if action_timer:
		value = action_timer.wait_time - action_timer.time_left

func _pause_action_timer() -> void:
	action_timer.paused = true

func _resume_action_timer() -> void:
	action_timer.paused = false

func _reset_action_timer() -> void:
	value = action_timer.wait_time
	action_timer.start()
