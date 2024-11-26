extends Control

@export var container_data: IngredientContainer
@onready var container_texture: TextureRect = $TextureRect
@onready var area_2d: Area2D = $Area2D

var spawn_ingredient: PackedScene
var ingredient_stock: int
var can_spawn: bool = true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
	if container_data:
		spawn_ingredient = container_data.ingredient_scene
		ingredient_stock = GlobalPlayerData._get_ingredient_amount(container_data.ingredient_id)


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if !_has_overlapping_ingredient() and UtilsInputQueries.check_topmost_clicked(area_2d, event.global_position) and spawn_ingredient and can_spawn and ingredient_stock > 0:
			get_viewport().set_input_as_handled()
			can_spawn = false
			_tween_pop_ingredient()
			
			#update stock
			ingredient_stock -= 1
			GlobalPlayerData._remove_ingredient(container_data.ingredient_id, 1)
			
			#create instance
			var _ingredient = spawn_ingredient.instantiate()
			_ingredient.position = Vector2(0,0)
			add_child(_ingredient)
			_ingredient._tween_pop_off(container_data.pop_direction, container_data.pop_strength)
			
			await get_tree().create_timer(container_data.pop_cooldown).timeout
			can_spawn = true


func _tween_pop_ingredient() -> void:
	var tween = create_tween()
	tween.tween_property(container_texture, "scale", Vector2(0.85, 1), 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.chain().tween_property(container_texture, "scale", Vector2(1, 1), 0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

func _has_overlapping_ingredient() -> bool:
	for body in area_2d.get_overlapping_bodies():
		if body.has_method('_ingredient_checker'):
			return true
	return false
