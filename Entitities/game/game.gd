extends Node2D
class_name Game



@export var pacman_scene : PackedScene
@export var ghost_scene : PackedScene
@export var dot_scene : PackedScene
@export var power_pellet_scene : PackedScene

var DOT_TILE_ID = Vector2i(10,5)
var POWER_PELLET_TILE_ID = Vector2i(13,0)

var input_allowed = true
var pacman : Pacman
var ghosts : Array[Ghost] = []

@onready var tilemap = $Level/Walls
@onready var dots_layer = $Level/Dots
@onready var spawn_pt_pacman = $SpawnPtPacman
@onready var spawn_pt_ghost = $SpawnPtGhost1


func _ready():
	spawn_dots_from_tilemap()
	spawn_pacman()
	spawn_ghosts()
	ScoreManager.game_over.connect(game_over)
	
func spawn_pacman():
	pacman = pacman_scene.instantiate()
	pacman.position = spawn_pt_pacman.position
	add_child(pacman)	
	
func spawn_ghosts():
	var blinky : Ghost = ghost_scene.instantiate()
	blinky.ghost_color = Color.RED
	blinky.position = spawn_pt_ghost.position
	blinky.killed_pacman.connect(_on_pacman_killed)
	blinky.ghost_eaten.connect(_on_ghost_eaten)
	add_child(blinky)
	ghosts.append(blinky)
	
func game_over():
	input_allowed = false
	
func spawn_dots_from_tilemap():
	#Get all tiles in the dots layer
	var used_cells = dots_layer.get_used_cells()
	var total_dots = 0
	for cell in used_cells:
		#get world position of this tile
		var world_pos = dots_layer.map_to_local(cell)
		var atlas_coords = dots_layer.get_cell_atlas_coords(cell)
		
		var collectible
		if atlas_coords == POWER_PELLET_TILE_ID:
			collectible = power_pellet_scene.instantiate()
		else:
			collectible = dot_scene.instantiate()
			
		total_dots += 1
		
		collectible.position = world_pos
		#Connect the signal to handle scoring
		collectible.collected.connect(_on_collectible_collected)
		add_child(collectible)
		
	ScoreManager.total_dots = total_dots
	ScoreManager.dots_remaining = total_dots
		
	dots_layer.visible = false
	
func _on_collectible_collected(points):
	ScoreManager.add_score(points)
	ScoreManager.collect_dot()
	
func _on_pacman_killed():
	pacman.die()
	print("Pacman is DEAD!")
	ScoreManager.lose_life()
	
	if ScoreManager.lives > 0:
		await get_tree().create_timer(2.0).timeout  # Wait for animation
		reset_level()	
	
func _on_ghost_eaten(points):
	ScoreManager.add_score(points)
	
func reset_level():
	pacman.position = spawn_pt_pacman.position
	for ghost in ghosts:
		ghost.position = spawn_pt_ghost.position
	pacman.wake_up()
	
func reset_game():
	pass
