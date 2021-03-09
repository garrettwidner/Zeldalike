extends KinematicBody2D

var player = null
var motivation = 3
var parrytake = 1
var dodgetake = 1

var knockdirection : Vector2 = dir.CENTER
var knocktimer = 0.0
var knockduration = .3
var knockstrength = 105
var is_knocked = false

var wanderspeed : int = 1
var movespeed : int = 35
var attackspeed : int = 40

var current_speed

var _velocity = Vector2.ZERO
var movedir = Vector2.ZERO

var is_chasing = false

var is_fleeing = false
var flightspeed = 70
var flighttimer = 1.2

var wait_time = 0

var line_attack_has_wound_up = false
var line_attack_direction = Vector2.ZERO
var line_attack_reverse_direction = Vector2.ZERO

var line_attack_windup_time = .2
var line_attack_windup_speed = 90
var line_attack_speed = 100
var line_attack_duration = .7
var line_attack_timer = 0


var base_alpha = .4
var max_alpha = .7
var max_alpha_change = .35
var old_alpha = 0
var new_alpha = 0

var alpha_step = 0

var alpha_switch_timer = 0
var max_alpha_switch_time = 1.6
var min_alpha_switch_time = .5

var is_positive = false

# get a number of seconds .5 to 1.5 and a new alpha +- 6.8

var state = "waiting"

#var base_perimeter_size = 80
#var perimeter_stddv = 1.7

func _ready():
	set_speed(wanderspeed)
	old_alpha = base_alpha
	$oversprite.modulate.a = base_alpha
	pass 

func _process(delta):
	
	run_alpha_animation(delta)
	
	match state:
		"waiting":
			waiting()
		"fleeing":
			fleeing(delta)
		"knocked":
			knocked(delta)
		"chasing":
			chasing()
		"line_attacking":
			line_attacking(delta)
	pass
	
func run_alpha_animation(delta):
	var new_modulate = $oversprite.modulate.a + (alpha_step * delta)
	$oversprite.modulate.a = new_modulate
	print($oversprite.modulate.a)
	alpha_switch_timer = alpha_switch_timer - delta
	if alpha_switch_timer <= 0:
		$oversprite.modulate.a = new_alpha
		old_alpha = new_alpha
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		alpha_switch_timer = rng.randf_range(min_alpha_switch_time, max_alpha_switch_time)
		print("alpha switched! new time is " + String(alpha_switch_timer))
		
		if is_positive:
			is_positive = false
			new_alpha = base_alpha + rng.randf_range(0, max_alpha_change)
		else:
			is_positive = true
			new_alpha = base_alpha - rng.randf_range(0, max_alpha_change)
		if new_alpha > max_alpha:
			new_alpha = max_alpha
		
		print("old alpha is " + String(old_alpha) + " and new alpha is: " + String(new_alpha))
			
		var alpha_difference = new_alpha - old_alpha 
		alpha_step = alpha_difference / alpha_switch_timer
		print("alpha step is: " + String(alpha_step))
	pass
#	print("CURRENT MODULATE: " + String($oversprite.modulate.a))
	
# --------WAIT
func set_state_waiting(time = 0):
	if time <= 0:
		pass
	state = "waiting"
	pass

func waiting():
	
	pass

#---------FLEE
func set_state_fleeing():
	state = "fleeing"
	pass
	
func fleeing(delta):
	var flightdirection = get_direction_towards_player()
	_velocity = flightdirection.normalized() * flightspeed
	move_and_slide(_velocity)
	flighttimer = flighttimer - delta
	if flighttimer <= 0:
		queue_free()
	pass

#---------KNOCK
func set_state_knocked():
	state = "knocked"
	knockdirection = get_direction_towards_player()
	knocktimer = knockduration
	pass
	
func knocked(delta):
	_velocity = knockdirection.normalized() * knockstrength
	knocktimer -= delta
	if knocktimer <= 0:
		knocktimer = 0
		state = "chasing"
	
	move_and_slide(_velocity)
	pass

#---------CHASE
	
func set_state_chasing():
	state = "chasing"
	set_speed(movespeed)
	pass
	
func chasing():
	move_towards_player()

#---------LINE ATTACK

func set_state_line_attacking():
	state = "line_attacking"
	line_attack_direction = get_direction_towards_player()
	line_attack_reverse_direction = -line_attack_direction
	line_attack_has_wound_up = false
	line_attack_timer = line_attack_windup_time
	print("Starting line attack")
	print("Direction towards player: " + String(line_attack_direction))
	print("Direction away from player: " + String(line_attack_reverse_direction))
	
func line_attacking(delta):
	if !line_attack_has_wound_up:
		print("Is winding up")
		_velocity = line_attack_direction * line_attack_windup_speed
		move_and_slide(_velocity)
		line_attack_timer = line_attack_timer - delta
		if line_attack_timer <= 0:
			line_attack_timer = line_attack_duration
			line_attack_has_wound_up = true
			print("Finished winding up")
		pass
		
	else:
		print("is line attacking")
		_velocity = line_attack_reverse_direction * line_attack_speed
		move_and_slide(_velocity)
		line_attack_timer = line_attack_timer - delta
		if line_attack_timer <= 0:
			set_state_chasing()
			print("Finished with line attack")
		pass
	pass
	
#----------------           ------------------------	

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
	
func _on_AttackArea_body_entered(body):
	if body.name == "player":
		start_area_attack()
	pass 

func start_area_attack():
	print("player entered danger zone")
	if state == "chasing":
		set_state_line_attacking()
	pass

func _on_PerimeterArea_body_entered(body):
	if body.name == "player":
		player = body
		set_state_chasing()
	pass 

func _on_PerimeterArea_body_exited(body):
#	if body.name == "player":
#		set_state_waiting()
	pass 

func set_speed(new_speed):
	current_speed = new_speed

func _on_Hitbox_body_entered(body):
#	print("simple_deoful got hit by " + body.name)
	pass

func _on_Hitbox_area_entered(area):
	set_state_knocked()
	get_parried()
		

func get_parried():
	motivation = motivation - parrytake
	check_for_flight()
	pass
	
func got_dodged():
	
	pass
	
func check_for_flight():
	if motivation <= 0:
		set_state_fleeing()
		pass
	pass
	
func get_direction_towards_player():
	return (global_transform.origin - player.global_transform.origin).normalized()
	
	
func start_hitfade():
	
	pass	
	

	
	
	
	