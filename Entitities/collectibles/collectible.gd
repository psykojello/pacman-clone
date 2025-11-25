extends Area2D
class_name Collectible

signal collected(points)

@export var points: int = 10

func _ready():
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body.name == "Pacman":
		on_collected(body)
		collected.emit(points)
		queue_free()
		
#Virtual function, override in child classes
func on_collected(body):
	pass
