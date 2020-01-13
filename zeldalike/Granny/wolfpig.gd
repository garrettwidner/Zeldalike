extends "res://engine/entity.gd"

var movetimer_length : int = 25
var movetimer : int = 0
var DAMAGE : int = 1
var damagetaker 
var collider

func _ready():
	$anim.play("left")
	movedir = dir.rand()
	speed = 30

	collider = get_node("CollisionShape2D")
	
func _process(delta):
	if movedir == dir.LEFT:
		$anim.play("left")
	elif movedir == dir.RIGHT:
		$anim.play("right")
	pass
	
func _physics_process(delta):
	movement_loop()
	damage_loop()
	if movetimer >0:
		movetimer -= 1
	if movetimer == 0 || is_on_wall():
		movedir = dir.rand()
		movetimer = movetimer_length
