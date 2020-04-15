extends "res://engine/entity.gd"

#var movetimer_length : int = 14
#var movetimer : int = 0
var DAMAGE : int = 1
var damagetaker 
var collider
var perimeter

func _ready():
	TYPE = "ENEMY"
	$anim.play("idle")
	movedir = dir.rand()
	speed = 0
	hitstun_amount = 20
	self.connect("health_changed", self, "take_damage")
	$anim.connect("animation_finished", self, "_on_anim_animation_finished")
	maxhealth = 2
	health = 2
	damagetaker = get_node("hitbox/CollisionShape2D")
	collider = get_node("CollisionShape2D")
	perimeter = get_node("perimeter1")
	
func _physics_process(delta):
	
	
	set_facedir()
	
	movement_loop()
	damage_loop()
	
#	if movetimer >0:
#		movetimer -= 1
#	if movetimer == 0 || is_on_wall():
#		movedir = dir.rand()
#		movetimer = movetimer_length
		
func take_damage(health, damage):
	if self.health <= 0:
		die()
	else:
		$anim.play("hurt")
		damagetaker.disabled = true

func die():
	$anim.play("die")
	damagetaker.disabled = true
	collider.disabled = true
	speed = 2
	
func _on_anim_animation_finished(animation_name):
	if animation_name == "die":
		queue_free()
	if animation_name == "hurt":
		$anim.play("default")
		damagetaker.disabled = false

func _on_perimeter1_body_entered(body):
	if body.name == "player":
		print(body.name + " entered false angel's perimeter")
		turn(body)
	pass 
	
func turn(body):
	var direction_to_body = body.global_position - global_position 
#	print(String(decimals(direction_to_body.x)) + " , " + String(decimals(direction_to_body.y)))
	set_movedir(direction_to_body)
	set_facedir()
	set_spritedir()
	speed = 4
	print("Spritedir is now " + spritedir)
	switch_anim("move")
