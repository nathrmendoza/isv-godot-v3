class_name UtilsInputQueries

# Add a static reference to our debug drawer
static var debug_drawer: Node2D

static func check_topmost_clicked(node: Node2D, event_position: Vector2) -> bool:
	var space = node.get_world_2d().direct_space_state
	
	# Use a small circle shape instead of a point for more reliable detection
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 10  # Small radius but not too small
	query.shape = shape
	query.transform = Transform2D(0, event_position)
	query.collision_mask = 1
	query.collide_with_bodies = true
	query.collide_with_areas = true

	var results = space.intersect_shape(query, 1)

	return results.size() > 0 and results[0].collider == node
