extends TextureRect

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite_parent: Sprite2D = $ShapeMask
@onready var hotpot_positions: Array = [
	$ShapeMask/Position1, 
	$ShapeMask/Position2, 
	$ShapeMask/Position3, 
	$ShapeMask/Position4, 
	$ShapeMask/Position5, 
	$ShapeMask/Position6
]

var cooking_slots: Array = [null, null, null, null, null, null]
var slot_sprites: Array = [null, null, null, null, null, null]
var slot_tweens: Array = [null, null, null, null, null, null]
var colliding_body_ref: RigidBody2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim_sprite.play('default')


func _has_slot() -> bool:
	return cooking_slots.count(null) > 0


func _get_slot() -> int:
	return cooking_slots.find(null)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("_start_cooking") and body.is_cooked != true:
		colliding_body_ref = body


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method("_start_cooking") and colliding_body_ref == body:
		colliding_body_ref = null


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed == false:
		if colliding_body_ref and _has_slot() and GlobalLevelData.player_is_grabbing:
			_start_cooking(colliding_body_ref)

func _start_cooking(ingredient: RigidBody2D = null) -> void:
	if ingredient == null: return
	var slot = _get_slot()
	
	colliding_body_ref = null
	
	cooking_slots[slot] = ingredient
	ingredient._start_cooking(hotpot_positions[slot].global_position)
	
	var sprite = Sprite2D.new()
	sprite.modulate = Color(1,1,1,0)
	sprite.scale = Vector2(0,0)
	sprite.texture = ingredient._get_anim_texture('raw')
	sprite.position = hotpot_positions[slot].position
	sprite_parent.add_child(sprite)
	
	var sprite_entry_tween = create_tween()
	sprite_entry_tween.tween_property(sprite, 'modulate', Color(1,1,1,1), 0.4).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	sprite_entry_tween.parallel().tween_property(sprite, 'scale', Vector2(0.9,0.9), 0.4).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	
	slot_sprites[slot] = sprite
	await sprite_entry_tween.finished
	
	var jiggle_tween = create_tween()
	jiggle_tween.set_loops().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	jiggle_tween.tween_property(sprite, 'position:y', sprite.position.y - 6, 0.25)
	jiggle_tween.tween_property(sprite, 'position:y', sprite.position.y, 0.15)
	slot_tweens[slot] = jiggle_tween
	
	get_tree().create_timer(ingredient.ingredient_resource.cook_timer).timeout.connect(
		_finish_cooking.bind(slot)
	)

func _finish_cooking(slot: int) -> void:
	var ingredient = cooking_slots[slot]
	
	if ingredient:
		ingredient._finish_cooking()
		cooking_slots[slot] = null
		slot_sprites[slot].queue_free()
		slot_sprites[slot] = null
		slot_tweens[slot].kill()
		slot_tweens[slot] = null
	
	#reset stove animation: check if all slots is null
	#var cooking_slots_empty = true
	#for i in cooking_slots:
		#if i != null:
			#cooking_slots_empty = false
			#break
	#if cooking_slots_empty:
		#anim_sprite.stop()
		#anim_sprite.animation = 'default'
