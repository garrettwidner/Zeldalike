extends "res://engine/entity.gd"

var movetimer_length : int = 60
var movetimer : int = 0
var DAMAGE : int = 1
var damagetaker 
var collider

func _ready():
	$anim.play("left")
	movedir = dir.randhor()
	speed = 40

	collider = get_node("CollisionShape2D")
	
	
func change_anim():
	if movedir == dir.LEFT:
		$anim.play("left")
	elif movedir == dir.RIGHT:
		$anim.play("right")
	
func _physics_process(delta):
	movement_loop()
	damage_loop()
	if movetimer >0:
		movetimer -= 1
	if movetimer == 0 || is_on_wall():
		movedir = dir.randhor()
		change_anim()
		movetimer = movetimer_length
