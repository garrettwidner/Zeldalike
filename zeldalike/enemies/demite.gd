extends "res://engine/entity.gd"

var movetimer_length : int = 15
var movetimer : int = 0
var DAMAGE : int = 1
var hurttimer : int = 0
var hurttimer_length : int = 10

func _ready():
	$anim.play("default")
	movedir = dir.rand()
	speed = 15
	self.connect("health_changed", self, "take_damage")
	
func _physics_process(delta):
	movement_loop()
	damage_loop()
	if movetimer >0:
		movetimer -= 1
	if movetimer == 0 || is_on_wall():
		movedir = dir.rand()
		movetimer = movetimer_length
		
	if $anim.current_animation == "hurt":
		if hurttimer >0:
			hurttimer -=1
		if hurttimer == 0:
			$anim.play("default")
		
func take_damage(health, damage):
	print("Took damage")
	$anim.play("hurt")
	hurttimer = hurttimer_length
	pass