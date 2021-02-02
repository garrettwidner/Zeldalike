extends Node

const LEFT : Vector2 = Vector2(-1,0)
const RIGHT : Vector2 = Vector2(1,0)
const UP : Vector2 = Vector2(0,-1)
const DOWN : Vector2 = Vector2(0,1)
const CENTER : Vector2 = Vector2(0,0)

func is_cardinal(vector: Vector2):
	if vector == LEFT || vector == RIGHT || vector == UP || vector == DOWN:
		return true
	return false
	
func is_vertical(vector: Vector2):
	if vector == UP || vector == DOWN:
		return true
	return false

func is_horizontal(vector: Vector2):
	if vector == RIGHT || vector == LEFT:
		return true
	return false

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
		dir.CENTER:
			return "center"
		_:
			print("Warning: improper direction passed to function. Must be cardinal.")
			return " - "
						

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
				
func closest_cardinal_or_ordinal(v: Vector2):
	var lateral_vector = dir.CENTER
	var vertical_vector = dir.CENTER
	
	if v == Vector2(0,0):
		return v
	else:
		if v.x > 0:
			lateral_vector = dir.RIGHT
		elif v.x < 0:
			lateral_vector = dir.LEFT
		if v.y > 0:
			vertical_vector = dir.DOWN
		elif v.y < 0:
			vertical_vector = dir.UP
			
		return lateral_vector + vertical_vector
		
#rotates and returns the start vector 90 degrees towards the given direction.
#if a 180 degree rotation is necessary, takes an optional bool to determine if it rotates left or right first
func rotate_90_towards_direction(start: Vector2, towards: Vector2, prioritize_left: bool = true):
	if start == towards:
		return towards

	if is_90_degrees_away(start, towards):
		return towards
		pass
	else:
		var rotation
		if prioritize_left:
			rotation = deg2rad(-90)
		else:
			rotation = deg2rad(90)
		
		var rotated_output = start.rotated(rotation)
		
		return clean_up_rotated_output(rotated_output)
	pass
	
#Godot uses floats for Vector2s, which results in -0 =\= 0. This cleans it for the direction class by casting to ints.
func clean_up_rotated_output(output):
	return Vector2(int(output.x), int(output.y))
	pass
		
func is_90_degrees_away(start: Vector2, comparison: Vector2):
	if is_cardinal(start) && is_cardinal(comparison):
		if (is_vertical(start) && is_horizontal(comparison)) || (is_horizontal(start) && is_vertical(comparison)):
			return true
			pass
		else:
			return false
	return false
		
		
		
		
		
		
		