extends Control

@onready var field_score = $HBoxContainer/MarginContainer/VBoxContainer/Field_Score
@onready var field_highscore = $HBoxContainer/MarginContainer2/VBoxContainer2/Field_Highscore
@onready var field_lives = $HBoxContainer2/MarginContainer2/VBoxContainer/Field_Lives

func _ready():
	ScoreManager.score_changed.connect(score_changed)
	ScoreManager.lives_changed.connect(lives_changed)
	
func score_changed(points):	
	field_score.text = str(points)

func lives_changed(lives):
	field_lives.text = "Lives: " + str(lives)
