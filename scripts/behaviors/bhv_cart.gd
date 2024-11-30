extends Control

@export var strength: float = 30.0
@export var fade: float = 5.0

var rng = RandomNumberGenerator.new()

var shake_strength: float = 0.0

func _shake() -> void:
	shake_strength = strength

func _shake_random_vector() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, fade * delta)
		
		position = _shake_random_vector()
