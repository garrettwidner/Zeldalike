extends KinematicBody2D

var player = null
var motivation = 3
var parrytake = 1
var dodgetake = 1

var knockdirection : Vector2 = dir.CENTER
var knocktimer = 0.0
var knockduration = .3
var knockstrength = 105

var wanderspeed : int = 1
var movespeed : int = 35
var attackspeed : int = 40

var current_speed

var _velocity = Vector2.ZERO
var movedir = Vector2.ZERO

var is_chasing = false

var is_fleeing = false
var flightspeed = 45
var flighttimer = 1.2

#var base_perimeter_size = 80
#var perimeter_stddv = 1.7

func _ready():
	set_speed(wanderspeed)
	pass 

func _process(delta):
	if is_fleeing:
		flee(delta)
	elif knocktimer > 0:
		get_knocked_away(delta)
	elif is_chasing:
		move_towards_player()
	
	pass

func begin_chase():
	is_chasing = true
	set_speed(movespeed)
	pass
	
func end_chase():
	is_chasing = false
	pass

func move_towards_player():
	if player != null:
		move_towards_position(player.global_position)
	pass
	
func move_towards_position(target_position):
	_velocity = steering.follow(
			_velocity,
			global_position,
			target_position,
			current_speed
			)

	move_and_slide(_velocity)
	
func get_knocked_away(delta):
	_velocity = knockdirection.normalized() * knockstrength
	knocktimer -= delta
	if knocktimer <= 0:
		knocktimer = 0
	
	move_and_slide(_velocity)
	pass

func _on_AttackArea_body_entered(body):
	
	pass 


func _on_PerimeterArea_body_entered(body):
	if body.name == "player":
		player = body
		begin_chase()
	pass 


func _on_PerimeterArea_body_exited(body):
	if body.name == "player":
		end_chase()
	pass 

func set_speed(new_speed):
	current_speed = new_speed

func _on_Hitbox_body_entered(body):
#	print("simple_deoful got hit by " + body.name)
	pass

func _on_Hitbox_area_entered(area):
	start_knock(area)
	got_parried()

func start_knock(area):
	knockdirection = global_transform.origin - player.global_transform.origin
	knocktimer = knockduration	

func got_parried():
	motivation = motivation - parrytake
	check_for_flight()
	pass
	
func got_dodged():
	
	pass
	
func check_for_flight():
	if motivation <= 0:
		is_fleeing = true
		pass
	pass
	
func flee(delta):
	var flightdirection = global_transform.origin - player.global_transform.origin
	_velocity = flightdirection.normalized() * flightspeed
	move_and_slide(_velocity)
	flighttimer = flighttimer - delta
	if flighttimer <= 0:
		queue_free()
	pass
	
	
	
	
	
	
	