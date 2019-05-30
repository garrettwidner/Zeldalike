extends "res://engine/entity.gd"

var input : Vector2 = dir.CENTER

func _ready():
	speed = 33

func _process(delta):
	set_movedir()
	set_facingdir()
	set_spritedir()
	
	if movedir != Vector2(0,0):
		switch_anim("walk")
	else:
		switch_anim("idle")
	
	movement_loop()
	
func set_movedir():
	var LEFT : bool = Input.is_action_pressed("left")
	var RIGHT : bool = Input.is_action_pressed("right")
	var UP : bool = Input.is_action_pressed("up")
	var DOWN : bool = Input.is_action_pressed("down")
	
	if LEFT:
		movedir.x = -1
	elif RIGHT:
		movedir.x = 1
	else:
		movedir.x = 0
	
	if UP:
		movedir.y = -1
	elif DOWN:
		movedir.y = 1
	else:
		movedir.y = 0
