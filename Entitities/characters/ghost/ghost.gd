extends CharacterBody2D
class_name Ghost

@export var ghost_color: Color = Color.RED
@onready var sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea
@onready var level: Level = get_node("../Level")

enum GHOSTSTATE {NORMAL, SCARED}
var ghost_state = GHOSTSTATE.NORMAL

signal killed_pacman
signal ghost_eaten(points)

func _ready():
	sprite.modulate = ghost_color
	ghost_state = GHOSTSTATE.NORMAL
	detection_area.body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	print("crashed into ", body.name)
	if body.name == "Pacman":
		if ghost_state == GHOSTSTATE.SCARED:
			eaten()
		else:
			print("Collided with pacman!")
			killed_pacman.emit()
			
func eaten():
	ghost_eaten.emit(200)
	#play eaten animation
	#return to ghost house
	#change to eyes only state
	queue_free()
	

func _input(event):
	
	if event.is_action_pressed("NavClicked") == false:
		return
	var from = level.convert_to_grid(position)
	var to = level.convert_to_grid(get_global_mouse_position())
	level.navigate(from, to)
