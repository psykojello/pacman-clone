extends CharacterBody2D
class_name Pacman

@onready var tilemap = get_node("../Level/Walls")  # Your TileMapLayer with collisions
@onready var animated_sprite = $AnimatedSprite2D  # Reference to the animation node
@onready var game: Game= get_node("..")

var speed = 100.0  # pixels per second
var tile_size = 20  # Your tile size in pixels
var map_bounds: Rect2

var current_direction = Vector2.LEFT  # Start moving left
var queued_direction = Vector2.ZERO  # No queued input yet

func die():
	game.input_allowed = false
	
func wake_up():
	game.input_allowed = true
	current_direction = Vector2.LEFT
	queued_direction = Vector2.ZERO
	
func _ready():
	map_bounds = MovementUtils.get_map_bounds(tilemap, tile_size)

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
	if MovementUtils.is_centered_on_tile(tilemap, position, speed, delta):
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
	
	position = MovementUtils.wrap_position(position, map_bounds)
	
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


func snap_to_tile_center():
	# Snap position to exact tile center for perfect alignment
	position = MovementUtils.get_tile_center(tilemap, position)

func can_move_in_direction(direction: Vector2) -> bool:
	# Get current tile coordinates
	var current_tile = tilemap.local_to_map(position)
	# Get the tile we want to move to
	var target_tile = current_tile + Vector2i(direction)
	
	return MovementUtils.is_walkable(tilemap, target_tile)
