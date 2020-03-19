extends "res://engine/entity.gd"

var input : Vector2 = dir.CENTER
var istrackingenemy : bool = false
var state = "default"
var walkspeed = 40
var runspeed = 50
var coverspeed = 30
var bowspeed = 20
var is_running = false
var motion_state = "idle"
var sprinkleoffset : float = 10
var sprinkleresource = preload("res://items/sprinkler/sprinkle.tscn")

var dialogueparser
#var inventorymanager

#var interacttarget
var interacttargets = []
var caninteract : bool = false
var post_speak_wait : float = 0.1

var speech_resource = preload("res://items/speech/speech.tscn")
signal on_spoke

var speech_animation_time : float = 0.2

var speechhittables = []

var searchareas = []

export var stamina : float = 10
export var maxstamina : float = 10
var stamina_drain_run : float = 2
var stamina_heal_walk : float = 1
var stamina_heal_still : float = 3

var stamina_drain_kickout = false
var stamina_previous = 0.0

signal stamina_changed
signal stamina_hit_zero

var is_covering = false
var cover_sun_decrease = 1.1

var hold_orienter
var hold_position
var is_holding : bool = false
var held_item
var is_eating : bool = false
var edible_is_finished : bool = false
export var bite_just_taken : bool = false

var inventory = []

var isinhoparea = false
var hoparea
var ispullingup
var ishoppingtocling
var isinclingcycle = false
var isinjumpdowncycle = false

var transitionweight
var transitionspeed = .15
var transitionstart
var transitionend

var hopdownspeed = 1
var sidepullupspeed = .09
var verticalpullupspeed = .20
var uphopupspeed = .15
var sidehopupspeed = .1
var downhopupspeed = .09
var hopdownleeway = 2.5
var current_hop_direction = null
var is_current_hop_upward = null

var landingtime = .2
var landingtimer = 0

var bow_is_fired = false
var bow_postfire_wait = .15
var arrow_resource = preload("res://items/arrow/arrow.tscn")

var sun
var sun_drain_damping = 0.6
var sun_areas = {}
var sun_base_strength
var sun_previous_total_strength = 0
signal on_sun_strength_changed
export var shade_color : Color 

var staticdir

var original_zindex

func _ready():
	set_state_stopped()
	pass

func run_setup():
	print("Setup being run on player")
	speed = 42
	TYPE = "PLAYER"
	
	dialogueparser = get_node("/root/Level/dialogue_parser")
	if dialogueparser != null:
		dialogueparser.connect("dialogue_finished", self, "dialogue_finished")
	else:
		print("ERROR: dialogueparser not found by Player")
		
#	inventorymanager = get_node("/root/Level/inventorymanager")
#	if inventorymanager == null:
#		print("ERROR: inventorymanager not found by player")
		
	original_zindex = z_index
	
	sun = get_node("/root/Level/sun")
	if sun != null:
		sun_base_strength = sun.strength
		
	hold_orienter = get_node("hold_orienter")	
	hold_position = get_node("hold_orienter/animation_mover")
	bite_just_taken = false
	
	connect("stamina_hit_zero", self, "create_stamina_drain_kickout")
#	print("Player position:")
#	print(global_position)
	
#	for i in range(20):
#   print(i, '\t', get_collision_layer_bit(i))
	set_state_default()
	pass

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
		"holding":
			state_holding(delta)
		"bowusing":
			state_bowusing(delta)
		"speech_animating":
			state_speech_animating(delta)
		"stopped":
			state_stopped(delta)

func dialogue_finished():
#	print("Character noticed dialogue was finished")
	$Timer.wait_time = post_speak_wait
	$Timer.start()
	
func state_default(delta):
	set_speed()
	set_movedir()
	set_facedir()
	set_spritedir()
	damage_loop()
	sun_damage_loop(delta)
	
#	for target in interacttargets:
#		print(target.name)
#	print("-----------")
	
	
	if !is_covering:
		if movedir != Vector2(0,0):
			if is_running:
				switch_anim("run")
				damage_stamina(stamina_drain_run, delta)
			else:
				switch_anim("walk")
				heal_stamina(stamina_heal_walk, delta)
		else:
			switch_anim("idle")
			heal_stamina(stamina_heal_still, delta)
	else:
		if movedir != Vector2(0,0):
			switch_anim("coverwalk")
			heal_stamina(stamina_heal_walk, delta)
		else:
			switch_anim("coveridle")
			heal_stamina(stamina_heal_still, delta)
		
	if Input.is_action_just_pressed("a"):
		use_item(preload("res://items/sword/sword.tscn"))
#		for i in searchareas:
#			print(i.name)
#		print("---")
#		else:
#			use_item(preload("res://items/sprinkler/sprinkler.tscn"))
#			add_sprinkle()
		
	elif Input.is_action_just_pressed("b"):
		if check_hop_validity():
			if is_current_hop_upward:
				set_state_uptransition()
#				print("Setting state as uptransition")
				if facedir == dir.RIGHT || facedir == dir.LEFT:
					transitionspeed = sidehopupspeed
				elif facedir == dir.UP:
					transitionspeed = uphopupspeed
				else:
					transitionspeed = downhopupspeed
				switch_anim("crouch")
			else:
				set_state_downtransition()
				transitionspeed = hopdownspeed / hoparea.height
				switch_anim("crouch")
		elif try_item_pickup():
#			print("Item pickup returned true")
			pass
		
	elif Input.is_action_just_pressed("y"):
#		set_state_bowusing()
		pass
		
	elif Input.is_action_just_pressed("test_1"):
		game_singleton.change_scene("level_1_test")
	elif Input.is_action_just_pressed("test_2"):
		game_singleton.change_scene("version_0_test")
	
	elif Input.is_action_just_pressed("x"):
		#interact with interactible you're facing
		var successfully_spoke = speak_to_interactibles()
		if !successfully_spoke:
			use_item(speech_resource)
			set_state_speech_animating()
			emit_signal("on_spoke")
			
	if Input.is_action_pressed("y"):
		is_covering = true;
	else:
		is_covering = false
		
		#if not, engage search area
		
		#if not speaking to interactible, trigger speechhittables
		
		
		#old logic -----------------------------
#		if caninteract:
##			print("Should be interacting with " + interacttarget.name + "!")
#			var is_valid_target = dialogueparser.activate(interacttarget)
#			if is_valid_target:
##				print("Set state to listen")
#				set_state_listen()
		#old logic end-----------------------------
		
				
#		staticdir = spritedir
#		use_item(preload("res://items/shield/shield.tscn"))
		pass
	
	
	movement_loop()
	
func damage_stamina(change, delta):
	stamina_previous = stamina
	if change <= 0:
		print("Warning: changes to stamina must be given as positive integers")
		change = abs(change)
	
	var modification = change * delta
	stamina -= modification
	if stamina < 0:
		stamina = 0
	else:
		emit_signal("stamina_changed", stamina, 0) 
	stamina_zero_check()
	
func heal_stamina(change, delta):
	stamina_previous = stamina
	if change <= 0:
		print("Warning: changes to stamina must be given as positive integers")
		change = abs(change)
	
	var modification = change * delta
	stamina += modification
	if stamina > maxstamina:
		stamina = maxstamina
	else:
		emit_signal("stamina_changed", stamina, 0) 
	stamina_zero_check()

func stamina_zero_check():
	if stamina_previous > 0 && stamina == 0:
		emit_signal("stamina_hit_zero")

func state_speech_animating(delta):
	switch_anim("speak")
	sun_damage_loop(delta)
	
func state_stopped(delta):
	pass

func speak_to_interactibles():
	var faced_targets = []
	var closest
	var closest_distance = 999999999
	
#	print("Number of interacttargets: " + String(interacttargets.size()))
#	for target in interacttargets:
#		print(target.name)
#	print("Can interact: " + String(caninteract))
	
	if caninteract:
		for target in interacttargets:
			var direction_towards = dir.closest_cardinal(target.position - position)
#			print("Direction towards " + target.name + " = " + String(direction_towards))
			match facedir:
				dir.RIGHT:
					if target.position.x > position.x:
						faced_targets.append(target)
				dir.LEFT:
					if target.position.x < position.x:
						faced_targets.append(target)
					pass
				dir.UP:
					if target.position.y < position.y:
						faced_targets.append(target)
					pass
				dir.DOWN:
					if target.position.y > position.y:
						faced_targets.append(target)
					pass 

#		print("After checking for facing direction:")
#		for target in faced_targets:
#			print(target.name)
#		print("-----------")
	
	#out of interactibles we're facing, find the closest
		if faced_targets.size() == 1:
			closest = faced_targets[0]
		elif faced_targets.size() > 1:
			for target in faced_targets:
				var this_distance = position.distance_to(target.position)
				if this_distance < closest_distance:
					closest_distance = this_distance
					closest = target
					
		if closest != null:
			var is_valid_target = dialogueparser.activate(closest)
			if is_valid_target:
				set_state_listen()
				return true
	return false

func state_bowusing(delta):
	
	if !bow_is_fired:
		set_movedir()
		set_spritedir()
		movement_loop()
		
		if Input.is_action_just_released("y"):
			bow_is_fired = true
			switch_anim_static("bowfire")
			$Timer.wait_time = bow_postfire_wait
			$Timer.start()
			#Fire arrow
			fire_arrow()
			
	else:
		if $Timer.time_left == 0:
			set_state_default()
	pass

func fire_arrow():
	var arrow = arrow_resource.instance()
	arrow.position = transform.get_origin()
	arrow.position.x += facedir.x * sprinkleoffset
	arrow.position.y += facedir.y * sprinkleoffset
	if facedir.x == 0:
		if arrow.position.y < position.y:
			arrow.set_z_index(-1)
		elif arrow.position.y > position.y:
			arrow.set_z_index(1)
	else:
		arrow.set_z_index(0)
		
	arrow.setup(facedir)
		
	self.get_parent().add_child(arrow)

func try_item_pickup():
#	print("Item pickup tried")
	var checkarea = get_node("hitbox")
	var pickupable
	var areas = checkarea.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("pickupable"):
			
			is_holding = true
			held_item = area
			
			if held_item.is_in_group("edible"):
				held_item.connect("on_eaten", self, "finish_edible")
				pass
			
#			add_child_below_node(hold_position,held_item, true)
			set_state_holding()
			return true
	return false
			
func finish_edible():
	edible_is_finished = true
	is_holding = false
	held_item = null
#	print("Item eaten")
	pass

func check_hop_validity():
	var already_hopping = false
	if isinhoparea:
#		print("Character is in hoparea")
#		print("Player:")
#		print(position.y)
#		print("Hoparea:")
#		print(hoparea.position.y)
		#character is below
		if global_position.y > hoparea.global_position.y:
#			print("Player is under hoparea")
			if hoparea.updirection == dir.DOWN:
				if facedir == dir.UP && hoparea.canhopdown:
#					print("can hop down")
					is_current_hop_upward = false
					
					already_hopping = true
			elif hoparea.updirection == dir.UP:
				if facedir == dir.UP && hoparea.canhopup:
#					print("can hop up")
					is_current_hop_upward = true
					
					already_hopping = true
		#character is above
		elif global_position.y < hoparea.global_position.y && !already_hopping:
			if hoparea.updirection == dir.DOWN:
				if facedir == dir.DOWN && hoparea.canhopup:
#					print("can hop up")
					is_current_hop_upward = true
					
					already_hopping = true
			elif hoparea.updirection == dir.UP:
				if facedir == dir.DOWN && hoparea.canhopdown:
#					print("can hop down") 
					is_current_hop_upward = false
					
					already_hopping = true
		#character is to the right
		if global_position.x > hoparea.global_position.x && !already_hopping:
			if hoparea.updirection == dir.LEFT:
				if facedir == dir.LEFT && hoparea.canhopup:
#					print("can hop up")
					is_current_hop_upward = true
					
					already_hopping = true
			elif hoparea.updirection == dir.RIGHT:
				if facedir == dir.LEFT && hoparea.canhopdown:
#					print("can hop down")
					is_current_hop_upward = false
					
					already_hopping = true
		#character is to the left
		if global_position.x < hoparea.global_position.x && !already_hopping:
			if hoparea.updirection == dir.LEFT:
				if facedir == dir.RIGHT && hoparea.canhopdown:
#					print("can hop down")
					is_current_hop_upward = false
					
					already_hopping = true
			elif hoparea.updirection == dir.RIGHT:
				if facedir == dir.RIGHT && hoparea.canhopup:
#					print("can hop up")
					is_current_hop_upward = true
					already_hopping = true
			pass
			
	return already_hopping
	
func get_hop_info():
	pass

func state_swing(delta):
	switch_anim("attack")
	damage_loop()
	heal_stamina(stamina_heal_walk, delta)
	
func state_listen(delta):
	if is_covering:
		switch_anim("coveridle")
	else:
		switch_anim("idle")
	heal_stamina(stamina_heal_still, delta)
	
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
		switch_anim("hang")
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
		
func state_holding(delta):
		
		
		
	if bite_just_taken:
		health += held_item.health
		emit_signal("health_changed", health, 0)
		held_item.was_bitten()
		bite_just_taken = false
	
	if !is_eating:
		set_hold_position()
		set_speed()
		set_movedir()
		set_facedir()
		set_spritedir()
		damage_loop()
		movement_loop()
		
	if !edible_is_finished:
		held_item.global_position = hold_position.global_position
		
		
	sun_damage_loop(delta)
	
#	print(held_item.position)

	if Input.is_action_just_pressed("b") && !is_eating:
		held_item.z_index = z_index - 1
		held_item.position = Vector2(held_item.position.x + (facedir.x * 3), held_item.position.y + (facedir.y * 3))
		is_holding = false
		held_item = null
		set_state_default()
		
	elif Input.is_action_just_pressed("a"):
		if held_item.is_in_group("edible"):
			is_eating = true
			facedir = dir.DOWN
			set_hold_position()
			
			switch_anim_directional("eat", "down")
#			held_item.queue_free()
			
			
	if !is_eating:
		if movedir != Vector2(0,0):
			switch_anim("holdwalk")
			heal_stamina(stamina_heal_walk, delta)
		else:
			switch_anim("holdidle")
			heal_stamina(stamina_heal_still, delta)
	
func set_hold_position():
	if facedir == dir.DOWN:
		hold_orienter.position = Vector2(0,3)
		held_item.z_index = z_index + 1
	if facedir == dir.RIGHT:
		hold_orienter.position = Vector2(6,2)
		held_item.z_index = z_index + 1
	if facedir == dir.LEFT:
		hold_orienter.position = Vector2(-6,2)
		held_item.z_index = z_index + 1
	if facedir == dir.UP:
		hold_orienter.position = Vector2(0,-3)
		held_item.z_index = z_index - 1
	pass
	
	
func start_down_hop():
	switch_anim("fall")
#	print("starting downward fall")
	transitionstart = global_position
	transitionend = hoparea.lowesthoppoint
	isinjumpdowncycle = true
	transitionweight = 0
	#testing
#	global_position = transitionend
#	set_state_default()
	pass
	
func continue_down_hop():
	global_position = transitionstart.linear_interpolate(transitionend, transitionweight)
	transitionweight += transitionspeed
	switch_anim("jumpdown")
	if transitionweight >= 1:
		global_position = transitionend
		isinjumpdowncycle = false
		set_state_landing()
		switch_anim("land")
		landingtimer = 0
	pass
	
func continue_ledge_hop():
	global_position = transitionstart.linear_interpolate(transitionend, transitionweight)
	transitionweight += transitionspeed
	if transitionweight >= 1:
#		print("Stopped ledge hop")
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
	switch_anim("jumpup")
	transitionend = hoparea.clingpoint
	transitionstart = global_position
	transitionweight = 0
	ishoppingtocling = true
	
func start_ledge_pullup():
	switch_anim("pullup")
	transitionend = hoparea.highesthoppoint
	if facedir == dir.RIGHT || facedir == dir.LEFT:
		transitionspeed = sidepullupspeed
	else:
		transitionspeed = verticalpullupspeed
	transitionstart = global_position
	transitionweight = 0
	ispullingup = true

func set_speed():
	if Input.is_action_pressed("b") && !is_holding && stamina > 0 && !stamina_drain_kickout && !is_covering:
		speed = runspeed
		is_running = true
	else:
		if stamina_drain_kickout:
			if Input.is_action_just_released("b"):
				stamina_drain_kickout = false
		speed = walkspeed
		is_running = false

func create_stamina_drain_kickout():
	stamina_drain_kickout = true
#	print("kicked out of using run through stamina drain")

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
	if sun != null:
		var sun_current_strength = sun_base_strength
		var change = 0
		var in_shade = false
		for sun_area in sun_areas.values():
			change += sun_area.modification
			if sun_area.is_shade:
				in_shade = true
		
		
		sun_current_strength += change
		
		if is_covering:
			sun_current_strength -= cover_sun_decrease
		
		if in_shade:
			$Sprite.modulate = shade_color
		else:
			$Sprite.modulate = Color.white
		
	#	print(sun_current_strength)
		
		take_sun_damage(sun_current_strength, delta)
		
		if sun_current_strength != sun_previous_total_strength:
			emit_signal("on_sun_strength_changed", sun_current_strength)
			sun_previous_total_strength = sun_current_strength
	

	
func take_sun_damage(sun_strength, delta):
	var damage = sun_strength * delta * sun_drain_damping
	if damage > 0:
		check_first_time_sun_damage()
		
		wasdamaged = true
		health -= damage
#		print("Sun damage: " + String(damage))
		emit_signal("health_changed", health, damage)

func check_first_time_sun_damage():
	if(!dialogueparser.check_experience("burnedOnce")):
		dialogueparser.set_experience("burnedOnce", true)
#		print("burned once set to " + String(dialogueparser.check_experience("burnedOnce")))
		

func _on_Area2D_body_entered(body, obj):
#	print("Player entered an area2d")
	if body.get_name() == "player":
		if obj.is_in_group("interactible"):
#			interacttarget = obj
			interacttargets.append(obj)
			check_if_can_interact()
#			print("Player's current interact target: " + obj.name)
		elif obj.is_in_group("speechhittable"):
			speechhittables.append(obj)
		elif obj.is_in_group("searcharea"):
			searchareas.append(obj)
#		elif obj.is_in_group("zindexchanger"):
#			if(get_collision_layer_bit(obj.ground_level)):
#				z_index = obj.player_z_index
		elif obj.is_in_group("hoparea"):
#			print("entered hoparea")
			isinhoparea = true
			hoparea = obj
#			print(hoparea.name)
		elif obj.is_in_group("sun_area"):
			sun_areas[obj.get_instance_id()] = obj
			
func _on_Area2D_body_exited(body, obj):
	if body.get_name() == "player":
		if obj.is_in_group("interactible"):
#			interacttarget = null
			var target_index = interacttargets.find(obj)
			if target_index != -1:
				interacttargets.remove(target_index)
			else:
				print("WARNING: interact target not found in array")
			check_if_can_interact()
#			print("Player no longer has a target for interaction")
		elif obj.is_in_group("speechhittable"):
			var target_index = speechhittables.find(obj)
			if target_index != -1:
				speechhittables.remove(target_index)
			else:
				print("WARNING: speechhittable target not found in array")
		elif obj.is_in_group("searcharea"):
			var target_index = searchareas.find(obj)
			if target_index != -1:
				searchareas.remove(target_index)
			else:
				print("WARNING: searcharea target not found in array")
#		elif obj.is_in_group("zindexchanger"):
#			if(get_collision_layer_bit(obj.ground_level)):
#				z_index = original_zindex
		elif obj.is_in_group("hoparea"):
			isinhoparea = false
			hoparea = null
		elif obj.is_in_group("sun_area"):
			var erasure_successful = sun_areas.erase(obj.get_instance_id())
#			if erasure_successful:
#				print("Successfully removed sun area from dictionary")
#			else:
#				print("Had some problem removing sun area from dictionary")

func check_if_can_interact():
	if interacttargets.size() >= 1:
		caninteract = true
	else:
		caninteract = false

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
	
func set_state_holding():
	state = "holding"
#	print("Picked up " + held_item.name)

func set_state_bowusing():
	state = "bowusing"
	bow_is_fired = false
	staticdir = spritedir
	switch_anim_static("bowdraw")
	speed = bowspeed
	
func set_state_speech_animating():
	state = "speech_animating"
	$Timer.wait_time = speech_animation_time
	$Timer.start()
	
func set_state_stopped():
	state = "stopped"
	
func switch_anim_static(animation):
	var nextanim : String = animation + staticdir
	if $anim.current_animation != nextanim:
		$anim.play(nextanim)
		
func switch_anim_directional(animation, direction):
	var nextanim : String = animation + direction
	if $anim.current_animation != nextanim:
		$anim.play(nextanim)

func _on_anim_animation_finished(anim_name):
	if anim_name == "eatdown":
		is_eating = false
		if held_item == null:
			edible_is_finished = false
			set_state_default()
#			print("State now default")
		
func _on_Timer_timeout():
	match state:
		"listen":
			set_state_default()
		"speech_animating":
			set_state_default()
