extends KinematicBody2D

var TYPE : String = ""
const DAMAGE : int = 1

#how many of each item can be active in scene at once (ex 3 bombs)
var maxamount : int = 2
var speed = 130
var is_setup = false
var move_direction
var deletion_time_flying = 1.45
var deletion_time_enemy = .02
var deletion_time_object = 1.3
var has_hit = false
var new_parent

#LOOK---------------------------
#TODO: Destroy self if offscreen
#LOOK---------------------------


func _ready():
	TYPE = "PLAYER"

func setup(direction):
	match direction:
		dir.RIGHT:
			pass
		dir.LEFT: 
			rotation_degrees = 180
		dir.DOWN:
			rotation_degrees = 90
		dir.UP:
			rotation_degrees = 270
			
	move_direction = direction
	$Timer.wait_time = deletion_time_flying
	$Timer.start()
	is_setup = true
	
func _process(delta):
	if is_setup:
		if !has_hit:
			move_and_slide(move_direction * speed)
		else:
			reparent(new_parent)

func _on_Timer_timeout():
	queue_free()

#Reparents arrow to what it hits so it 'sticks' to it
func reparent(parent):
	if get_parent().name == parent.name:
		pass
	else:
		var start_position = global_position
#		print("Position before reparent: ")
		print(global_position)
#		print("Reparented arrow to " + parent.name)
		get_parent().remove_child(self)
		parent.add_child(self)
		global_position = start_position
#		print("Position after reparent: ")
#		print(global_position)

func hit_object(object_parent, deletion_time):
	has_hit = true
	new_parent = object_parent
	$Timer.stop()
	$Timer.wait_time = deletion_time
	$Timer.start()

func _on_Area2D_body_entered(body):
	if(!("arrow" in body.name) && !("player" in body.name)):
		print("Arrow hit body " + body.name)
		hit_object(body, deletion_time_object)
		pass

func _on_Area2D_area_shape_entered(area_id, area, area_shape, self_shape):
#	print("Arrow hit " + area.get_parent().name)
	var area_parent = area.get_parent()
	if area_parent.get("TYPE") != null:
		if area_parent.get("TYPE") == "ENEMY":
			hit_object(area_parent, deletion_time_enemy)
	
