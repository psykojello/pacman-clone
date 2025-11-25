extends Control

@onready var gameOverControl = $"Game Over"

func _ready():
	gameOverControl.visible = false
	ScoreManager.game_over.connect(show_game_over)
	
func show_game_over():
	gameOverControl.visible = true
	
