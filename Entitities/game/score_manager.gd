extends Node

var score = 0
var lives = 3
var level = 1
var total_dots = 100
var dots_remaining = 100

signal score_changed(score)
signal lives_changed(lives)
signal game_over()
signal level_completed()

func add_score(points):
	score += points
	score_changed.emit(score)
	
func lose_life():
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		game_over.emit()
	
func reset_level():
	pass
	
func collect_dot():
	dots_remaining -= 1
	if dots_remaining <= 0:
		level_complete()
	
func level_complete():
	print("level_complete!")
	level_completed.emit()	
