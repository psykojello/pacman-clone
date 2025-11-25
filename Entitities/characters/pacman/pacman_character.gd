extends CharacterBody2D
class_name Pacman

@onready var tilemap = get_node("../TileMap/Walls")  # Your TileMapLayer with collisions
@onready var animated_sprite = $AnimatedSprite2D  # Reference to the animation node
@onready var game: Game= get_node("..")

var speed = 100.0  # pixels per second
var tile_size = 20  # Your tile size in pixels

var current_direction = Vector2.LEFT  # Start moving left
var queued_direction = Vector2.ZERO  # No queued input yet

func die():
	game.input_allowed = false
	
func wake_up():
	game.input_allowed = true
	current_direction = Vector2.LEFT
	queued_direction = Vector2.ZERO

func _physics_process(delta):
	if not game.input_allowed:
		return
	# Handle input - queue the direction
	if Input.is_action_just_pressed("ui_right"):
		queued_direction = Vector2.RIGHT
	elif Input.is_action_just_pressed("ui_left"):
		queued_direction = Vector2.LEFT
	elif Input.is_action_just_pressed("ui_down"):
		queued_direction = Vector2.DOWN
	elif Input.is_action_just_pressed("ui_up"):
		queued_direction = Vector2.UP
	
	# Check if we're at an intersection (centered on a tile)
	if is_centered_on_tile():
		# Try to execute queued direction if it's walkable
		if queued_direction != Vector2.ZERO and can_move_in_direction(queued_direction):
			current_direction = queued_direction
			queued_direction = Vector2.ZERO  # Clear the queue
			snap_to_tile_center()  # Ensure perfect alignment
		# If current direction is blocked, stop
		elif not can_move_in_direction(current_direction):
			current_direction = Vector2.ZERO
	
	# If stopped and have queued input, try it immediately
	if current_direction == Vector2.ZERO and queued_direction != Vector2.ZERO:
		if can_move_in_direction(queued_direction):
			current_direction = queued_direction
			queued_direction = Vector2.ZERO
			snap_to_tile_center()
		
	# Move in current direction
	velocity = current_direction * speed
	move_and_slide()
	
	# Update animation based on movement
	update_animation()

func update_animation():
	# If not moving, pause the animation
	if current_direction == Vector2.ZERO:
		animated_sprite.pause()
		return
	
	# Play appropriate animation based on direction
	if current_direction == Vector2.RIGHT:
		animated_sprite.play("moveRight")
	elif current_direction == Vector2.LEFT:
		animated_sprite.play("moveLeft")
	elif current_direction == Vector2.UP:
		animated_sprite.play("moveUp")
	elif current_direction == Vector2.DOWN:
		animated_sprite.play("moveDown")

func is_centered_on_tile() -> bool:
	# Check if we're close enough to the center of a tile
	var tile_center = get_tile_center(position)
	var distance = position.distance_to(tile_center)
	return distance < speed * get_physics_process_delta_time() * 1.5

func get_tile_center(pos: Vector2) -> Vector2:
	# Get the grid coordinates of the tile we're on
	var tile_coords = tilemap.local_to_map(pos)
	# Convert back to world position (center of tile)
	return tilemap.map_to_local(tile_coords)

func snap_to_tile_center():
	# Snap position to exact tile center for perfect alignment
	position = get_tile_center(position)

func can_move_in_direction(direction: Vector2) -> bool:
	# Get current tile coordinates
	var current_tile = tilemap.local_to_map(position)
	# Get the tile we want to move to
	var target_tile = current_tile + Vector2i(direction)
	
	# Check if target tile has a wall
	# Since "Walls" layer only has walls, if there's a tile = wall = blocked
	var tile_data = tilemap.get_cell_source_id(target_tile)
	
	# -1 means no tile = empty = walkable
	# Any other value means there's a wall tile = blocked
	return tile_data == -1
