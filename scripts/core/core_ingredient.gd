extends RigidBody2D
class_name CoreIngredient

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_body: CollisionShape2D = $CollisionShape2D

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

var is_cooked: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
	if _init_validation() == false: queue_free()
	input_pickable = true
	viewport_height = get_viewport_rect().size.y
	offscreen_margin = collision_body.shape.size.y
	get_tree().root.size_changed.connect(_on_viewport_change)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_draggable:
			if _check_pointer_within_shape(event.global_position):
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
			is_dragging = false
			freeze = false
			apply_central_impulse(pointer_velocity * throw_force_multiplier)
			
	#remove if below boundary
	if global_position.y > viewport_height + offscreen_margin:
		queue_free()

func _grabbing_object(pointer_position: Vector2) -> void:
	if not is_dragging:
		is_dragging = true
		drag_start = pointer_position - global_position
		last_pointer_position = pointer_position
		freeze = true

func _start_cooking(cooking_position: Vector2):
	if not is_cooked:
		is_draggable = false
		global_position = cooking_position
		set_deferred('freeze', true)
		#disable colliding
		set_collision_mask_value(1, false)
		hide()

func _finish_cooking():
	show()
	is_cooked = true
	is_draggable = true
	sprite.animation = 'cooked'
	freeze = false
	_tween_pop_off('right', 500)

func _tween_pop_off(pop_direction: String, pop_strength: int) -> void:
	set_collision_mask_value(1, false)
	var rand_x = randi_range(250, 750)
	match pop_direction:
		'straight':
			apply_central_impulse(Vector2(0, -pop_strength))
		'left':
			apply_central_impulse(Vector2(-rand_x, -pop_strength))
		'right':
			apply_central_impulse(Vector2(rand_x, -pop_strength))
	await get_tree().create_timer(2).timeout
	set_collision_mask_value(1, true)

func _check_pointer_within_shape(point: Vector2) -> bool:
	if collision_body.shape:
		var local_point = to_local(point)
		if collision_body.shape is RectangleShape2D:
			var half_extents = collision_body.shape.size / 2
			return abs(local_point.x) <= half_extents.x and abs(local_point.y) <= half_extents.y
		elif collision_body.shape is CircleShape2D:
			return local_point.length() <= collision_body.shape.radius
		elif collision_body.shape is CapsuleShape2D:
			var half_height = collision_body.shape.height / 2 - collision_body.shape.radius
			#horizontal
			if abs(local_point.y) <= half_height:
				return abs(local_point.y) <= collision_body.shape.radius
			else:
				#vertical
				var circle_center = Vector2(0, sign(local_point.y) * half_height)
				return abs(local_point - circle_center).length() <= collision_body.shape.radius
	#fallback
	return false

func _on_viewport_change() -> void:
	viewport_height = get_viewport_rect().size.y

func _init_validation() -> bool:
	if ingredient_resource == null:
		printerr("Assign an ingredient resource to this instance!")
		return false
	return true
