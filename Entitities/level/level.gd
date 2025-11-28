extends TileMapLayer

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
			if tile_data == 1:
				print(str(tile_position) + " : solid" )
				astar_grid.set_point_solid(tile_position)
			else:
				print(str(tile_position) + " : walkable" )
	

func convert_to_grid(pos : Vector2) -> Vector2i:
	return tilemap.local_to_map(pos)
		
func navigate(from : Vector2i, to: Vector2i):
	var id_path = astar_grid.get_id_path(from, to, true)
	print(id_path)
	#var packedpts : PackedVector2Array
	#for pt in id_path:
		#var pos = tilemap.map_to_local(pt)
		#packedpts.append(pos)
		#draw_circle(pos, 5, Color.RED)
	#
	#
	#draw_multiline(packedpts, Color.RED, 1.0)
	
