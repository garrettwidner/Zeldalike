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
var isinclingcycle = false
var isinjumpdowncycle = false

var transitionweight
var transitionspeed = .15
var transitionstart
var transitionend

var hopdownspeed = 1
var hopupspeed = .15
var hopdownleeway = 2.5

var landingtime = .2
var landingtimer = 0

var sun_area
var is_in_sun_area = false
signal on_entered_sun_area
signal on_exited_sun_area

var staticdir

var original_zindex

func _ready():
	speed = 40
	TYPE = "PLAYER"
	dialogueparser = get_node("../dialogue_parser")
	dialogueparser.connect("dialogue_finished", self, "dialogue_finished")
	original_zindex = z_index
	
#	print("Player position:")
#	print(global_position)
	
#	for i in range(20):
#    	print(i, '\t', get_collision_layer_bit(i))

func _process(delta):
	match state:
		"default":
			state_default(delta)
		"swing":
			state_swing(delta)
		"listen":
			state_listen(delta)
		"block":
			state_block(delta)
		"cling":
			state_cling(delta)
		"uptransition":
			state_uptransition(delta)
		"downtransition":
			state_downtransition(delta)
		"landing":
			state_landing(delta)

func dialogue_finished():
	set_state_default()
	
func state_default(delta):
	set_speed()
	set_movedir()
	set_facedir()
	set_spritedir()
	damage_loop()
	sun_damage_loop(delta)
	
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
		if check_hop_validity():
			set_state_uptransition()
			transitionspeed = hopupspeed
			switch_anim("ledgecrouch")
		elif isinhoparea && position.y < hoparea.position.y && hoparea.canhopdown && facedir == dir.DOWN:
#			print(abs(position.x - hoparea.position.x))
			if abs(position.x - hoparea.position.x) < hopdownleeway:
				set_state_downtransition()
				transitionspeed = hopdownspeed / hoparea.height
				switch_anim("ledgecrouch")
		else:
			use_item(preload("res://items/sword/sword.tscn"))
		
	if Input.is_action_just_pressed("x"):
		staticdir = spritedir
		use_item(preload("res://items/shield/shield.tscn"))
		pass
	
	
	movement_loop()
#		if isinhoparea && position.y > hoparea.position.y && hoparea.canhopup && facedir == dir.UP:

func check_hop_validity():
	var already_hopping = false
	if isinhoparea:
		#character is below
		if position.y > hoparea.position.y:
			if hoparea.updirection == dir.DOWN:
				if facedir == dir.UP && hoparea.canhopdown:
					print("can hop down")
					already_hopping = true
			elif hoparea.updirection == dir.UP:
				if facedir == dir.UP && hoparea.canhopup:
					print("can hop up")
					already_hopping = true
		#character is above
		elif position.y < hoparea.position.y && !already_hopping:
			if hoparea.updirection == dir.DOWN:
				if facedir == dir.DOWN && hoparea.canhopup:
					print("can hop up")
					already_hopping = true
			elif hoparea.updirection == dir.UP:
				if facedir == dir.DOWN && hoparea.canhopdown:
					print("can hop down") 
					already_hopping = true
		#character is to the right
		if position.x > hoparea.position.x && !already_hopping:
			if hoparea.updirection == dir.LEFT:
				if facedir == dir.LEFT && hoparea.canhopup:
					print("can hop up")
					already_hopping = true
			elif hoparea.updirection == dir.RIGHT:
				if facedir == dir.LEFT && hoparea.canhopdown:
					print("can hop down")
					already_hopping = true
		#character is to the left
		if position.x < hoparea.position.x && !already_hopping:
			if hoparea.updirection == dir.LEFT:
				if facedir == dir.RIGHT && hoparea.canhopdown:
					print("can hop down")
					already_hopping = true
			elif hoparea.updirection == dir.RIGHT:
				if facedir == dir.RIGHT && hoparea.canhopup:
					print("can hop up")
					already_hopping = true
			pass
					
	return false
	
func get_hop_info():
	pass

func state_swing(delta):
	switch_anim("attack")
	damage_loop()
	
func state_listen(delta):
	switch_anim("idle")
	
func state_block(delta):
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

func state_cling(delta):
	switch_anim("cling")
	if Input.is_action_just_pressed("b"):
		switch_anim("pullupstart")
		set_state_uptransition()
		#pullup()
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

func state_uptransition(delta):
	if ishoppingtocling:
		continue_ledge_hop()
	elif ispullingup:
		continue_ledge_pullup()
		pass
	else:
		if !isinclingcycle:
			damage_loop()
			if wasdamaged:
				set_state_default()
			elif Input.is_action_just_released("b"):
				start_ledge_hop()
		else:
			if Input.is_action_just_released("b"):
				start_ledge_pullup()
	pass
	
func state_downtransition(delta):
	if !isinjumpdowncycle:
		damage_loop()
		if wasdamaged:
			set_state_default()
		elif(Input.is_action_just_released("b")):
			start_down_hop()
	else:
		continue_down_hop()
	
	pass
	
func state_landing(delta):
	damage_loop()
	if wasdamaged:
		set_state_default()
		return
	landingtimer += delta
	if landingtimer >= landingtime:
		set_state_default()
	
	
func start_down_hop():
	switch_anim("hop")
	transitionstart = position
	transitionend = get_character_position_at_base()
	isinjumpdowncycle = true
	transitionweight = 0
	#testing
#	global_position = transitionend
#	set_state_default()
	pass
	
func continue_down_hop():
	global_position = transitionstart.linear_interpolate(transitionend, transitionweight)
	transitionweight += transitionspeed
	if transitionweight >= 1:
		global_position = transitionend
		isinjumpdowncycle = false
		set_state_landing()
		switch_anim("landing")
		landingtimer = 0
	pass
	
func continue_ledge_hop():
	global_position = transitionstart.linear_interpolate(transitionend, transitionweight)
	transitionweight += transitionspeed
	if transitionweight >= 1:
		global_position = transitionend
		ishoppingtocling = false
		set_state_cling()
		
func continue_ledge_pullup():
	global_position = transitionstart.linear_interpolate(transitionend, transitionweight)
	transitionweight += transitionspeed
	if transitionweight >= 1:
		global_position = transitionend
		ispullingup = false
		set_state_default()
		isinclingcycle = false
		
func start_ledge_hop():
	isinclingcycle = true
	switch_anim("hop")
	transitionend = Vector2(hoparea.clingpoint.x, hoparea.clingpoint.y + clinghandsycorrection)
	transitionstart = position
	transitionweight = 0
	ishoppingtocling = true
	
func start_ledge_pullup():
	switch_anim("pullup")
	transitionend = get_character_position_after_pullup()
	transitionstart = position
	transitionweight = 0
	ispullingup = true
	
func get_character_position_after_pullup():
	var collisionshape = get_node("CollisionShape2D")
	var collisionextents = collisionshape.shape.extents
	var centerdisttocollisionbottom = global_position.y - (collisionshape.global_position.y + collisionextents.y)
	return Vector2(hoparea.highesthoppoint.x, hoparea.highesthoppoint.y + centerdisttocollisionbottom)
	
func get_character_position_at_base():
	var collisionshape = get_node("CollisionShape2D")
	var collisionextents = collisionshape.shape.extents
	var centerdisttocollisiontop = global_position.y - (collisionshape.global_position.y - collisionextents.y)
	var position_at_base = Vector2(hoparea.lowesthoppoint.x, hoparea.lowesthoppoint.y - centerdisttocollisiontop)
#	hoparea.get_node("Sprite").global_position = position_at_base
	return position_at_base

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
#	var closestdistance = 0
#	for body in $sightbox.get_overlapping_bodies():
#		if body.get("TYPE") == "ENEMY":
#
#			istrackingenemy = true
#			var directiontowards : Vector2 = body.transform.origin - transform.origin
#			facedir = dir.closest_cardinal(directiontowards)
#		else:
#			istrackingenemy = false
#			.set_facedir()
	.set_facedir()
			
func sun_damage_loop(delta):
	if !is_in_sun_area:
		return
	
	var damage_done = sun_area.get_damage()
	var damage = damage_done * delta
	wasdamaged = true
	health -= damage
	emit_signal("health_changed", health, damage)
	
	pass
			
func _on_Area2D_body_entered(body, obj):
	if body.get_name() == "player":
		if obj.is_in_group("interactible"):
			caninteract = true
			interacttarget = obj
#			print("Player's current interact target: " + obj.name)
#		elif obj.is_in_group("zindexchanger"):
#			if(get_collision_layer_bit(obj.ground_level)):
#				z_index = obj.player_z_index
		elif obj.is_in_group("hoparea"):
			isinhoparea = true
			hoparea = obj
		elif obj.is_in_group("sun_area"):
			sun_area = obj
			is_in_sun_area = true
			emit_signal("on_entered_sun_area")
			
		

func _on_Area2D_body_exited(body, obj):
	if body.get_name() == "player":
		if obj.is_in_group("interactible"):
			caninteract = false
			interacttarget = null
#			print("Player no longer has a target for interaction")
#		elif obj.is_in_group("zindexchanger"):
#			if(get_collision_layer_bit(obj.ground_level)):
#				z_index = original_zindex
		elif obj.is_in_group("hoparea"):
			isinhoparea = false
			hoparea = null
		elif obj.is_in_group("sun_area"):
			is_in_sun_area = false
			sun_area = null
			emit_signal("on_exited_sun_area")

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
	
func set_state_uptransition():
	state = "uptransition"
	
func set_state_downtransition():
	state = "downtransition"

func set_state_landing():
	state = "landing"
	
func switch_anim_static(animation):
	var nextanim : String = animation + staticdir
	if $anim.current_animation != nextanim:
		$anim.play(nextanim)
		
	
	
	
	
	
