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

var isinhoparea = false
var hoparea
var clinghandsycorrection = 00
var ispullingup
var ishoppingtocling

var transitionweight
var transitionspeed = .15
var transitionstart
var transitionend


var staticdir

var original_zindex

func _ready():
	speed = 40
	TYPE = "PLAYER"
	dialogueparser = get_node("../dialogue_parser")
	dialogueparser.connect("dialogue_finished", self, "dialogue_finished")
	original_zindex = z_index
	
	print("Player position:")
	print(global_position)
	
#	for i in range(20):
#    	print(i, '\t', get_collision_layer_bit(i))

func _process(delta):
	match state:
		"default":
			state_default()
		"swing":
			state_swing()
		"listen":
			state_listen()
		"block":
			state_block()
		"cling":
			state_cling()
		"transition":
			state_transition(delta)

func dialogue_finished():
	set_state_default()
	
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
#			print("Should be interacting with " + interacttarget.name + "!")
			set_state_listen()
			dialogueparser.activate(interacttarget)
		else:
			use_item(preload("res://items/sprinkler/sprinkler.tscn"))
			add_sprinkle()
		
	if Input.is_action_just_pressed("b"):
		if isinhoparea:
			set_state_transition()
			switch_anim("crouch")
		else:
			use_item(preload("res://items/sword/sword.tscn"))

				
				#tryhoptocling()
		
		
	if Input.is_action_just_pressed("x"):
		staticdir = spritedir
		use_item(preload("res://items/shield/shield.tscn"))
		pass
	
	
	movement_loop()

func state_swing():
	switch_anim("attack")
	damage_loop()
	
func state_listen():
	switch_anim("idle")
	
func state_block():
	if movedir != Vector2(0,0):
		switch_anim_static("walk")
	else:
		switch_anim_static("idle")
		
	set_speed()
	set_movedir()
	set_spritedir()
	movement_loop()
	hitback_loop()
	if Input.is_action_just_released("x"):
		set_state_default()

func state_cling():
	switch_anim("cling")
	if Input.is_action_just_pressed("b"):
		pullup()
	pass
	


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

func state_transition(delta):
	if ishoppingtocling:
		global_position = transitionstart.linear_interpolate(transitionend, transitionweight)
		
		transitionweight += transitionspeed
		if transitionweight >= 1:
			global_position = transitionend
			ishoppingtocling = false
			set_state_cling()
		pass
	elif ispullingup:
		
		pass
	else:
		damage_loop()
		if wasdamaged:
			set_state_default()
		elif Input.is_action_just_released("b"):
			if isinhoparea:
				if position.y > hoparea.position.y:
					#Jumping up on a ledge
					switch_anim("hop")
					set_collision_layer_bit(hoparea.belowheight, false)
					z_index = hoparea.abovez
					transitionend = Vector2(hoparea.clingpoint.x, hoparea.clingpoint.y + clinghandsycorrection)
					transitionstart = position
					transitionweight = 0
					ishoppingtocling = true
	pass
	
func pullup():
	var collisionshape = get_node("CollisionShape2D")
	var collisionextents = collisionshape.shape.extents
	var centertocollisionbottom = global_position.y - (collisionshape.global_position.y + collisionextents.y)
	
	global_position = Vector2(hoparea.highesthoppoint.x, hoparea.highesthoppoint.y + centertocollisionbottom)
	set_collision_layer_bit(hoparea.aboveheight, true)
	
	set_state_default()
	
	
	pass

func set_speed():
#	if Input.is_action_pressed("x"):
#		speed = runspeed
#	else:
#		speed = walkspeed
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
			
			istrackingenemy = true
			var directiontowards : Vector2 = body.transform.origin - transform.origin
			facedir = dir.closest_cardinal(directiontowards)
		else:
			istrackingenemy = false
			.set_facedir()
			
func _on_Area2D_body_entered(body, obj):
	if body.get_name() == "player":
		if obj.is_in_group("interactible"):
			caninteract = true
			interacttarget = obj
			print("Player's current interact target: " + obj.name)
		elif obj.is_in_group("zindexchanger"):
			if(get_collision_layer_bit(obj.ground_level)):
				z_index = obj.player_z_index
		elif obj.is_in_group("hoparea"):
			isinhoparea = true
			hoparea = obj
		

func _on_Area2D_body_exited(body, obj):
	if body.get_name() == "player":
		if obj.is_in_group("interactible"):
			caninteract = false
			interacttarget = null
#			print("Player no longer has a target for interaction")
		elif obj.is_in_group("heightchanger"):
			change_elevation(obj)
		elif obj.is_in_group("zindexchanger"):
			if(get_collision_layer_bit(obj.ground_level)):
				z_index = original_zindex
		elif obj.is_in_group("hoparea"):
			isinhoparea = false
			hoparea = null

func change_elevation(heightchanger):
	var newheight 
	var oldheight
	
	if position.y < heightchanger.position.y:
		newheight = heightchanger.aboveheight
		oldheight = heightchanger.belowheight
		z_index = heightchanger.abovez
	else:
		newheight = heightchanger.belowheight
		oldheight = heightchanger.aboveheight 
		z_index = heightchanger.belowz

	set_collision_layer_bit(newheight, true)
	set_collision_layer_bit(oldheight, false)

#	print("layer " + String(newheight) + " is " + String(get_collision_layer_bit(newheight)))
#	print("layer " + String(oldheight) + " is " + String(get_collision_layer_bit(oldheight)))
#	for i in range(20):
#    	print(i, '\t', get_collision_layer_bit(i))

func set_state_swing():
	state = "swing"

func set_state_default():
	state = "default"
	
func set_state_listen():
	state = "listen"
	
func set_state_block():
	state = "block"
	
func set_state_cling():
	state = "cling"
	
func set_state_transition():
	state = "transition"
	
	
func switch_anim_static(animation):
	var nextanim : String = animation + staticdir
	if $anim.current_animation != nextanim:
		$anim.play(nextanim)
		
	
	
	
	
	
