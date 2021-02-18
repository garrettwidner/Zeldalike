extends KinematicBody2D


var player
var position_past_player
var _velocity = Vector2.ZERO
var move_speed = 40
var attack_speed = 80
var current_speed = 0

var distance_leeway = 2
var is_overshooting = false
var overshoot_distance = 60
var overshoot_position = null

var attack_endpoint = null
var is_attacking = false

var player_left_area = false

var fade_speed = 3
var should_fade = true

func _ready():
	$AnimationPlayer.play("idle")
	current_speed = move_speed
	pass
	
func _physics_process(delta):
	if player != null:
		if is_attacking:
			move_towards_position(attack_endpoint)
			if global_position.distance_to(attack_endpoint) < distance_leeway:
				end_attack_pattern()
		else:
			move_towards_position(player.global_position)
			if player_left_area:
				player = null
				player_left_area = false
	

		pass
		
func fade_out_and_disappear(delta):
	$Sprite.modulate.a = $Sprite.modulate.a - (delta * fade_speed)
	pass

func move_towards_position(target_position):
	_velocity = steering.follow(
			_velocity,
			global_position,
			target_position,
			current_speed
			)
	move_and_slide(_velocity)
	pass


func _on_SenseArea_body_entered(body):
	if body.name == "player":
		print("Player entered")
		player = body
		current_speed = move_speed
	pass # Replace with function body.


func _on_SenseArea_body_exited(body):
	if body.name == "player":
		print("Player exited (but not cleared)")
		player_left_area = true
	pass # Replace with function body.


func _on_AttackArea_body_entered(body):
	if body.name == "player":
		print("Player entered ATTACK area")
		start_attack_pattern()
	pass # Replace with function body.

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
	if player_left_area:
		player = null
		player_left_area = false
	pass

func _on_AttackArea_body_exited(body):
	pass # Replace with function body.
