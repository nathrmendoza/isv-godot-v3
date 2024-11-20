@tool
extends Control

var spawn_ingredient: PackedScene
var ingredient_stock: int
var has_overlapping_body: bool = false

@onready var container_texture: TextureRect = $ContainerTexture
@export var container_data: IngredientContainer:
	set(value):
		container_data = value
		if container_texture != null and _init_validation():
			container_texture.texture = container_data.container_texture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
	if _init_validation():
		_init_container()

func _on_container_texture_gui_input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if spawn_ingredient and ingredient_stock > 0 and not has_overlapping_body:
			_tween_pop_ingredient()
			GlobalPlayerData._remove_ingredient(container_data.ingredient_id, 1)
			var _ingredient = spawn_ingredient.instantiate()
			_ingredient.position = Vector2(0,0)
			add_child(_ingredient)
			_ingredient._tween_pop_off(container_data.pop_direction, container_data.pop_strength)

func _tween_pop_ingredient() -> void:
	var tween = create_tween()
	tween.tween_property(container_texture, "scale", Vector2(0.85, 1), 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.chain().tween_property(container_texture, "scale", Vector2(1, 1), 0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

func _init_container() -> void:
	# only allow changing of texture in editor
	container_texture.texture = container_data.container_texture
	if Engine.is_editor_hint(): return
	
	ingredient_stock = GlobalPlayerData._get_ingredient_amount(container_data.ingredient_id)
	spawn_ingredient = container_data.ingredient_scene

func _init_validation() -> bool:
	if container_data == null:
		printerr("Assign a container resource!")
		return false
	if container_data.ingredient_scene == null:
		printerr("Assign an ingredient scene to the container resource!")
		return false
	if container_data.container_texture == null:
		printerr("Assign a texture to the container resource!")
		return false
	return true


func _on_area_2d_body_entered(body: Node2D) -> void:
	has_overlapping_body = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	has_overlapping_body = false
