extends Node

const LEFT : Vector2 = Vector2(-1,0)
const RIGHT : Vector2 = Vector2(1,0)
const UP : Vector2 = Vector2(0,-1)
const DOWN : Vector2 = Vector2(0,1)
const CENTER : Vector2 = Vector2(0,0)

func rand():
	var d = randi() % 4 + 1
	match d:
		1: 
			return LEFT
		2: 
			return RIGHT
		3: 
			return UP
		4: 
			return DOWN
			
func closest_cardinal(v : Vector2):
	if v == Vector2(0,0):
		return v
	else:
		if abs(v.x) > abs (v.y):
			if v.x > 0:
				return dir.RIGHT
			else:
				return dir.LEFT
		else:
			if v.y > 0: 
				return dir.DOWN
			else:
				return dir.UP