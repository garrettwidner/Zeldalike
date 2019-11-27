extends KinematicBody2D

var TYPE : String = ""
const DAMAGE : int = 1

#how many of each item can be active in scene at once (ex 3 bombs)
var maxamount : int = 2
var speed = 130
var is_setup = false
var move_direction
var arrow_deletion_time = 1.45

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
	$Timer.wait_time = arrow_deletion_time
	$Timer.start()
	is_setup = true
	
func _process(delta):
	if is_setup:
		move_and_slide(move_direction * speed)

func _on_Timer_timeout():
	queue_free()
