extends "res://engine/entity.gd"

var collision_increment = 0
var collision_state 
var hits_enemy = true

func _ready():
	speed = 25
	pass 
	
func increment_collision_state():
	collision_increment = collision_increment + 1
	if collision_increment > 2:
		collision_increment = 0

	match collision_increment:
		0:
			collision_state = 0
			set_collision_mask_bit(coll.LAYER.GROUND, false)
			set_collision_mask_bit(coll.LAYER.MOUNTAIN, false)
			print("Collision test player should now collide only with -NO- objects")
			
		1:
			collision_state = coll.LAYER.GROUND
			set_collision_mask_bit(coll.LAYER.GROUND, true)
			set_collision_mask_bit(coll.LAYER.MOUNTAIN, false)
			print("Collision test player should now collide only with -ground- objects")
		2:
			collision_state = coll.LAYER.MOUNTAIN
			set_collision_mask_bit(coll.LAYER.GROUND, false)
			set_collision_mask_bit(coll.LAYER.MOUNTAIN, true)
			print("Collision test player should now collide only with -mountain- objects")
			
	
	
	
func _process(delta):
	if Input.is_action_just_pressed("action"):
		increment_collision_state()
#		print("Player now collides with " + state_to_string(collision_state))
		pass
		
	elif Input.is_action_just_pressed("sack"):
		hits_enemy = !hits_enemy
		set_collision_mask_bit(coll.LAYER.ENEMY, hits_enemy)
		set_collision_layer_bit(coll.LAYER.PLAYER, hits_enemy)
		print("Collision test player hits enemy: " + String(hits_enemy))
		print("You are a player: " + String(!hits_enemy))
		pass
	
func _physics_process(delta):
	movedir = dir.direction_from_input()
	movement_loop()