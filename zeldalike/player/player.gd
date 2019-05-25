extends KinematicBody2D

var speed : float = 20

func _process(delta):
	var input: Vector2 = Vector2(0,0)
	
	if Input.is_action_pressed("left"):
		input.x = -1
	elif Input.is_action_pressed("right"):
		input.x = 1
	else:
		input.x = 0
	
	if Input.is_action_pressed("up"):
		input.y = -1
	elif Input.is_action_pressed("down"):
		input.y = 1
	else:
		input.y = 0
	
	move_and_slide(input * speed, Vector2(0,-1))
	
	
	
	
	pass