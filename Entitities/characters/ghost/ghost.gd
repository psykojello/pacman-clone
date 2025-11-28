extends CharacterBody2D
class_name Ghost

@onready var detection_area = $DetectionArea
@onready var level: Level = get_node("../Level")
@onready var pacman: Pacman = get_node("../Pacman")

enum GHOSTSTATE {NORMAL, SCARED}
enum GHOSTTYPE {BLINKY, PINKY, INKY, CLYDE}

@export var ghost_color: Color = Color.RED
@onready var sprite = $AnimatedSprite2D
@export var ghost_type = GHOSTTYPE.BLINKY

var speed = 95.0  # pixels per second
var map_bounds: Rect2


var ghost_state = GHOSTSTATE.NORMAL
var current_direction = Vector2.LEFT
var queued_direction = Vector2.ZERO
var current_tile : Vector2i

signal killed_pacman
signal ghost_eaten(points)

func _ready():
	sprite.modulate = ghost_color	
	detection_area.body_entered.connect(_on_body_entered)
	map_bounds = MovementUtils.get_map_bounds(level.tilemap, level.cell_size)
	reset_ghost(position)

func reset_ghost(pos: Vector2):
	position = pos
	ghost_state = GHOSTSTATE.NORMAL
	current_direction = Vector2.LEFT
	queued_direction = Vector2.ZERO
	

func _on_body_entered(body):
	if body.name == "Pacman":
		if ghost_state == GHOSTSTATE.SCARED:
			eaten()
		else:
			killed_pacman.emit()
			
func eaten():
	ghost_eaten.emit(200)
	#play eaten animation
	#return to ghost house
	#change to eyes only state
	queue_free()
	
func _physics_process(delta: float) -> void:
	
	var tile : Vector2i = level.convert_to_grid(position)
	if current_tile != tile:
		current_tile = tile
		decide_direction()
		
	move_in_current_direction(delta)

func move_in_current_direction(delta: float):
	
	# Check if we're at an intersection (centered on a tile)
	if MovementUtils.is_centered_on_tile(level.tilemap, position, speed, delta):
		# Try to execute queued direction if it's walkable
		if current_direction != Vector2.ZERO and queued_direction != Vector2.ZERO:
			current_direction = queued_direction
			queued_direction = Vector2.ZERO  # Clear the queue
			snap_to_tile_center()  # Ensure perfect alignment
		
	# Move in current direction
	velocity = current_direction * speed
	move_and_slide()
	
	position = MovementUtils.wrap_position(position, map_bounds)
	
	# Update animation based on movement
	update_animation()

func update_animation():
	## If not moving, pause the animation
	#if current_direction == Vector2.ZERO:
		#animated_sprite.pause()
		return
		
func snap_to_tile_center():
	# Snap position to exact tile center for perfect alignment
	position = MovementUtils.get_tile_center(level.tilemap, position)	

	
func get_valid_directions():
	var valid_dirs = []
		
	if level.is_walkable(current_tile + Vector2i.LEFT) and current_direction != Vector2.RIGHT:
		valid_dirs.append(Vector2.LEFT)
	if level.is_walkable(current_tile + Vector2i.RIGHT) and current_direction != Vector2.LEFT:
		valid_dirs.append(Vector2.RIGHT)		
	if level.is_walkable(current_tile + Vector2i.UP) and current_direction != Vector2.DOWN:
		valid_dirs.append(Vector2.UP)
	if level.is_walkable(current_tile + Vector2i.DOWN) and current_direction != Vector2.UP:
		valid_dirs.append(Vector2.DOWN)		
	
	return valid_dirs
	
func decide_direction():
	var valid_dirs = get_valid_directions()
	if len(valid_dirs) < 1: 
		return
	if len(valid_dirs) == 1:
		queued_direction = valid_dirs[0]
		return
		
	#More than one direction is available - choose the closest one
	var target = calculate_target_tile()
	
	var best_dir = current_direction
	var best_dist = INF
	
	for dir in valid_dirs:
		var test_tile = level.convert_to_grid(position) + Vector2i(dir)
		var dist = test_tile.distance_squared_to(target)
		
		if dist < best_dist:
			best_dist = dist
			best_dir = dir
	queued_direction = best_dir
	
func calculate_target_tile() -> Vector2i:
	
	match ghost_type:
		GHOSTTYPE.BLINKY:
			return level.convert_to_grid(pacman.position)
		GHOSTTYPE.PINKY:
			# 4 tiles ahead of Pacman
			return level.convert_to_grid(pacman.position) + Vector2i(pacman.current_direction) * 4
		# etc.	
	return level.convert_to_grid(pacman.position)
