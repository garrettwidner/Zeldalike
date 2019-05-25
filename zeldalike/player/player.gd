extends KinematicBody2D

var speed : float = 33
var input : Vector2 = Vector2(0,0)
onready var anim : AnimationPlayer = $anim
var facingdir : Vector2 = Vector2(0,0)

func _process(delta):
	set_input()
	set_facing_dir()
	animate()
	
	
	move_and_slide(input * speed, Vector2(0,-1))
	
	
	
func set_input():
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
		
func set_facing_dir():
	if input.x == 0 and input.y == 0:
		return null
	elif input.x == 1:
		facingdir = dir.RIGHT
	elif input.x == -1:
		facingdir = dir.LEFT
	elif input.y == 1:
		facingdir = dir.DOWN
	elif input.y == -1: 
		facingdir = dir.UP
		
func animate():
	match facingdir:
		dir.UP:
			anim.play("walkup")
		dir.DOWN:
			anim.play("walkdown")
		dir.LEFT:
			anim.play("walkleft")
		dir.RIGHT:
			anim.play("walkright")
	if input.x == 0 and input.y == 0:
		anim.stop(true)
	
	pass