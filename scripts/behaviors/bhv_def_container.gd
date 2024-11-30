extends Control

@export var container_data: IngredientContainer
@onready var container_texture: TextureRect = $TextureRect
@onready var area_2d: Area2D = $Area2D

@export var target_path: NodePath
@onready var target_node: CanvasLayer = get_node(target_path)

var spawn_ingredient: PackedScene
var ingredient_stock: int
var can_spawn: bool = true

var overlapping_bodies: Array

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
	area_2d.connect("body_entered", _on_body_entered)
	area_2d.connect("body_exited", _on_body_exited)
	
	if container_data:
		spawn_ingredient = container_data.ingredient_scene
		ingredient_stock = GlobalPlayerData._get_ingredient_amount(container_data.ingredient_id)


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if !_overlap_checker(event.position) and spawn_ingredient and can_spawn and ingredient_stock > 0:
			get_viewport().set_input_as_handled()
			can_spawn = false
			_tween_pop_ingredient()
			
			#update stock
			ingredient_stock -= 1
			GlobalPlayerData._remove_ingredient(container_data.ingredient_id, 1)
			
			#create instance
			var _ingredient = spawn_ingredient.instantiate()
			_ingredient.position = global_position
			target_node.add_child(_ingredient)
			_ingredient._tween_pop_off(container_data.pop_direction, container_data.pop_strength)
			
			await get_tree().create_timer(container_data.pop_cooldown).timeout
			can_spawn = true


func _tween_pop_ingredient() -> void:
	var tween = create_tween()
	tween.tween_property(container_texture, "scale", Vector2(0.85, 1), 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.chain().tween_property(container_texture, "scale", Vector2(1, 1), 0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("_ingredient_checker"):
		overlapping_bodies.append(body)

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("_ingredient_checker"):
		overlapping_bodies.erase(body)

func _overlap_checker(click_pos: Vector2) -> bool:
	for body in overlapping_bodies:
		var polygon = body.get_node("CollisionPolygon2D")
		var polygon_points = polygon.polygon
		var local_click = body.to_local(click_pos)
		
		if Geometry2D.is_point_in_polygon(local_click, polygon_points):
			return true		
	return false
