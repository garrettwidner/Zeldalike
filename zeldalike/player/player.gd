extends "res://engine/entity.gd"

var input : Vector2 = dir.CENTER
var istrackingenemy : bool = false
var state = "default"
var walkspeed = 40
var runspeed = 65
var sprinkleoffset : float = 10
var sprinkleresource = preload("res://items/sprinkler/sprinkle.tscn")

var dialogueparser

var interacttarget
var caninteract : bool = false
var inventory = []

func _ready():
	speed = 40
	TYPE = "PLAYER"
	dialogueparser = get_node("../dialogue_parser")

func _process(delta):
	match state:
		"default":
			state_default()
		"swing":
			state_swing()
		"listen":
			state_listen()
	
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
		if caninteract:
			print("Should be interacting with " + interacttarget.name + "!")
			dialogueparser.init_dialogue(interacttarget)
		else:
			use_item(preload("res://items/sprinkler/sprinkler.tscn"))
			add_sprinkle()
		
	if Input.is_action_just_pressed("b"):
		use_item(preload("res://items/sword/sword.tscn"))
	
	movement_loop()

func state_swing():
	switch_anim("idle")
	damage_loop()
	
func state_listen():
	switch_anim("idle")

func add_sprinkle():
	var sprinkle = sprinkleresource.instance()
	sprinkle.position = transform.get_origin()
	sprinkle.position.x += facedir.x * sprinkleoffset
	sprinkle.position.y += facedir.y * sprinkleoffset
	if facedir.x == 0:
		if sprinkle.position.y < position.y:
			sprinkle.set_z_index(-1)
		elif sprinkle.position.y > position.y:
			sprinkle.set_z_index(1)
	else:
		sprinkle.set_z_index(0)
		
	self.get_parent().add_child(sprinkle)


	
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
			
func _on_Area2D_body_entered(body, obj):
	if body.get_name() == "player":
		caninteract = true
		interacttarget = obj
		print("Player's current interact target: " + obj.name)

func _on_Area2D_body_exited(body, obj):
	if body.get_name() == "player":
		caninteract = false
		interacttarget = null
		print("Player no longer has a target for interaction")

func set_state_swing():
	state = "swing"

func set_state_default():
	state = "default"
	
func set_state_listen():
	state = "listen"