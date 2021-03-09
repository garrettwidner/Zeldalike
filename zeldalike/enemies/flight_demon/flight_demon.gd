extends "res://engine/entity.gd"

var player
var position_past_player
var _velocity = Vector2.ZERO
var move_speed = 45
var attack_speed = 80
var current_speed = 0

var distance_leeway = 2
var is_overshooting = false
var overshoot_distance = 60
var overshoot_position = null

var attack_endpoint = null
var is_attacking = false

var player_left_area = false

var fade_speed = 1.2
var should_fade = false

var base_sense_area_size = 80
var sense_area_stddv = 1.7

func _ready():
	$AnimationPlayer.play("idle")
	current_speed = move_speed
	
	set_random_sensearea_size()
	pass
	
func set_random_sensearea_size():
	$SenseArea/CollisionShape2D.shape = CircleShape2D.new()
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	$SenseArea/CollisionShape2D.shape.radius = base_sense_area_size + rng.randfn(0, sense_area_stddv)
	
	print("New SenseArea size is: " + String($SenseArea/CollisionShape2D.shape.radius))
	
func _physics_process(delta):
	
	speed = current_speed
	
	if should_fade:
		fade_out_and_disappear(delta)
	
	if player != null:
		
		damage_loop()
		
		
		if is_attacking:
			move_towards_position(attack_endpoint)
			if global_position.distance_to(attack_endpoint) < distance_leeway:
				end_attack_pattern()
				resolve_player_left_area()
		else:
			move_towards_position(player.global_position)
			resolve_player_left_area()
		pass
		
func fade_out_and_disappear(delta):
	if $ubersprite.modulate.a <= 0:
		$Particles2D.emitting = false
		$deathtimer.start()
		return
	else:
		$ubersprite.modulate.a = $ubersprite.modulate.a - (delta * fade_speed)
#		print($ubersprite.modulate.a)

func move_towards_position(target_position):
	_velocity = steering.follow(
			_velocity,
			global_position,
			target_position,
			current_speed
			)
	movedir = _velocity
	movement_loop()
			
#	move_and_slide(_velocity)
	pass
	
func resolve_player_left_area():
	if player_left_area:
		player = null
		player_left_area = false
		should_fade = true

func _on_SenseArea_body_entered(body):
	if body.name == "player":
#		print("Player entered")
		player = body
		current_speed = move_speed


func _on_SenseArea_body_exited(body):
	if body.name == "player":
#		print("Player exited (but not cleared)")
		player_left_area = true


func _on_AttackArea_body_entered(body):
	if body.name == "player":
#		print("Player entered ATTACK area")
		start_attack_pattern()

func start_attack_pattern():
	attack_endpoint = global_position + (_velocity.normalized() * overshoot_distance)
	is_attacking = true
	current_speed = attack_speed
	$AnimationPlayer.play("strike")
	rotation = _velocity.angle()
	
func end_attack_pattern():
	is_attacking = false
	current_speed = move_speed
	$AnimationPlayer.play("idle")
	rotation = 0
	pass

func _on_deathtimer_timeout():
	queue_free()
