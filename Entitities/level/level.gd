extends Node

class_name Level

@onready var tilemap: TileMapLayer = $"Walls"
@export var cell_size = 20

var astar_grid : AStarGrid2D

func _ready():
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tilemap.get_used_rect()
	astar_grid.cell_size = Vector2(cell_size, cell_size)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.jumping_enabled = true
	astar_grid.update()
	
	for x in tilemap.get_used_rect().size.x:
		for y in tilemap.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + tilemap.get_used_rect().position.x,
				y + tilemap.get_used_rect().position.y
			)
			
			var tile_data = tilemap.get_cell_source_id(tile_position)
			if tile_data != -1:
				astar_grid.set_point_solid(tile_position)
	

func convert_to_grid(pos : Vector2) -> Vector2i:
	return tilemap.local_to_map(pos)
		
func navigate(from : Vector2i, to: Vector2i):
	if not astar_grid.is_in_boundsv(from) or not astar_grid.is_in_boundsv(to):
		print("Navigation error: point out of bounds")
		return []
	
	if astar_grid.is_point_solid(from) or astar_grid.is_point_solid(to):
		print("Navigation error: point is solid")
		return []
		
	var id_path = astar_grid.get_id_path(from, to, true)
	return id_path

func get_next_tile(from_pos: Vector2, to_pos: Vector2) -> Vector2i:
	var from_grid = convert_to_grid(from_pos)
	var to_grid = convert_to_grid(to_pos)
	var path = navigate(from_grid, to_grid)
	
	if path.size() > 1:
		return path[1]  # Return next step (path[0] is current position)
	return from_grid  # No path found, stay put

func is_walkable(tile: Vector2i) -> bool:
	return tilemap.get_cell_source_id(tile) == -1	
