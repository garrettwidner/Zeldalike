extends KinematicBody2D

var speed : float = 33
var input : Vector2 = dir.NULL
onready var anim : AnimationPlayer = $anim
var facingdir : Vector2 = dir.DOWN

var movedir : Vector2 = dir.NULL
var spritedir : String = ""

func _process(delta):
	set_input()
	set_movedir()
	set_facingdir()
	set_spritedir()
	
	
	if movedir != Vector2(0,0):
		switch_anim("walk")
	else:
		switch_anim("idle")
	
	movement_loop()
	
func set_input():
	var LEFT : bool = Input.is_action_pressed("left")
	var RIGHT : bool = Input.is_action_pressed("right")
	var UP : bool = Input.is_action_pressed("up")
	var DOWN : bool = Input.is_action_pressed("down")
	
	if LEFT:
		input.x = -1
	elif RIGHT:
		input.x = 1
	else:
		input.x = 0
	
	if UP:
		input.y = -1
	elif DOWN:
		input.y = 1
	else:
		input.y = 0

func set_movedir():
	if input.x == 0 and input.y == 0:
		movedir = dir.NULL
	elif input.x == 1:
		movedir = dir.RIGHT
	elif input.x == -1:
		movedir = dir.LEFT
	elif input.y == 1:
		movedir = dir.DOWN
	elif input.y == -1: 
		movedir = dir.UP

func set_facingdir():
	if movedir != Vector2(0,0):
		facingdir = movedir

func set_spritedir():
	match facingdir:
		dir.UP:
			spritedir = "up"
		dir.DOWN:
			spritedir = "down"
		dir.LEFT:
			spritedir = "left"
		dir.RIGHT:
			spritedir = "right"

func switch_anim(animation):
	var nextanim : String = animation + spritedir
	if anim.current_animation != nextanim:
		anim.play(nextanim)

func movement_loop():
	var motion = input.normalized() * speed
	move_and_slide(motion, Vector2(0,0))
	