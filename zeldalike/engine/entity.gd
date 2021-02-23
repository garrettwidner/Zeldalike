extends KinematicBody2D

var TYPE : String = "ENEMY"
var speed : int = 0
var damage_type : String = "PHYSICAL"
							#"SPIRITUAL"

var knockdir : Vector2 = dir.CENTER

var facedir : Vector2 = dir.DOWN
var movedir : Vector2 = dir.CENTER
var spritedir : String = "down"

var hitstun_timer : int = 0
var hitstun_amount : int = 10
var knock_strength : float = 1.5
var knock_was_parry : bool = false
var parry_strength : float = 2.5
export var health : float = 3
export var maxhealth : float = 3


signal health_changed
signal on_death

#These only apply to the very last frame, and reset after that
var wasdamaged : bool = false
var received_damage_type = null
var received_parry : bool = false

func increase_health(amount):
	if health + amount <= maxhealth:
		health = health + amount
		emit_signal("health_changed", health, amount)
	else:
		var difference = maxhealth - health
		health = maxhealth
		emit_signal("health_changed", health, difference)
	

func decrease_health(amount):
	if health - amount > 0:
		health = health - amount
		emit_signal("health_changed", health, amount)
	else:
		var difference = health
		health = 0
		emit_signal("health_changed", health, difference)
	pass
	
func set_directionality(direction):
	set_movedir(direction)
	set_facedir()
	set_spritedir()

func set_movedir(direction):
	movedir = dir.closest_cardinal_or_ordinal(direction)

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
#	print(facedir)
		
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
		$anim.play(nextanim)

func movement_loop():
	var motion
	if hitstun_timer == 0:
		motion = movedir.normalized() * speed
	else:
		if knock_was_parry:
			motion = knockdir.normalized() * speed * parry_strength
#			print("Applying parry knock")
		else:
			motion = knockdir.normalized() * speed * knock_strength
#			print("Applying nonparry knock")
			
	
	move_and_slide(motion, dir.CENTER)
	
func damage_loop():
	wasdamaged = false
	received_damage_type = ""
	received_parry = false
	if hitstun_timer > 0:
		hitstun_timer -= 1
	for area in $hitbox.get_overlapping_areas():
		var body = area.get_parent()
		if hitstun_timer == 0 and body.get("DAMAGE") != null and body.get("TYPE") != TYPE && area.name == "hitbox":
			wasdamaged = true
			received_damage_type = body.get("damage_type")
			received_parry = body.get("is_parry")
			if received_parry: 
				knock_was_parry = true
			else:
				knock_was_parry = false
			var damage = body.get("DAMAGE")
#			health -= damage
#			emit_signal("health_changed", health, damage)
			decrease_health(damage)
			
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
	if newitem != null:
		return newitem
	
	