extends RigidBody2D
class_name CoreIngredient

@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var collision_body: CollisionPolygon2D = $CollisionPolygon2D
@onready var shader_material: ShaderMaterial = sprite.material

var is_dragging: bool = false
var is_draggable: bool = true
var drag_start: Vector2
var last_pointer_position: Vector2
var pointer_velocity: Vector2

@export var ingredient_resource: Ingredient = null
@export var throw_force_multiplier: float = 15.0
@export var throw_max_velocity: float = 30.0

var offscreen_margin: float
var viewport_height: float

var is_cooking: bool = false
var is_cooked: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
	# assign material as unique
	var cooking_material = ShaderMaterial.new()
	cooking_material.shader = preload("res://scripts/shaders/shaders_ingredient_cooking.gdshader")
	sprite.material = cooking_material.duplicate()
	
	if _ingredient_checker() == false: queue_free()
	input_pickable = true
	viewport_height = get_viewport_rect().size.y
	offscreen_margin = _get_polygon_height()
	get_tree().root.size_changed.connect(_on_viewport_change)
	
	# just instantiated, remove collisions
	collision_layer = 1
	collision_mask = 0
	
	await get_tree().create_timer(2).timeout
	collision_mask = 1

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_draggable:
			if  _is_point_in_polygon(event.global_position):
				_grabbing_object(event.global_position)

func _physics_process(delta: float) -> void:
	if is_dragging:
		var current_pointer_position = get_global_mouse_position()
		if Input.is_action_pressed('click'):
			# update the position of object
			global_position = current_pointer_position - drag_start
			pointer_velocity = (current_pointer_position - last_pointer_position) / delta
			pointer_velocity = pointer_velocity.limit_length(throw_max_velocity)
			last_pointer_position = current_pointer_position
		elif Input.is_action_just_released('click'):
			GlobalLevelData.toggle_player_is_grabbing(false)
			is_dragging = false
			freeze = false
			apply_central_impulse(pointer_velocity * throw_force_multiplier)
		
	#remove if below boundary
	if global_position.y > viewport_height + offscreen_margin:
		queue_free()

func _grabbing_object(pointer_position: Vector2) -> void:
	if not is_dragging:
		GlobalLevelData.toggle_player_is_grabbing(true)
		is_dragging = true
		drag_start = pointer_position - global_position
		last_pointer_position = pointer_position
		freeze = true

func _start_cooking(cooking_position: Vector2):
	if not is_cooked:
		collision_mask = 0
		is_cooking = true
		is_draggable = false
		global_position = cooking_position
		set_deferred('freeze', true)
		#collision_body.disabled = true
		hide()

func _finish_cooking():
	show()
	is_cooking = false
	is_cooked = true
	is_draggable = true
	
	#sprite.animation = 'cooked'
	
	# set shader
	if sprite.material != null:
		sprite.material.set_shader_parameter("is_cooking", false)
		sprite.material.set_shader_parameter("fixed_time", 5)
		sprite.material.set_shader_parameter("cook_progress", 1.0)
		sprite.material.set_shader_parameter("heat_intensity", 1.0)
	
	freeze = false
	_tween_pop_off('right', 1200)
	await get_tree().create_timer(4).timeout
	collision_mask = 1

func _tween_pop_off(pop_direction: String, pop_strength: int) -> void:
	var rand_x = randi_range(250, 500)
	match pop_direction:
		'straight':
			apply_central_impulse(Vector2(0, -pop_strength))
		'left':
			apply_central_impulse(Vector2(-rand_x, -pop_strength))
		'right':
			apply_central_impulse(Vector2(rand_x, -pop_strength))

func _is_point_in_polygon(point: Vector2) -> bool:
	var local_point = to_local(point)
	var polygon_points = collision_body.polygon
	
	var inside = false
	var j = polygon_points.size() - 1
	
	for i in polygon_points.size():
		if ((polygon_points[i].y > local_point.y) != (polygon_points[j].y > local_point.y) and
			local_point.x < (polygon_points[j].x - polygon_points[i].x) * 
			(local_point.y - polygon_points[i].y) / 
			(polygon_points[j].y - polygon_points[i].y) + polygon_points[i].x):
			inside = !inside
		j = i
		
	return inside

func _get_polygon_height() -> float:
	var polygon_points = collision_body.polygon
	
	var min_y = polygon_points[0].y
	var max_y = polygon_points[0].y
	
	for point in polygon_points:
		min_y = min(min_y, point.y)
		max_y = max(max_y, point.y)
	
	return max_y - min_y

func _get_anim_texture(state: String) -> Texture2D:
	var sprite_frames = sprite.get_sprite_frames()
	return sprite_frames.get_frame_texture(state, 0)

func _on_viewport_change() -> void:
	viewport_height = get_viewport_rect().size.y

func _ingredient_checker() -> bool:
	if ingredient_resource == null:
		return false
	return true
