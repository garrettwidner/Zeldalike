extends KinematicBody2D

export var jumparea_path : NodePath
var jumparea

var jumpstartpos
var jumpendpos
var jumpweight
var jumpspeed

func _ready():
	var jumparea_string = helper.nodepath_to_usable_string_path("/root/level", jumparea_path)
	print(jumparea_string)
	
	jumparea = get_node(jumparea_string)
	print("Jumparea name is " + jumparea.name)


func _physics_process(delta):
	if Input.is_action_just_pressed("action"):
		
		start_jump()
		pass
		
func start_jump():
	jumpstartpos = global_position
	jumpendpos = jumparea.global_position
	
	global_position = jumpendpos
	pass