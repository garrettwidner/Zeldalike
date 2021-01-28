extends "res://engine/entity.gd"

var input : Vector2 = dir.CENTER
var istrackingenemy : bool = false
var state = "stopped"
var walkspeed = 40
var runspeed = 50
var coverspeed = 30
var bowspeed = 20
var climbspeed = 25

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
var stamina_heal_walk : float = 2.2
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

enum JUMPTYPE 	{
				HOP,
				JUMP,
				LEAP
				}	
				
var jump_type = JUMPTYPE.HOP

var isinleaparea = false
var leaparea
var isinjumparea = false
#var current_jumparea
var isinhoparea = false
var hoparea

var ledge_catch_leeway = .22
var ledge_catch_timer = 0
var can_ledge_catch = false
var min_height_for_ledge_catch = 30

#----------------------------------------------
var jumpstartpos
var jumpendpos
var jumpweight
var jumpspeed

var tiny_jump_speed_modifier = 0.6

var tiny_jumpheight = 1.2
var short_jumpheight = 5
var long_jumpheight = 10
var min_distance_for_short_jump = 15
var min_distance_for_long_jump = 45
var current_jumpheight

var linked_jumpareas
var next_jumparea_index = 0

var previous_terrain = terrain.TYPE.GROUND
var current_terrain = terrain.TYPE.GROUND
var upcoming_terrain = terrain.TYPE.GROUND

var current_jumparea

var upcoming_jumparea
var upcoming_jumparea_index = 0
var direction_to_upcoming_jumparea
var distance_to_upcoming_jumparea

var min_ledge_width_for_side_climb = 11

var is_grace_timing = false
var short_jump_grace_time = .32
var grace_timer = 0

#var current_ledge
var is_on_ledge
var current_ledge_l_bound
var current_ledge_r_bound
var can_side_climb_current_ledge = false

#var upcoming_ledge
var will_be_on_ledge
var upcoming_ledge_l_bound
var upcoming_ledge_r_bound
var can_side_climb_upcoming_ledge = false

var checking_crouch_ledge_fall_validity = false

#----------------------------------------------

var sidepullupspeed = .09
var verticalpullupspeed = .20
var ledgeclimbspeed = 20

var falllandingtime = .2
var jumplandingtime = .1
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

var is_blocking = false
var stamina_drain_block : float = 1
var shield_icon 

var jump_reticule_resource = preload("res://UI/jump_reticule.tscn")
var jump_reticule
var is_using_jump_reticule = false
var reticule_visibility_min_distance = 20

var check_fall = false
var fall_check_direction
var valid_fall_location
var falldistance
var general_hop_distance = 12
var fallspeed = 1.2
var is_coming_from_fall = false

var proper_landing_damage_reducer = .5
var side_landing_damage_reducer = .85

var max_falldamage_height = 150
#var max_mid_fall_height = 150
#var max_bouldering_height = 100
var max_low_fall_height = 30


export var fall_damage_curve : Curve
var max_fall_damage = 50
var min_fall_damage	= 1

#var max_high_fall_damage = 50
#var min_high_fall_damage = 30
#var max_mid_fall_damage = 30
#var min_mid_fall_damage = 8
#var max_bouldering_damage = 4
#var min_bouldering_damage = 1
#var low_fall_damage = 0

var check_fallgrab = false
var fallgrab_area = null
var fallgrab_type = terrain.TYPE.NONE

var vanish_reticule_resource = preload("res://testing/vanish_reticule.tscn")

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
	
	food_sack.connect("on_eat", self, "eat_sacked_food")
	food_sack.connect("on_give", self, "place_food_in_basket")
	food_sack.connect("on_closed", self, "end_food_sack_use")
	food_sack.visible = true
	
	
	connect("on_eat_anim_finished", food_sack, "eat_animation_finished")
	
	get_node("hold_orienter/animation_mover/food_sprite").visible = false
	
	set_state_default()
	
#	$Sprite.texture = test_sprites
	add_test_items()
	
	
	shield_icon = $shield_icon
	is_setup = true
	
	pass
	
func add_test_items():
#	inventorymanager.add_item("bow")
#	inventorymanager.add_item("sword")
	inventorymanager.add_item("food_sack")
#	inventorymanager.add_item("veil")
	
	
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
	
#	print("Last terrain is " + terrain.string_from_terrain(current_terrain))
	
#	print(Performance.get_monitor(Performance.TIME_FPS))
	
	if !is_setup:
		return
	
	if !has_done_first_sun_check:
		process_initial_sun_checks()
		has_done_first_sun_check = true
		pass
		
#	if current_jumparea!= null:
#		print("Current jumparea: " + current_jumparea.name)

	if is_grace_timing:
		grace_timer = grace_timer - delta
		if grace_timer <= 0:
			grace_timer = 0
			is_grace_timing = false
			
		
func reset_and_start_grace_timer(grace_time = short_jump_grace_time):
	is_grace_timing = true
	grace_timer = grace_time
	
	
func _physics_process(delta):
	if check_fall:
		get_valid_fall_end_location()
	check_fall = false
		
	if check_fallgrab:
		get_valid_fallgrab_area()
	check_fallgrab = false
	
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
		"crouch":
			state_crouch(delta)
		"jump":
			state_jump(delta)
		"climb":
			state_climb(delta)	
		"ledge":
			state_ledge(delta)
		"fall":
			state_fall(delta)
		"pullup":
			state_pullup(delta)
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
	
	
func get_valid_fall_end_location():
	var space_state = get_world_2d().get_direct_space_state()
	valid_fall_location = get_fall_end_location(space_state)
	
	if is_on_ledge:
		#Makes the character 'fall' so that it looks like he's jumping down a slope
		if valid_fall_location != null:
			if current_jumparea.updirection == dir.LEFT || current_jumparea.updirection == dir.RIGHT:
				var fall_jump_illusion_strength = 3
				valid_fall_location.y = valid_fall_location.y + fall_jump_illusion_strength
		else:
			pass
#			print("Error: no valid fall location")
			
			
#		if valid_fall_location != null:
##			print("Found valid fall location.")
#			pass
	pass	

func get_fall_end_location(space_state):
	#Check for an empty space until you find one
	var checkdirection = fall_check_direction
#	print("Checking for fall in direction: " + String(checkdirection))
	var has_found_end = false
	var i = 3
	var check_distance = $CollisionShape2D.shape.extents.y
#	print("Fall check distance is " + String(check_distance))
	while !has_found_end:
		var checkposition = (checkdirection * check_distance * i) + global_position
#		instantiate_vanish_reticule(checkposition)
		i = i + 1
		var results_array = space_state.intersect_point(checkposition, 32, [], 2147483647, false, true)
#		print("-next check results-")
		if results_array.empty():
			pass
		else:
			var found_real_collision = false
			for a in results_array:
				var found_area = a["collider"]
#				print("Found collider: " + found_area.name)
				if found_area.name != name:
					if found_area.is_in_group("fallarea"):
						found_real_collision = true
#						print("Found a fallarea named: " + found_area.name)
						return checkposition
			pass
		var max_fall_position_checks = 90
		if i == max_fall_position_checks:
#			print("Did not find a fall end location after checking a distance of " + String(max_fall_position_checks * check_distance))
			return null
		pass
	
	pass
	
func get_valid_fallgrab_area():
	var did_we_find_it = false
	var found_jumparea = null
	var space_state = get_world_2d().get_direct_space_state()
	var checkposition = global_position
	# Old results array based on checking a point
#	var results_array = space_state.intersect_point(checkposition, 32, [], 2147483647, false, true)
	
	var shape_query : Physics2DShapeQueryParameters = Physics2DShapeQueryParameters.new()
	var collision_object = $climbbox
	var shape = $climbbox/CollisionShape2D.shape
	
	shape_query.collide_with_areas = true
	shape_query.collide_with_bodies = false
	shape_query.shape_rid = shape.get_rid()
	shape_query.transform = collision_object.global_transform
	
	var results_array = space_state.intersect_shape(shape_query)
	
	if results_array.empty():
#			print("Fall check array was totally empty")
		pass
	else:
		for a in results_array:
			var found_area = a["collider"]
#				print("Found area while falling: " + found_area.name)
			if found_area.name != name:
				if found_area.is_in_group("jumparea"):
					if found_area.terrain_string == "wall" || found_area.terrain_string == "ledge":
						fallgrab_area = found_area
						did_we_find_it = true
						fallgrab_type = terrain.get_from_string(found_area.terrain_string)
#		if !did_we_find_it:
#			print("Did not find a grabbable area.")
	
			
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
	set_directionality(movedir)
	damage_loop()
	sun_damage_loop(delta)
	block_loop(delta)
	
	if movedir != Vector2(0,0):
		if is_running:
			switch_anim("run")
			damage_stamina(stamina_drain_run, delta)
		else:
			switch_anim("walk")
			if !is_blocking:
				heal_stamina(stamina_heal_walk, delta)
	else:
		switch_anim("idle")
		if !is_blocking:
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
			if isinjumparea:
				set_state_crouch()

		
	elif Input.is_action_just_pressed("test_1"):
#		print("Switched to climbing")
#		set_state_climb()
		increase_health(90)
		print("TESTING: Health brought back to full")
		
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
#		if !item_was_picked_up:
#			if inventorymanager.has("food_sack"):
##				set_state_sackusing()
		
		
		
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
	
func set_terrains(new):
	previous_terrain = current_terrain
	current_terrain = new
	
	
	
#	print("Terrain set to " + terrain.string_from_terrain(current_terrain) + ", previous terrain set to " + terrain.string_from_terrain(previous_terrain))
	
		
func block_loop(delta):
#	is_blocking = false
#	if Input.is_action_pressed("test_1"):
#		print("input pressed")
#		if stamina > 0:
#			is_blocking = true
#			print("stamina's good")
#			damage_stamina(stamina_drain_block, delta)
#
#	if is_blocking:
#		shield_icon.visible = true
#	else:
#		shield_icon.visible = false
	pass

func state_veiled(delta):
	set_veiled_speed()
	assign_movedir_from_input()
	set_directionality(movedir)
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
		elif item_name == "food_sack":
			set_state_sackusing()
			pass
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
#	print("Stamina decreased by " + String(modification) + ", stamina now " + String(stamina))
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
	
func get_full_hoparea_path_from_relative_nodepath(nodePath):
	return helper.nodepath_to_usable_string_path("/root/Level/hop_areas/", nodePath)
	

	
func set_jump_animation_direction(start, end):
	var direction  = end - start
	direction = dir.closest_cardinal(direction)
	match direction:
		dir.LEFT:
			switch_anim_directional("jumpup", "left")
		dir.RIGHT:
			switch_anim_directional("jumpup", "right")
		dir.UP:
			switch_anim_directional("jumpup", "up")
		dir.DOWN:
			switch_anim_directional("jumpup", "down")
	pass
	
#---------------------Jump Work Area-----------------------------------------------
	
	
func set_state_crouch():
	state = "crouch"
	speed = 0
	
#	print("current_jumparea at crouch start: " + current_jumparea.name)
#	print("current_jumparea linked areas size: " + String(current_jumparea.linked_areas.size()))
	
	if linked_jumpareas.size() == 0:
#		print("Crouching, and linked jumpareas size is 0")
		clear_upcoming_jumparea()
		if current_jumparea.terrain_string == "ledge":
			movedir = dir.opposite(current_jumparea.updirection)
			set_directionality(movedir)
			switch_anim("crouch")
#		if current_jumparea.terrain_string == "ledge":
##			print("Crouching at a ledge")
#			pass
	else:
		set_first_upcoming_jumparea()
		set_upcoming_ledge()
		set_upcoming_terrain()
		if distance_to_upcoming_jumparea > reticule_visibility_min_distance:
			show_jump_reticule()
	
		if current_terrain == terrain.TYPE.GROUND:
			
			switch_anim("crouch")
	#		print("Terrain type is ground")
		elif current_terrain == terrain.TYPE.WALL:
			switch_anim_directional("climbhang", dir.string_from_direction(direction_to_upcoming_jumparea))
	#		print("Terrain type is wall")
			pass
		elif current_terrain == terrain.TYPE.LEDGE:
	#		#Should not be able to crouch on ledge
			pass
			
	#Testing ability to jump down a ledge. Will follow up on in state_crouch()
	if current_terrain == terrain.TYPE.GROUND && current_jumparea.terrain_string == "ledge" && current_jumparea.updirection == dir.UP:
		fall_check_direction = dir.DOWN
		check_fall = true
		checking_crouch_ledge_fall_validity = true
		pass
		
func set_first_upcoming_jumparea():
	upcoming_jumparea = linked_jumpareas[upcoming_jumparea_index]
	set_upcoming_jumparea_distance_and_direction()
#	print("direction to upcoming jumparea is: " + String(direction_to_upcoming_jumparea))
	pass
	
func set_upcoming_ledge():
	will_be_on_ledge = false
	can_side_climb_upcoming_ledge = false
	if upcoming_jumparea.terrain_string == "ledge":
		will_be_on_ledge = true
		var upcoming_ledge_bounds = upcoming_jumparea.get_node("CollisionShape2D")
		upcoming_ledge_l_bound = upcoming_jumparea.global_position.x - upcoming_ledge_bounds.shape.extents.x
		upcoming_ledge_r_bound = upcoming_jumparea.global_position.x + upcoming_ledge_bounds.shape.extents.x
		var upcoming_ledge_width = upcoming_ledge_bounds.shape.extents.x * 2
#		print("Upcoming ledge width: " + String(upcoming_ledge_width))
		if upcoming_ledge_width >= min_ledge_width_for_side_climb:
			can_side_climb_upcoming_ledge = true
	pass
		
func show_jump_reticule():
	is_using_jump_reticule = true
	jump_reticule = jump_reticule_resource.instance()
	jump_reticule.global_position = linked_jumpareas[upcoming_jumparea_index].global_position
	self.get_parent().add_child(jump_reticule)
	
func hide_jump_reticule():
	if is_using_jump_reticule:
		is_using_jump_reticule = false
		if jump_reticule != null:
	#		print("Queue freeing jump reticule: " + jump_reticule.name)
			jump_reticule.queue_free()
		
func instantiate_vanish_reticule(location):
	var reticule = vanish_reticule_resource.instance()
	reticule.global_position = location
	self.get_parent().add_child(reticule)

func state_crouch(delta):
#	print("Crouching")
	
	#Check for ability to jump down a ledge. If impossible, play head shaking animation then exit state.
	#This should be resuming after fall direction was checked in the last frame.
	if checking_crouch_ledge_fall_validity:
		checking_crouch_ledge_fall_validity = false
		if valid_fall_location == null:
			$anim.play("headshake")
			checking_crouch_ledge_fall_validity = true
			return
		return
	
	
	if upcoming_jumparea != null:
		if is_using_jump_reticule:
			if Input.is_action_just_pressed("left") || Input.is_action_just_pressed("up"):
				increment_upcoming_jumparea()
				set_upcoming_jumparea_distance_and_direction()
				set_upcoming_ledge()
				set_upcoming_terrain()
				reposition_jump_reticule()
			elif Input.is_action_just_pressed("right") || Input.is_action_just_pressed("down"):
				decrement_upcoming_jumparea()
				set_upcoming_jumparea_distance_and_direction()
				set_upcoming_ledge()
				set_upcoming_terrain()
				reposition_jump_reticule()
			
		#Set Movedir
		if current_jumparea.terrain_string == "ledge":
			movedir = dir.opposite(current_jumparea.updirection)
		#Deals with edge case where a wide ledge causes player to look to the side before jumping up
		elif upcoming_jumparea.terrain_string == "ledge" && upcoming_jumparea.updirection == dir.UP:
			movedir = dir.UP
		else:
			movedir = direction_to_upcoming_jumparea
		
		set_directionality(movedir)
		
		
	#Allow Crouch Cancellation	
	if current_terrain == terrain.TYPE.GROUND:
		if Input.is_action_just_pressed("sack"):
			set_state_default()
			hide_jump_reticule()
			
	#Switch to Ledge
		
			
	#Set Animation
	if current_terrain == terrain.TYPE.GROUND:
		switch_anim("crouch")
		
	elif current_terrain == terrain.TYPE.WALL:
		if upcoming_jumparea != null:
			switch_anim_directional("climbhang", dir.string_from_direction(direction_to_upcoming_jumparea))
		else:
			switch_anim_directional("climbhang", "up")
		pass
	elif current_terrain == terrain.TYPE.LEDGE:
		pass
		
	movement_loop()
	
	#Start Jump
	if Input.is_action_just_released("action"):
		
		if current_jumparea.terrain_string == "ledge":
			set_state_fall()
		else:
#			if linked_jumpareas.size() != 0:
			set_state_jump()
#			print("About to call hide jump reticule from state_crouch")
			hide_jump_reticule()
	pass
	
func set_upcoming_jumparea_distance_and_direction():
	direction_to_upcoming_jumparea = dir.closest_cardinal(upcoming_jumparea.global_position - global_position)
	distance_to_upcoming_jumparea = upcoming_jumparea.global_position.distance_to(global_position)
#	print("Distance to upcoming jumparea is " + String(distance_to_upcoming_jumparea))
	pass
	
func increment_upcoming_jumparea():
	upcoming_jumparea_index = upcoming_jumparea_index + 1
	if upcoming_jumparea_index >= linked_jumpareas.size():
		upcoming_jumparea_index = 0
	upcoming_jumparea = linked_jumpareas[upcoming_jumparea_index]
	pass
	
func decrement_upcoming_jumparea():
	upcoming_jumparea_index = upcoming_jumparea_index - 1
	if upcoming_jumparea_index < 0:
		upcoming_jumparea_index = linked_jumpareas.size() - 1
	upcoming_jumparea = linked_jumpareas[upcoming_jumparea_index]
	pass
	
func clear_upcoming_jumparea():
	upcoming_jumparea = null
	direction_to_upcoming_jumparea = null
	distance_to_upcoming_jumparea = null
	upcoming_terrain = null
	
func set_upcoming_terrain():
	upcoming_terrain = upcoming_jumparea.terrain_type
	
func reposition_jump_reticule():
	jump_reticule.global_position = upcoming_jumparea.global_position
	
func set_state_jump():
	
	state = "jump"
	jumpstartpos = global_position
	jumpweight = 0
	jumpspeed = 2.2
	
	if upcoming_jumparea != null:
		jumpendpos = upcoming_jumparea.global_position
		jumpspeed = jumpspeed / distance_to_upcoming_jumparea
		
		#Tiny hop slowing
		if distance_to_upcoming_jumparea < min_distance_for_short_jump:
			jumpspeed = jumpspeed * tiny_jump_speed_modifier
		
		#Jumping up to wide ledge
		if upcoming_jumparea.terrain_type == terrain.TYPE.LEDGE:
			if upcoming_jumparea.updirection == dir.UP && can_side_climb_upcoming_ledge:
				jumpendpos = Vector2(global_position.x, upcoming_jumparea.global_position.y)	
			
		set_current_jumpheight()
		
		if upcoming_jumparea.terrain_type == terrain.TYPE.GROUND:
			set_ground_jump_animation()
		else:
			set_wall_jump_animation()
	else:
		jumpendpos = global_position
		current_jumpheight = short_jumpheight
		if current_jumparea.terrain_type == terrain.TYPE.WALL:
			switch_anim_directional("landjump", "up")
		else:
			switch_anim("jump")
		jumpspeed = 0.05
	
	reset_and_start_grace_timer()
	pass	
	
func set_ground_jump_animation():
	var animprefix = "landjump"
	var animsuffix = dir.string_from_direction(direction_to_upcoming_jumparea)
	switch_anim_directional(animprefix, animsuffix)
	
	pass
	
func set_wall_jump_animation():
	var animprefix = ""
	var animsuffix = ""
	var suffixpreset = false
	
	if upcoming_jumparea.terrain_type == terrain.TYPE.LEDGE:
		if upcoming_jumparea.updirection == dir.UP && can_side_climb_upcoming_ledge:
			suffixpreset = true
			animsuffix = dir.string_from_direction(dir.UP)
	
	if upcoming_jumparea.terrain_type == terrain.TYPE.WALL:
		animprefix = "landjump"
	elif current_jumparea.terrain_type == terrain.TYPE.GROUND && (upcoming_jumparea.terrain_type == terrain.TYPE.LEDGE || upcoming_jumparea.terrain_type == terrain.TYPE.WALL):
		animprefix = "jumpup"
	else:
		animprefix = "jumpdown"

	if !suffixpreset:
		animsuffix = dir.string_from_direction(direction_to_upcoming_jumparea)
	
#	print("Jump animation should be " + animprefix + animsuffix)
	switch_anim_directional(animprefix, animsuffix)
	

func set_current_jumpheight():
#	print("Dist to upcoming area: " + String(distance_to_upcoming_jumparea))
	if distance_to_upcoming_jumparea >= min_distance_for_long_jump:
		current_jumpheight = long_jumpheight
#		print("Making a longer jump")
	elif distance_to_upcoming_jumparea >= min_distance_for_short_jump:
		current_jumpheight = short_jumpheight
#		print("Making a short jump")
	else:
		current_jumpheight = tiny_jumpheight
#		print("Making a tiny jump")

func state_jump(delta):
	global_position = jumpstartpos.linear_interpolate(jumpendpos, jumpweight)
	
	#Y jump arc modification
	var pi_weight = jumpweight * 3.14
	var sine_y = current_jumpheight * sin(pi_weight)
	global_position = Vector2(global_position.x, global_position.y - sine_y)
	
	jumpweight += jumpspeed
	if jumpweight >= 1:
		global_position = jumpendpos
		
		if upcoming_jumparea != null:
#			print("There is an upcoming jumparea")
			set_current_jumparea_and_info(upcoming_jumparea)
			set_terrains(current_jumparea.terrain_type)
			
		set_post_jump_state()
		
	pass
	
			
func set_post_jump_state():
	if current_terrain == terrain.TYPE.WALL:
		if Input.is_action_pressed("sack") || is_grace_timing:
			set_state_climb()
		else:
			set_state_fall()
	elif current_terrain == terrain.TYPE.GROUND:
		set_state_landing()
	elif current_terrain == terrain.TYPE.LEDGE:
#		retrieve_new_ledge()
		if Input.is_action_pressed("sack") || is_grace_timing:
			set_state_ledge()
		else:
			set_state_fall()
	
	
func set_state_ledge():
	state = "ledge"
#	print("---Now on ledge---")
	
#	$CollisionShape2D.disabled = true
	set_level_collision_to_off()
	
#	if current_jumparea == null:
#		print("Problem: jumparea is null.")
#		return
	fall_check_direction = dir.opposite(current_jumparea.updirection)
	
	
	var ledge_bounds = current_jumparea.get_node("CollisionShape2D")

	if current_jumparea.updirection == dir.UP && can_side_climb_current_ledge:
		speed = ledgeclimbspeed
	else:
		speed = 0
		match current_jumparea.updirection:
			dir.LEFT:
				switch_anim_directional("cling", "left")
			dir.RIGHT:
				switch_anim_directional("cling", "right")
			dir.DOWN:
				switch_anim_directional("cling", "down")
			dir.UP:
				switch_anim_directional("cling", "up")
				
	
func state_ledge(delta):
	
	var upledge_not_side_climbable

	if current_jumparea.updirection == dir.UP && can_side_climb_current_ledge:
		
		movedir = dir.l_r_direction_from_input()
		
		if $anim.current_animation.begins_with("climbheadshake") || !Input.is_action_pressed("sack"):
			movedir = Vector2(0,0)
		
		if movedir.x < 0 && global_position.x <= current_ledge_l_bound:
			movedir.x = 0
		if movedir.x > 0 && global_position.x >= current_ledge_r_bound:
			movedir.x = 0
			
		if movedir != Vector2(0,0):
			if !$anim.current_animation.begins_with("climbheadshake"):
				switch_anim("ledgeclimb")
		elif !$anim.current_animation.begins_with("climbheadshake"):
			$anim.stop()
	else:
		movedir = dir.CENTER
		
		
	if Input.is_action_just_released("sack"):
		if valid_fall_location == null:
			switch_anim("climbheadshake")
		
	if !Input.is_action_pressed("sack"):
		if valid_fall_location != null:
			if !is_grace_timing:
				movedir = dir.UP
				set_directionality(movedir)
				set_state_fall()
#				print("falling")

#		if !is_grace_timing:
#			set_state_fall()
#		pass
	elif Input.is_action_just_pressed("action"):
		if current_jumparea.canclimbup:
			set_state_pullup()
		else:
#			print("Can't climb up ledge " + current_ledge.name)
			movedir = dir.CENTER
		pass
		
	set_directionality(movedir)
	movement_loop()
	
	check_fall = true
	pass
	
func set_state_climb():
	state = "climb"
	fall_check_direction = dir.DOWN
	speed = climbspeed
	switch_anim("climb")
	set_level_collision_to_mountain()
	
func state_climb(delta):
	assign_movedir_from_input()
	if $anim.current_animation.begins_with("climbheadshake") || !Input.is_action_pressed("sack"):
		movedir = Vector2(0,0)
		
#	print("Movedir while climbing is: " + String(movedir))
	set_directionality(movedir)

#	if movedir != Vector2(0,0):
#		switch_anim("climb")
#	else:
#		$anim.stop()
		
	if movedir != Vector2(0,0):
		if !$anim.current_animation.begins_with("climbheadshake"):
			switch_anim("climb")
	elif !$anim.current_animation.begins_with("climbheadshake"):
		$anim.stop()

	movement_loop()
	
	if Input.is_action_pressed("action"):
		if isinjumparea:
			set_state_crouch()
	
#	if !Input.is_action_pressed("sack"):
#		if !is_grace_timing:
#			set_state_fall()
			
	if Input.is_action_just_released("sack"):
		if valid_fall_location == null:
			if facedir == dir.LEFT:
				$anim.play("climbheadshakeleft")
			else:
				$anim.play("climbheadshakeright")
		
	if !Input.is_action_pressed("sack"):
		if valid_fall_location != null:
			if !is_grace_timing:
				set_state_fall()
			
	check_fall = true		
	
	pass
	
func set_state_pullup():
	state = "pullup"
	switch_anim("pullup")
	
#	$CollisionShape2D.disabled = true
	set_level_collision_to_off()
	
	if current_jumparea.updirection == dir.RIGHT || current_jumparea.updirection == dir.LEFT:
		jumpspeed = sidepullupspeed
#		print("Pulling up to the side")
	else: 
		jumpspeed = verticalpullupspeed
#		print("Pulling up vertically")
	
	jumpendpos = global_position + ($CollisionShape2D.shape.extents.x * current_jumparea.updirection) 
	jumpstartpos = global_position
	
#	print("Pullup start at: " + String(jumpstartpos))
#	print("Pullup end   at: " + String(jumpendpos))
	jumpweight = 0

	
func state_pullup(delta):
#	print("Pulling up")
	global_position = jumpstartpos.linear_interpolate(jumpendpos, jumpweight)
	jumpweight += jumpspeed
	if jumpweight >= 1:
		set_state_default()
#		$CollisionShape2D.disabled = false
		set_level_collision_to_ground()
		set_terrains(terrain.TYPE.GROUND)
#		print("Current terrain is " + terrain.string_from_terrain(current_terrain))
#		print("---- just pulled up onto ledge ----")
	pass
	
func set_state_fall():
	state = "fall"
	
	is_coming_from_fall = true
	
	#Sets timer window within which player can regrab a ledge he just jumped off
	if current_terrain == terrain.TYPE.GROUND && current_jumparea.terrain_string == "ledge":
		ledge_catch_timer = ledge_catch_leeway
		can_ledge_catch = true
#		print("Setting can_catch_ledge to true")
	
	#This starts a process in _physics_process() of finding where the fall ends
	check_fall = true
	
	jumpstartpos = global_position
	jumpendpos = null
#	jumpendpos set in physics_process
	jumpweight = 0
	jumpspeed = fallspeed
	
	match current_terrain:
		terrain.TYPE.WALL:
#			print("About to start fall from wall")
			fall_check_direction = dir.DOWN
			movedir = dir.DOWN
			facedir = dir.UP
			switch_anim_directional("fallbehind", dir.string_from_direction(facedir))
			pass
		terrain.TYPE.LEDGE:
#			print("About to start fall from ledge")
			fall_check_direction = dir.opposite(current_jumparea.updirection)
#			print("Ledge fall direction: " + String(fall_check_direction))
			switch_anim("fallbehind")

		terrain.TYPE.GROUND:
			if current_jumparea.terrain_string == "ledge":
#				retrieve_new_ledge()
				var ledge_jumpdown_direction = dir.opposite(current_jumparea.updirection)
				fall_check_direction = ledge_jumpdown_direction
#				print("Attempting to fall to lower ground from a ledge")
				movedir = ledge_jumpdown_direction
				facedir = ledge_jumpdown_direction
				switch_anim_directional("fallbehind", dir.string_from_direction(facedir))
			else:
				print("Warning: Trying to fall from the ground with no ledge to fall from")
			switch_anim("fallbehind")
			
		_:
			print("!! --Found no correct terrain state to fall from-- !!")
			pass
	
#	$CollisionShape2D.disabled = true
	set_level_collision_to_off()
			
	pass
	
	
func state_fall(delta):
#	print("Falling")
	if jumpendpos == null:
		if valid_fall_location != null:
			jumpendpos = valid_fall_location
			
			falldistance = jumpendpos.distance_to(jumpstartpos)
			
			#Invalidates ledge catch ability if the jump is too short
			if falldistance < min_height_for_ledge_catch:
				can_ledge_catch = false
				ledge_catch_timer = 0
			
			if jumpendpos.distance_to(jumpstartpos) < general_hop_distance:
				jumpspeed = .1
#				print("Fall distance: " + String(jumpendpos.distance_to(jumpstartpos)))
#				print("Falling from a hop.")
				pass
			else:
#				print("Falling from a longer distance")
				jumpspeed = jumpspeed / falldistance
				pass
#			print("Set jump end position")
		else:
			return
	
	#Immediately catching a ledge after jump
	if can_ledge_catch:
		ledge_catch_timer = ledge_catch_timer - delta
		if ledge_catch_timer <= 0 || Input.is_action_just_pressed("sack"):
			ledge_catch_timer = 0
			can_ledge_catch = false
#			print("-no more ledge catching-")
		if Input.is_action_just_pressed("sack"):
			global_position = Vector2(global_position.x, current_jumparea.global_position.y)
			set_state_ledge()
			set_terrains(terrain.TYPE.LEDGE)
			return
	
	#Turning during a fall	
	var direction_input = dir.direction_just_pressed_from_input()
	
	if direction_input != dir.CENTER && direction_input != facedir:
		facedir = dir.rotate_90_towards_direction(facedir, direction_input)
		switch_anim_directional("fallbehind", dir.string_from_direction(facedir))
	#End turning during a fall
			
	#Reconnecting to wall
	if facedir == dir.UP:
		#Note: setting check_fallgrab to true triggers a check to be performed in the physics_process function
		check_fallgrab = true
			
		if Input.is_action_just_pressed("sack"):
		#again, this has been previously set in physics_process
			if fallgrab_area != null:
				jumpendpos = null
				valid_fall_location = null
				
				if fallgrab_type == terrain.TYPE.WALL:
					set_state_climb()
					set_terrains(terrain.TYPE.WALL)
					global_position = fallgrab_area.global_position
					return
				elif fallgrab_type == terrain.TYPE.LEDGE:
					set_state_ledge()
					set_terrains(terrain.TYPE.LEDGE)
					global_position = Vector2(global_position.x, fallgrab_area.global_position.y)
					return
				fallgrab_area = null
			
	#End reconnecting to wall
		
	global_position = jumpstartpos.linear_interpolate(jumpendpos, jumpweight)
	jumpweight += jumpspeed
	if jumpweight >= 1:
		jumpendpos = null
		valid_fall_location = null
#		set_state_default()
		set_state_landing()
		set_terrains(terrain.TYPE.GROUND)
#		$CollisionShape2D.disabled = false
		set_level_collision_to_ground()
#		print("fall ended")
		# NOTE: If not sensing correct jumparea after fall (especially for downward jumpareas),
		#       try moving the jumparea at the base of the cliff further away from the cliff physically.
		#       this seems to make it so that if the one at the top of the cliff is sensed, it is sensed
		#       first and overridden by the second.
	pass
	
func set_state_landing():
	state = "landing"
	if current_terrain == terrain.TYPE.WALL:
		switch_anim_directional("land", "down")
		landingtimer = falllandingtime
	else:
		switch_anim("land")
		landingtimer = jumplandingtime
		
	if is_coming_from_fall:
		take_landing_damage()
		is_coming_from_fall = false
	
func take_landing_damage():
#	print("Fall distance was " + String(falldistance))
	var damage = 0
	var t

#	if falldistance < max_low_fall_height:
#		damage = low_fall_damage
#	elif falldistance < max_bouldering_height:
#		t = get_landing_t(max_low_fall_height, max_bouldering_height, falldistance)
#		damage = interpolate(min_bouldering_damage, max_bouldering_damage, t)
#		pass
#	elif falldistance < max_mid_fall_height:
#		t = get_landing_t(max_bouldering_height, max_mid_fall_height, falldistance)
#		damage = interpolate(min_mid_fall_damage, max_mid_fall_damage, t)
#	elif falldistance < max_falldamage_height:
#		t = get_landing_t(max_mid_fall_height, max_falldamage_height, falldistance)
#		damage = interpolate(min_high_fall_damage, max_high_fall_damage, t)
#	else:
#		damage = max_high_fall_damage
#		pass
		
	t = get_landing_t(max_low_fall_height, max_falldamage_height, falldistance)
	
	var curved_damage_t = fall_damage_curve.interpolate(t)
	
	damage = interpolate(min_fall_damage, max_fall_damage, curved_damage_t)
	
	
#	print("T was: " + String(t))
#	print("Curved T was: " + String(curved_damage_t))
	
	#Reduces damage if you fall correctly
	if fall_check_direction == facedir:
		damage = damage * proper_landing_damage_reducer
	elif dir.is_90_degrees_away(fall_check_direction, facedir):
		damage = damage * side_landing_damage_reducer
	
#	print("Damage was: " + String(damage))
	decrease_health(damage)
	
	pass

func interpolate(start, end, t):
	return (start + (end - start) * t)
	
func get_landing_t(minval, maxval, currentval):
	var t = (currentval - float(minval)) / (maxval - minval)
	
	#	print("Min: " + String(minval))
#	print("Max: " + String(maxval))
#	print("Curr: " + String(currentval))
#
#	print("T for this value is: " + String(t))
	
	if t > 1:
		return 1
	elif t < 0:
		return 0
		
	return t
	
func state_landing(delta):
	landingtimer = landingtimer - delta
	if landingtimer <= 0:
		landingtimer = 0
		set_state_default()
	pass
	
	
#----------------------------------------------------------------------------
	
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
		set_directionality(movedir)
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
			if get_givable_in_vicinity() != null:
				var found_givable = get_givable_in_vicinity()
			else:
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
	
#func set_facedir():
##	var closestdistance = 0
##	for body in $sightbox.get_overlapping_bodies():
##		if body.get("TYPE") == "ENEMY":
##
##			istrackingenemy = true
##			var directiontowards : Vector2 = body.transform.origin - transform.origin
##			facedir = dir.closest_cardinal(directiontowards)
##		else:
##			istrackingenemy = false
##			.set_facedir()
#	.set_facedir()

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
	if !gamedata.get_experience("player", "burnedOnce"):
		gamedata.set_experience("player", "burnedOnce", true)
#		print("burned once set to " + String(dialogueparser.check_experience("burnedOnce")))
#	if(!dialogueparser.check_experience("burnedOnce")):
#		dialogueparser.set_experience("burnedOnce", true)

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
		elif obj.is_in_group("jumparea"):
#			print("Entered jumparea: " + obj.name)
			set_current_jumparea_and_info(obj)
			
		
		elif obj.is_in_group("sun_area"):
			sun_areas[obj.get_instance_id()] = obj
			
func set_current_jumparea_and_info(new_jumparea):
	
	current_jumparea = new_jumparea
	isinjumparea = true
	
#	print("Setting jumparea to new jumparea: " + new_jumparea.name)
	
	linked_jumpareas = []
	linked_jumpareas.clear()
	
	upcoming_jumparea_index = 0
	
	var count = 0
	if current_jumparea.linked_areas.size() != 0:
		for path in current_jumparea.linked_areas:
	#		count = count + 1
	#		print("Iteration count: " + String(count))
	#		print(path)
			var full_jumparea_path = get_full_hoparea_path_from_relative_nodepath(path)
		#	print("Jumparea path is " + String(linked_jumparea_path))
			var linked_jump_area = get_node(full_jumparea_path)
			if linked_jump_area.name != "hop_areas":
				linked_jumpareas.append(linked_jump_area)
		
		is_on_ledge = false
		if current_jumparea.terrain_string == "ledge":
#			current_ledge = get_ledge_from_jumparea(current_jumparea)
#			if current_ledge != null:
			is_on_ledge = true
			can_side_climb_current_ledge = false
			if current_jumparea.updirection == dir.UP:
				var ledge_bounds = current_jumparea.get_node("CollisionShape2D")
				current_ledge_l_bound = current_jumparea.global_position.x - ledge_bounds.shape.extents.x
				current_ledge_r_bound = current_jumparea.global_position.x + ledge_bounds.shape.extents.x
				var current_ledge_width = ledge_bounds.shape.extents.x * 2
#					print("Current ledge width: " + String(current_ledge_width))
				if current_ledge_width >= min_ledge_width_for_side_climb:
					can_side_climb_current_ledge = true

	pass
	
#func get_ledge_from_jumparea(jumparea):
#	if jumparea.terrain_string == "ledge":
#		var relative_ledge_path = jumparea.connected_object
#		var full_ledge_path = get_full_hoparea_path_from_relative_nodepath(relative_ledge_path)
#		return get_node(full_ledge_path)
#	return 
			
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
		elif obj.is_in_group("jumparea"):
			if state != "jump" && current_jumparea == obj:
#				print("Left jumparea: " + obj.name)
				isinjumparea = false
#				current_jumparea = null
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

#func add_sprinkle():
#	var sprinkle = sprinkleresource.instance()
#	sprinkle.position = transform.get_origin()
#	sprinkle.position.x += facedir.x * sprinkleoffset
#	sprinkle.position.y += facedir.y * sprinkleoffset
#	if facedir.x == 0:
#		if sprinkle.position.y < position.y:
#			sprinkle.set_z_index(-1)
#		elif sprinkle.position.y > position.y:
#			sprinkle.set_z_index(1)
#	else:
#		sprinkle.set_z_index(0)
#
#	self.get_parent().add_child(sprinkle)
	
	
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
		food_sack.open(is_foodgiving, cardinal_dir, givable)
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
	
#Keeps player facing the defined (static) direction during animation
func switch_anim_static(animation):
	var nextanim : String = animation + staticdir
	if $anim.current_animation != nextanim:
		$anim.play(nextanim)
		
#Allows for switching to a one-off singular direction for the duration of animation
#animation and direction should be strings
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
	elif anim_name == "headshake":
		set_state_default()
	elif "givefood" in anim_name:
		switch_anim_static("holdidle")
		
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
	
func place_food_in_basket(food_texture):
	switch_anim("givefood")
	#TODO: Connect food texture so it looks correct
	
	pass
	
func set_level_collision_to_ground():
	set_collision_mask_bit(coll.LAYER.GROUND, true)
	set_collision_mask_bit(coll.LAYER.MOUNTAIN, false)
	pass
	
func set_level_collision_to_mountain():
	set_collision_mask_bit(coll.LAYER.GROUND, false)
	set_collision_mask_bit(coll.LAYER.MOUNTAIN, true)
	pass
	
func set_level_collision_to_off():
	set_collision_mask_bit(coll.LAYER.GROUND, false)
	set_collision_mask_bit(coll.LAYER.MOUNTAIN, false)
	pass

#func add_sprinkle():
#	var sprinkle = sprinkleresource.instance()
#	sprinkle.position = transform.get_origin()
#	sprinkle.position.x += facedir.x * sprinkleoffset
#	sprinkle.position.y += facedir.y * sprinkleoffset
#	if facedir.x == 0:
#		if sprinkle.position.y < position.y:
#			sprinkle.set_z_index(-1)
#		elif sprinkle.position.y > position.y:
#			sprinkle.set_z_index(1)
#	else:
#		sprinkle.set_z_index(0)
#
#	self.get_parent().add_child(sprinkle)