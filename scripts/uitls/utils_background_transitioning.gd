extends TextureRect

signal on_transition_start
signal on_transition_finished

@export var textures: Array[CompressedTexture2D]
@export var transition_speed: float = 1.2

var current_index = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if textures.size() > 0:
		texture = textures[0]

func _transition_textures() -> void:
	current_index += 1
	if current_index < textures.size(): 
		var bg_tween = create_tween()
		on_transition_start.emit()
		bg_tween.tween_property(self, 'modulate', Color(0,0,0,1), transition_speed / 2)
		bg_tween.chain().tween_callback(func():
			texture = textures[current_index]	
		)
		bg_tween.tween_property(self, 'modulate', Color(1,1,1,1), transition_speed / 2)
		bg_tween.chain().tween_callback(func():
			on_transition_finished.emit()
		)
