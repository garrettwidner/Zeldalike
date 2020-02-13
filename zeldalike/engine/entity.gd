extends KinematicBody2D

var TYPE : String = "ENEMY"
var speed : int = 0

var knockdir : Vector2 = dir.CENTER

var facedir : Vector2 = dir.DOWN
var movedir : Vector2 = dir.CENTER
var spritedir : String = "down"

var hitstun_timer : int = 0
var hitstun_amount : int = 10
var knock_strength : float = 1.5
export var health : float = 3
export var maxhealth : float = 3

signal health_changed

var wasdamaged = false

func set_facedir():
	if movedir.x == 0 and movedir.y == 0:
		return
	elif movedir.x == 1:
		facedir = dir.RIGHT
	elif movedir.x == -1:
		facedir = dir.LEFT
	elif movedir.y == 1:
		facedir = dir.DOWN
	elif movedir.y == -1: 
		facedir = dir.UP

func set_spritedir():
	match facedir:
		dir.UP:
			spritedir = "up"
		dir.DOWN:
			spritedir = "down"
		dir.LEFT:
			spritedir = "left"
		dir.RIGHT:
			spritedir = "right"

func switch_anim(animation):
	var nextanim : String = animation + spritedir
	if $anim.current_animation != nextanim:
		print("Playing animation: " + nextanim)
		$anim.play(nextanim)

func movement_loop():
	var motion
	if hitstun_timer == 0:
		motion = movedir.normalized() * speed
	else:
		motion = knockdir.normalized() * speed * knock_strength
	move_and_slide(motion, dir.CENTER)
	
func damage_loop():
	wasdamaged = false
	if hitstun_timer > 0:
		hitstun_timer -= 1
	for area in $hitbox.get_overlapping_areas():
		var body = area.get_parent()
		if hitstun_timer == 0 and body.get("DAMAGE") != null and body.get("TYPE") != TYPE:
			wasdamaged = true
			var damage = body.get("DAMAGE")
			health -= damage
			emit_signal("health_changed", health, damage)
			
			hitstun_timer = hitstun_amount
			knockdir = global_transform.origin - body.global_transform.origin

func hitback_loop():
	if hitstun_timer > 0:
		hitstun_timer -= 1
	for area in $hitbox.get_overlapping_areas():
		var body = area.get_parent()
		if hitstun_timer == 0 and body.get("DAMAGE") != null and body.get("TYPE") != TYPE:
#			health -= body.get("DAMAGE")
			hitstun_timer = hitstun_amount
			knockdir = global_transform.origin - body.global_transform.origin
	
func use_item(item):
	var newitem = item.instance()
	newitem.add_to_group(str(newitem.get_name(), self))
	add_child(newitem)
	if get_tree().get_nodes_in_group(str(newitem.get_name(), self)).size() > newitem.maxamount:
		newitem.queue_free()
	
	