extends "res://engine/entity.gd"

var input : Vector2 = dir.CENTER
var istrackingenemy : bool = false
var state = "default"
var walkspeed = 40
var runspeed = 65

func _ready():
	speed = 40
	TYPE = "PLAYER"

func _process(delta):
	match state:
		"default":
			state_default()
		"swing":
			state_swing()
	
func state_default():
	set_speed()
	set_movedir()
	set_facedir()
	set_spritedir()
	damage_loop()
	
	if movedir != Vector2(0,0):
		switch_anim("walk")
	else:
		switch_anim("idle")
		
	if Input.is_action_just_pressed("a"):
		use_item(preload("res://items/sprinkler/sprinkler.tscn"))
	if Input.is_action_just_pressed("b"):
		use_item(preload("res://items/sword/sword.tscn"))
	
	movement_loop()

func state_swing():
	switch_anim("idle")
	damage_loop()
	
func set_speed():
	if Input.is_action_pressed("c"):
		speed = runspeed
	else:
		speed = walkspeed

func set_movedir():
	var LEFT : bool = Input.is_action_pressed("left")
	var RIGHT : bool = Input.is_action_pressed("right")
	var UP : bool = Input.is_action_pressed("up")
	var DOWN : bool = Input.is_action_pressed("down")
	
	if LEFT:
		movedir.x = -1
	elif RIGHT:
		movedir.x = 1
	else:
		movedir.x = 0
	
	if UP:
		movedir.y = -1
	elif DOWN:
		movedir.y = 1
	else:
		movedir.y = 0

func set_facedir():
	var closestdistance = 0
	for body in $sightbox.get_overlapping_bodies():
		if body.get("TYPE") == "ENEMY":
			#TODO: Make it so enemy
			
			
			istrackingenemy = true
			var directiontowards : Vector2 = body.transform.origin - transform.origin
			facedir = dir.closest_cardinal(directiontowards)
		else:
			istrackingenemy = false
			.set_facedir()
	