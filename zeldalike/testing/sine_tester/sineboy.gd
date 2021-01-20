extends "res://engine/entity.gd"

export var jumparea_path : NodePath
var jumparea

var jumpstartpos
var jumpendpos
var jumpweight
var jumpspeed = 0.05

var jump_height_multiplier = 20
var set_speed = 40

var is_jumping = false

func _ready():
	var jumparea_string = helper.nodepath_to_usable_string_path("/root/level", jumparea_path)
	print(jumparea_string)
	
	jumparea = get_node(jumparea_string)
	print("Jumparea name is " + jumparea.name)
	speed = set_speed


func _physics_process(delta):
	pass
		
func _process(delta):
	if !is_jumping:
		
		movedir = dir.direction_from_input()
		set_directionality(movedir)
		movement_loop()
		
		if Input.is_action_just_pressed("action"):
			start_jump()
			
		
	else:
		print("Should be jumping now")
		continue_jump()
		pass
		
func start_jump():
	jumpstartpos = global_position
	jumpendpos = jumparea.global_position
	jumpweight = 0
	is_jumping = true
	
	pass
	
func continue_jump():
	global_position  = jumpstartpos.linear_interpolate(jumpendpos, jumpweight)
	
	var altered_weight = jumpweight * 3.14
	
	var sine_y = sin(altered_weight) * jump_height_multiplier
	print(sine_y)
	global_position = Vector2(global_position.x, global_position.y - sine_y)
	
	
	jumpweight += jumpspeed
	if jumpweight >= 1:
		is_jumping = false
		print("Ended jump")
	pass
	
	
	
	
	
	
	
	
	