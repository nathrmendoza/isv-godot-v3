class_name UtilsInputQueries

static func check_topmost_clicked(node: Node2D, event_position: Vector2) -> bool:
	var space = node.get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = event_position
	query.collision_mask = node.collision_mask
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var results = space.intersect_point(query, 1)
	return results.is_empty() or results[0].collider == node
