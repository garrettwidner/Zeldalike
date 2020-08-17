extends "res://engine/entity.gd"

var input : Vector2 = dir.CENTER
var istrackingenemy : bool = false
var state = "stopped"
var walkspeed = 40
var runspeed = 50
var coverspeed = 30
var bowspeed = 20
var is_running = false
var motion_state = "idle"
var sprinkleoffset : float = 10
var sprinkleresource = preload("res://items/sprinkler/sprinkle.tscn")

var dialogueparser

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

var is_veiled = false
var cover_sun_decrease = 1.1

var hold_orienter
var hold_position
var is_holding : bool = false
var held_item
var is_eating : bool = false
var edible_is_finished : bool = false
export var bite_just_taken : bool = false

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
var sword_resource = preload("res://items/sword/sword.tscn")
var veil_resource
var shield_resource = preload("res://items/shield/shield.tscn")

var sun

var min_sun_drain_damping = 0.6
var max_sun_drain_damping = 2.5
var sun_drain_damping = 0.6

var sun_areas = {}
var sun_base_strength
var sun_previous_total_strength = 0
signal on_sun_strength_changed
signal on_sun_start
export var shade_color : Color 

var disease_state : int = 1
var max_disease : int = 6
var min_disease : int = 1

var disease_6_sprite = preload("res://player/Lodan_Disease_6.png")
var disease_5_sprite = preload("res://player/Lodan_Disease_5.png")
var disease_4_sprite = preload("res://player/Lodan_Disease_4.png")
var disease_3_sprite = preload("res://player/Lodan_Disease_3.png")
var disease_2_sprite = preload("res://player/Lodan_Disease_2.png")
var disease_1_sprite = preload("res://player/Lodan_Recalibrator.png")

var elevation = 0
var previous_height_changer
var previous_height_change_was_decrement

var staticdir

var original_zindex

var inventorymanager

onready var food_sack = get_node("food_sack_display")
var end_food_sack_use = false
signal on_eat_anim_finished
var eating_sack_food_bite_health
var is_foodgiving = false

signal unique_item_picked_up
var item_pickup_hold_time = 2.2

var has_done_first_sun_check = false
signal on_initial_sun_check

var is_setup = false

func _ready():
	set_state_stopped()
	pass

func run_setup(start_position, start_direction):
#	print("----------------------Setup being run on player")
	speed = 42
	TYPE = "PLAYER"
	
	global_position = start_position
	set_facedir_manual(start_direction)
	
#	print("Player starting at position " + String(start_position) + " and in direction " + String(start_direction))
	
	dialogueparser = game_singleton.get_node("dialogue_parser")
	if dialogueparser != null:
		dialogueparser.connect("dialogue_finished", self, "dialogue_finished")
	else:
		print("ERROR: dialogueparser not found by Player")
		
	inventorymanager = game_singleton.get_node("inventorymanager")
	if inventorymanager == null:
		print("ERROR: inventorymanager not found by player")
		
	original_zindex = z_index
	
	sun = get_node("/root/Level/sun")
	if sun != null:
		sun_base_strength = sun.strength
#		print("Found sun")
#	else:
#		print("Warning: Sun is null")
		
	hold_orienter = get_node("hold_orienter")	
	hold_position = get_node("hold_orienter/animation_mover")
	bite_just_taken = false
	
	connect("stamina_hit_zero", self, "create_stamina_drain_kickout")
#	print("Player position:")
#	print(global_position)
	
#	for i in range(20):
#   print(i, '\t', get_collision_layer_bit(i))
#	set_state_default()

	connect("unique_item_picked_up", game_singleton.get_node("system_sound_player"), "play_unique_item_sound")
	connect("unique_item_picked_up", inventorymanager, "add_item")
	
	check_if_in_sunarea_at_start()
	
	var sunstrength = get_sun_current_strength()
#	print("Sunstrength as seen by player script is: " + String(sunstrength))
	
#	$heat_lines.run_setup(get_sun_current_strength())
#	var sun_current_strength = get_sun_current_strength()
#	emit_signal("on_sun_start", sun_current_strength)
#	print("on sun start should have signaled")
	
	food_sack.connect("on_closed", self, "end_food_sack_use")
	food_sack.connect("on_eat", self, "eat_sacked_food")
	connect("on_eat_anim_finished", food_sack, "eat_animation_finished")
	
	get_node("hold_orienter/animation_mover/food_sprite").visible = false
	
	set_state_default()
	
#	$Sprite.texture = test_sprites
	add_test_items()
	
	is_setup = true
	
	
	
	pass
	
func add_test_items():
	inventorymanager.add_item("food_sack")
	
func run_startup():
	#add code for starting character movement here
	pass
	
func check_if_in_sunarea_at_start():
	var all_sun_areas = get_tree().get_nodes_in_group("sun_area")
	var area_added = false
#	print("$$$")
#
#	var test_areas = $hitbox.get_overlapping_areas()
#	for a in range(test_areas.size()):
#		print("----Found overlapping area " + String(a + 1))
#	if test_areas.size() == 0:
#		print("----Could not find overlapping areas in test")
	
#	print("Checking sun areas at start")
	for i in range(all_sun_areas.size()):
#		print("Found sun area " + String(i + 1) + " and....")
#		if $hitbox.overlaps_area(all_sun_areas[i]):
		if all_sun_areas[i].overlaps_area($hitbox):
			area_added = true
			sun_areas[all_sun_areas[i].get_instance_id()] = all_sun_areas[i]
#			print("...added sun area #" + String(i + 1) + " to character list at start")
#		else:
#			print("...did not add it to the character list")
#	if area_added:
#		emit_signal("on_sun_strength_changed", sun_current_strength)
#	print("$$$")
	pass

func _process(delta):
	if !is_setup:
		return
	
	if !has_done_first_sun_check:
		process_initial_sun_checks()
		has_done_first_sun_check = true
		pass
	
	match state:
		"default":
			state_default(delta)
		"veiled":
			state_veiled(delta)
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
		"sackusing":
			state_sackusing(delta)
		"bowusing":
			state_bowusing(delta)
		"speech_animating":
			state_speech_animating(delta)
		"stopped":
			state_stopped(delta)
		"item_get":
			state_item_get(delta)
			
func process_initial_sun_checks():
	var perceived_initial_sun_strength = get_sun_current_strength()
#	print("Player initially perceived the sun's strength as " + String(perceived_initial_sun_strength))
	emit_signal("on_initial_sun_check", self, perceived_initial_sun_strength)
	pass

func dialogue_finished():
	$Timer.wait_time = post_speak_wait
	$Timer.start()
	
func state_default(delta):
	set_speed()
	assign_movedir_from_input()
	set_facedir()
	set_spritedir()
	damage_loop()
	sun_damage_loop(delta)
	
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
		
	if Input.is_action_just_pressed("item1") && !Input.is_action_pressed("itemchange"):
# 		find out which item corresponds to item1, and then trigger it
# 		by passing it to another function which uses an item based on the passed string

		var item1 = inventorymanager.get_item_1()
		if item1 != null:
#			print("Item 1: " + item1)
			use_named_item(item1)

#		use_item(preload("res://items/sprinkler/sprinkler.tscn"))
#		add_sprinkle()
		pass
		
	elif Input.is_action_just_pressed("item2") && !Input.is_action_pressed("itemchange"):
		var item2 = inventorymanager.get_item_2()
		if item2 != null:
#			print("Item 2: " + item2)
			use_named_item(item2)
		
	elif Input.is_action_just_pressed("action"):
		var successfully_spoke = speak_to_interactibles()
		if !successfully_spoke:
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

		
	elif Input.is_action_just_pressed("test_1"):
#		game_singleton.change_scene("level_1_test")
#		set_facedir_manual(dir.UP)
#		decrease_disease()
		pass

	elif Input.is_action_just_pressed("test_2"):
#		game_singleton.change_scene("version_0_test")
#		set_facedir_manual(dir.RIGHT)
#		increase_disease()
		pass
	
	elif Input.is_action_just_pressed("sack"):
		var item_was_picked_up = try_item_pickup()
		if !item_was_picked_up:
			if inventorymanager.has("food_sack"):
				set_state_sackusing()
		
		
		
		#interact with interactible you're facing
#		var item_was_picked_up = try_item_pickup()
#
#		if !item_was_picked_up:
#			var successfully_spoke = speak_to_interactibles()
#			if !successfully_spoke:
#				if speech_resource != null:
#					use_item(speech_resource)
#					set_state_speech_animating()
#					emit_signal("on_spoke")
	#				print("Speech item should play")
	#			else:
	#				print("Speech resource not loaded correctly")
				
	
	movement_loop()

func state_veiled(delta):
	set_veiled_speed()
	assign_movedir_from_input()
	set_facedir()
	set_spritedir()
	damage_loop()
	sun_damage_loop(delta)
	
	if movedir != Vector2(0,0):
		switch_anim("coverwalk")
		heal_stamina(stamina_heal_walk, delta)
	else:
		switch_anim("coveridle")
		heal_stamina(stamina_heal_still, delta)
	
	var veil_button = get_button_from_equipped_item("veil")
	if veil_button != null:
		if Input.is_action_just_released(veil_button):
			is_veiled = false
			set_state_default()
	
	if Input.is_action_just_pressed("action"):
		#interact with interactible you're facing
		var successfully_spoke = speak_to_interactibles()
#		if !successfully_spoke:
#			if speech_resource != null:
#				use_item(speech_resource)
#				set_state_speech_animating()
#				emit_signal("on_spoke")
#				print("Speech item should play")
#			else:
#				print("Speech resource not loaded correctly")
			
		pass
	
	movement_loop()
	
	pass
	
func pause():
#	set_state_stopped()
	pass
	
func unpause():
	pass

func get_button_from_equipped_item(item_name):
	if inventorymanager.get_item_1() == item_name:
		return "item1"
	elif inventorymanager.get_item_2() == item_name:
		return "item2"
	return null

func use_named_item(item_name):
	if inventorymanager.has(item_name):
#		print("Inventory contains " + item_name)
		if item_name == "veil":
			set_state_veiled()
			pass
		elif item_name == "bow":
			set_state_bowusing()
			pass
		elif item_name == "sword":
			use_item(sword_resource)
			pass
#		elif item_name == "food_sack":
#			set_state_sackusing()
#			pass
		else:
			pass
	pass

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

func state_sackusing(delta):
	sun_damage_loop(delta)
	
	heal_stamina(stamina_heal_still, delta)
	
	if bite_just_taken:
		increase_health(eating_sack_food_bite_health)
		bite_just_taken = false
		
	
	
	if end_food_sack_use:
		end_food_sack_use = false
		set_state_default()
	pass
	
func end_food_sack_use():
	end_food_sack_use = true
#	print("should close out of food sack")
	pass

func state_bowusing(delta):
	
	if !bow_is_fired:
		assign_movedir_from_input()
		set_spritedir()
		movement_loop()
		
		var bow_button = get_button_from_equipped_item("bow")
		if bow_button != null:
			if Input.is_action_just_released(bow_button):
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
		
	arrow.setup(facedir, elevation)
		
	self.get_parent().add_child(arrow)

func is_pickupable_in_vicinity():
	var checkarea = get_node("hitbox")
	var pickupable
	var areas = checkarea.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("unique_item"):
			return true
		elif area.is_in_group("pickupable"):
			return true
	return false
	
func get_givable_in_vicinity():
	return get_groupitem_in_vicinity("givable")
	pass
	
func get_groupitem_in_vicinity(group_name):
	var checkarea = get_node("hitbox")
	var givable
	var areas = checkarea.get_overlapping_areas()
	for area in areas:
		if area.is_in_group(group_name):
			return area
	return null
	

func try_item_pickup():
#	print("Item pickup tried")
	var checkarea = get_node("hitbox")
	var areas = checkarea.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("unique_item"):
			set_state_item_get(area)
			is_holding = true
			held_item = area
			return true
		elif area.is_in_group("pickupable"):
			if area.is_in_group("food"):
				if inventorymanager.has("food_sack"):
					if area.fits_in_sack:
						food_sack.add(area)
						area.queue_free()
						return true
					else:
						set_held_item(area)
						held_item.connect("on_eaten", self, "finish_edible")
						
						return true
				else:
					set_held_item(area)
					held_item.connect("on_eaten", self, "finish_edible")
					
					return true
					
			else:
				set_held_item(area)
				return true
	return false
#		elif area.is_in_group("pickupable"):
#
#			is_holding = true
#			held_item = area
#
#			if held_item.is_in_group("edible"):
#				held_item.connect("on_eaten", self, "finish_edible")
#
##			add_child_below_node(hold_position,held_item, true)
#			set_state_holding()
#			return true
#		elif area.is_in_group("food"):
#			var found_food = helper.string_strip(area.name)
##			print("Player picked up food named " + found_food)
#			food_sack.add(area)
##			food_sack.print_contents()
#			area.queue_free()
#			return true
			
func set_held_item(item):
	is_holding = true
	held_item = item
	set_state_holding()	

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
	if is_veiled:
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
	assign_movedir_from_input()
	set_spritedir()
	movement_loop()
	hitback_loop()
	if Input.is_action_just_released("sack"):
		set_state_default()
		print("Error: this should be set up to trigger when a character is done blocking only")

func state_cling(delta):
	switch_anim("cling")
	if Input.is_action_just_pressed("action"):
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
			elif Input.is_action_just_released("action"):
				start_ledge_hop()
		else:
			if Input.is_action_just_released("action"):
				start_ledge_pullup()
	pass
	
func state_downtransition(delta):
	if !isinjumpdowncycle:
		damage_loop()
		if wasdamaged:
			set_state_default()
		elif(Input.is_action_just_released("action")):
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
		if held_item == null:
			return
		increase_health(held_item.bite_health)
#		health += held_item.health
#		emit_signal("health_changed", health, 0)
		held_item.was_bitten()
		bite_just_taken = false
	
	if !is_eating:
		set_hold_position()
		set_speed()
		assign_movedir_from_input()
		set_facedir()
		set_spritedir()
		damage_loop()
		movement_loop()
		
	if !edible_is_finished:
		held_item.global_position = hold_position.global_position
		
	sun_damage_loop(delta)
	
#	print(held_item.position)

	if Input.is_action_just_pressed("sack") && !is_eating:
		if held_item == null:
			return
		held_item.z_index = z_index - 1
		held_item.position = Vector2(held_item.position.x + (facedir.x * 3), held_item.position.y + (facedir.y * 3))
		is_holding = false
		held_item = null
		set_state_default()
		
	elif Input.is_action_just_pressed("action"):
		if held_item == null:
			return
		if held_item.is_in_group("food"):
			is_eating = true
			facedir = dir.DOWN
			set_hold_position()
			
			switch_anim_directional("eat", "down")
#			switch_anim_directional("eatslow", "down")
#			held_item.queue_free()
			
			
	if !is_eating:
		if movedir != Vector2(0,0):
			switch_anim("holdwalk")
			heal_stamina(stamina_heal_walk, delta)
		else:
			switch_anim("holdidle")
			heal_stamina(stamina_heal_still, delta)

func state_item_get(delta):
	set_hold_position()
	if $Timer.time_left <= 0:
		set_state_default()
		held_item.queue_free()
		is_holding = false

func set_hold_position():
	if facedir == dir.DOWN:
		hold_orienter.position = Vector2(0,3)
		held_item.z_index = z_index + 1
	if facedir == dir.RIGHT:
#		hold_orienter.position = Vector2(6,2)
#		held_item.z_index = z_index + 1
		
		hold_orienter.position = Vector2(6,-2)
		held_item.z_index = z_index - 1
	if facedir == dir.LEFT:
#		hold_orienter.position = Vector2(-6,2)
#		held_item.z_index = z_index + 1
		
		hold_orienter.position = Vector2(-6,-2)
		held_item.z_index = z_index - 1
	if facedir == dir.UP:
		hold_orienter.position = Vector2(0,-5)
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
	if Input.is_action_pressed("action") && !is_holding && stamina > 0 && !stamina_drain_kickout:
		speed = runspeed
		is_running = true
	else:
		if stamina_drain_kickout:
			if Input.is_action_just_released("action"):
				stamina_drain_kickout = false
		speed = walkspeed
		is_running = false

func set_veiled_speed():
	speed = coverspeed
	is_running = false
	pass

func create_stamina_drain_kickout():
	stamina_drain_kickout = true
#	print("kicked out of using run through stamina drain")

func assign_movedir_from_input():
	movedir = dir.direction_from_input()
	
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

func set_facedir_manual(new_direction):
	if new_direction == dir.DOWN || new_direction == dir.UP || new_direction == dir.LEFT || new_direction == dir.RIGHT:
		facedir = new_direction
	else:
		print("Error: facedir must be a cardinal direction")
		
func sun_damage_loop(delta):
	if sun != null:
		
#		print("Sun damage loop is running")
		
		var sun_current_strength = get_sun_current_strength()
#		print("Sun current strength: " + String(sun_current_strength))
		var in_shade = get_is_in_shade()
		
		if in_shade:
			$Sprite.modulate = shade_color
#			print("Changed sprite to shade color")
		else:
			$Sprite.modulate = Color.white
#			print("Changed sprite to normal color")
		
	#	print(sun_current_strength)
		
		take_sun_damage(sun_current_strength, delta)
		
		if sun_current_strength != sun_previous_total_strength:
			emit_signal("on_sun_strength_changed", sun_current_strength)
			sun_previous_total_strength = sun_current_strength
	
func get_is_in_shade():
	var in_shade = false
	for sun_area in sun_areas.values():
#		print(sun_area.get_node("..").name)
		if sun_area.is_shade:
			return true
	return false
	
func get_sun_current_strength():
	var sun_current_strength = sun_base_strength
#	print("---")
#	print("Sun base strength is " + String(sun_current_strength))
	var change = 0
	
	var sun_area_count = 0
	
	for sun_area in sun_areas.values():
		change += sun_area.modification
		sun_area_count = sun_area_count + 1
		
#	print("Found " + String(sun_area_count) + " sun areas in check")
#	print("sun change from base is " + String(change))
	
	sun_current_strength += change
	
#	print("Final calculated sun strength is " + String(sun_current_strength))
#	print("---")
	
	if is_veiled:
		sun_current_strength -= cover_sun_decrease
#		print("Being effected by veil")
#	else: 
#		print("Get sun current strength not noticing veil")
		
#	print("Final calculated sun strength with cover is " + String(sun_current_strength))
		
	return sun_current_strength
	
	
func take_sun_damage(sun_strength, delta):
	var damage = sun_strength * delta * sun_drain_damping
	if damage > 0:
		check_first_time_sun_damage()
		
		wasdamaged = true
#		print("Sun damage: " + String(damage))
		decrease_health(damage)
#		health -= damage
#		emit_signal("health_changed", health, damage)

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
		elif obj.is_in_group("heightchanger"):
#			print("Player exited heightchanger object")
			var height_change_is_decrement
			
			if obj.is_point_above($CollisionShape2D.global_position):
				height_change_is_decrement = false
			else:
				height_change_is_decrement = true
				
			if height_change_is_decrement == previous_height_change_was_decrement && previous_height_changer == obj:
#				print("Exiting from same side of most recent height change object; height not changed.")
				return
			else:
				previous_height_changer = obj
				if height_change_is_decrement:
					elevation = elevation - obj.magnitude
					previous_height_change_was_decrement = true
				else:
					elevation = elevation + obj.magnitude
					previous_height_change_was_decrement = false
					
				print("Player elevation changed to " + String(elevation))
			
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
	
func set_state_veiled():
	state = "veiled"
	is_veiled = true
	
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

func set_state_sackusing():
	state = "sackusing"
	
	var givable = get_givable_in_vicinity()
	
	if givable != null:
		is_foodgiving = true
		var dir_towards_givable = givable.global_position - global_position
		var cardinal_dir = dir.closest_cardinal(dir_towards_givable)
		set_facedir_manual(cardinal_dir)
		set_spritedir()
		staticdir = spritedir
		food_sack.open(is_foodgiving, cardinal_dir)
		print("Food sack opened with direction( " + String(cardinal_dir) + " )")
		switch_anim_static("holdidle")
		pass
	else:
		is_foodgiving = false
		set_facedir_manual(dir.DOWN)
		set_spritedir()
		staticdir = spritedir
		food_sack.open(is_foodgiving, dir.DOWN)
		switch_anim_static("holdidle")
	
	
#	switch_anim_static("sackusing")
	pass

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
	
func set_state_item_get(item):
	state = "item_get"
	held_item = item
	facedir = dir.DOWN
	set_hold_position()
	$anim.play("itempickup")
	held_item.global_position = hold_position.global_position
	$Timer.start(item_pickup_hold_time)
	emit_signal("unique_item_picked_up", item.name)
	
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
	if anim_name == "eatdown" || anim_name == "eatslowdown":
		if state != "sackusing":
			is_eating = false
			if held_item == null:
				edible_is_finished = false
				set_state_default()
	#			print("State now default")
		elif state == "sackusing":
			switch_anim_static("holdidle")
	elif anim_name == "eatdoubledown" && state == "sackusing":
		emit_signal("on_eat_anim_finished")	
		
func _on_Timer_timeout():
	match state:
		"listen":
			if is_veiled:
				set_state_veiled()
			else:
				set_state_default()
		"speech_animating":
			set_state_default()
			
func increase_disease():
	disease_state = disease_state + 1
	if disease_state > max_disease:
		disease_state = max_disease
		
	set_disease_sprite()
		
func decrease_disease():
	disease_state = disease_state - 1
	if disease_state < min_disease:
		disease_state = min_disease
		
	set_disease_sprite()
		
func set_disease(new_disease):
	disease_state = new_disease
	
	if disease_state > max_disease:
		print("Warning: disease_state must be less than " + String(max_disease))
		disease_state = max_disease
	elif disease_state < min_disease:
		print("Warning: disease_state must be greater than " + String(min_disease))
		disease_state = min_disease
		
	set_disease_sprite()
		
func set_disease_sprite():
	match disease_state:
		1:
			print("disease sprite 1")
			$Sprite.texture = disease_1_sprite
		2:
			print("disease sprite 2")
			$Sprite.texture = disease_2_sprite
		3:
			print("disease sprite 3")
			$Sprite.texture = disease_3_sprite
		4: 
			print("disease sprite 4")
			$Sprite.texture = disease_4_sprite
		5:
			print("disease sprite 5")
			$Sprite.texture = disease_5_sprite
		6:
			print("disease sprite 6")
			$Sprite.texture = disease_6_sprite
			
			

func eat_sacked_food(food_health, food_texture, food_bitten_texture):
	if state == "sackusing":
#		print("player ate food from sack")


		#TODO: Show eaten food
		var food_sprite = get_node("hold_orienter/animation_mover/food_sprite")
		food_sprite.texture = food_texture
		food_sprite.visible = true
		var food_sprite_bitten = get_node("hold_orienter/animation_mover/food_sprite_bitten")
		food_sprite_bitten.texture = food_bitten_texture
		food_sprite_bitten.visible = false
		eating_sack_food_bite_health = food_health / 2
#		increase_health(food_health / 2)
#		health += food_health
#		emit_signal("health_changed", health, 0)
		
		switch_anim_directional("eatdouble", "down")

	pass
