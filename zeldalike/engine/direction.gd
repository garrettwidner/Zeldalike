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
			
func randhor():
	var d = randi() % 2 + 1
	match d:
		1: 
			return LEFT
		2: 
			return RIGHT
			
func string_from_direction(direction):
	match direction:
		dir.LEFT:
			return "left"
		dir.RIGHT:
			return "right"
		dir.UP:
			return "up"
		dir.DOWN:
			return "down"
						

func opposite(direction):
	match direction:
		dir.LEFT:
			return dir.RIGHT
		dir.RIGHT:
			return dir.LEFT
		dir.UP:
			return dir.DOWN
		dir.DOWN:
			return dir.UP

func l_r_direction_from_input():
	var direction = direction_from_input()
	direction.y = 0
	return direction
	
func u_d_direction_from_input():
	var direction = direction_from_input()
	direction.x = 0
	return direction
	

func direction_from_input():
	
	var direction = Vector2()
	
	var LEFT : bool = Input.is_action_pressed("left")
	var RIGHT : bool = Input.is_action_pressed("right")
	var UP : bool = Input.is_action_pressed("up")
	var DOWN : bool = Input.is_action_pressed("down")
	
	if LEFT:
		direction.x = -1
	elif RIGHT:
		direction.x = 1
	else:
		direction.x = 0
	
	if UP:
		direction.y = -1
	elif DOWN:
		direction.y = 1
	else:
		direction.y = 0
		
	return direction
	
func direction_just_pressed_from_input():
	var direction = Vector2()
	
	var LEFT : bool = Input.is_action_just_pressed("left")
	var RIGHT : bool = Input.is_action_just_pressed("right")
	var UP : bool = Input.is_action_just_pressed("up")
	var DOWN : bool = Input.is_action_just_pressed("down")
	
	if LEFT:
		direction.x = -1
	elif RIGHT:
		direction.x = 1
	else:
		direction.x = 0
	
	if UP:
		direction.y = -1
	elif DOWN:
		direction.y = 1
	else:
		direction.y = 0
		
	return direction
	
			
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