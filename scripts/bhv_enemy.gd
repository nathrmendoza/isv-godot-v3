extends Node2D

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# make sure all enemies have idle animations
	anim_sprite.animation = 'idle'
	anim_sprite.play()
