extends "res://engine/entity.gd"

var movetimer_length : int = 15
var movetimer : int = 0
var DAMAGE : int = 1

func _ready():
	$anim.play("default")
	movedir = dir.rand()
	speed = 0
	
func _physics_process(delta):
	movement_loop()
	damage_loop()
	if movetimer >0:
		movetimer -= 1
	if movetimer == 0 || is_on_wall():
		movedir = dir.rand()
		movetimer = movetimer_length