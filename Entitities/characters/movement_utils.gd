class_name MovementUtils

static func get_tile_center(tilemap: TileMapLayer, position: Vector2) -> Vector2:
	var tile_coords = tilemap.local_to_map(position)	
	return tilemap.map_to_local(tile_coords)
	
static func is_walkable(tilemap: TileMapLayer, tile_coords: Vector2i) -> bool:
	var tile_data = tilemap.get_cell_source_id(tile_coords)
	return tile_data == -1
	
static func wrap_position(pos: Vector2, bounds: Rect2) -> Vector2:
	
	var wrapped_pos = pos
	if pos.x < bounds.position.x:
		wrapped_pos.x = bounds.end.x
	elif pos.x > bounds.end.x:
		wrapped_pos.x = bounds.position.x
	
	if pos.y < bounds.position.y:
		wrapped_pos.y = bounds.end.y
	elif pos.y > bounds.end.y:
		wrapped_pos.y = bounds.position.y
	
	return wrapped_pos

# Check if position is centered on a tile
static func is_centered_on_tile(tilemap: TileMapLayer, position: Vector2, speed: float, delta: float) -> bool:
	var tile_center = get_tile_center(tilemap, position)
	var distance = position.distance_to(tile_center)
	return distance < speed * delta * 1.5

# Get map bounds from tilemap
static func get_map_bounds(tilemap: TileMapLayer, tile_size: int) -> Rect2:
	var used_rect = tilemap.get_used_rect()
	
	return Rect2(
		used_rect.position.x * tile_size,
		used_rect.position.y * tile_size,
		used_rect.size.x * tile_size,
		used_rect.size.y * tile_size
	)
