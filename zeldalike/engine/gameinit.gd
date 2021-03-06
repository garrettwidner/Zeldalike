extends CanvasLayer

var player
var cameracontroller
var scenechanger
var issetup = false
var screencover
var healthbar
var staminabar

var sceneblocks = []
var camareas = []

var new_entrance_number : int
var entrance_scene_block

enum COLL_LAYER{
	default = 0,
	lv1 = 1,
	lv2 = 2,
	lv3 = 3,
	lv4 = 4,
	player = 5,
	enemy = 6
	}
	
func perform_first_setup_if_needed(default_entrance):
	if !issetup:
#		print("First time setup being performed")
		issetup = true
		scenechanger = $scenechanger
		scenechanger.connect("scene_just_changed", self, "perform_preliminary_level_setup")
		scenechanger.connect("scene_change_finished", self, "perform_concluding_level_setup")
		scenechanger.connect("got_signal_to_change_scene", self, "get_changing_sceneblock")
		screencover = $screencover
		
		healthbar = get_node("GUI/HBoxContainer/Container/healthbar")
		staminabar = get_node("GUI/HBoxContainer/Container/staminabar")
		
		new_entrance_number = default_entrance
		
		perform_preliminary_level_setup()
		perform_concluding_level_setup()
		
		
#		player.run_setup()

func get_camarea_at_point(point):
	
	for i in range(camareas.size()):
#		print("--")
#		print("Checking camarea " + String(i) + " in scene")
		var pos = camareas[i].position
#		print("camarea position is " + String(pos))
		var extents = camareas[i].get_node("CollisionShape2D").shape.extents
		var left = pos.x - extents.x
		var right = pos.x + extents.x
		var top = pos.y - extents.y
		var bottom = pos.y + extents.y
		
#		print("Left extent is " + String(left))
#		print("Right extent is " + String(right))
#		print("Top extent is " + String(top))
#		print("Bottom extent is " + String(bottom))
#		print("Checked point is at " + String(point))
		
		if point.x > left && point.x < right:
			if point.y > top && point.y < bottom:
#				print("Camarea FOUND at checked position")
#				print("--")
				
				return camareas[i]
		
	pass
	
	print("Warning: No camarea found by game singleton at checked point: (" + String(point) + ")")
#	print("--")
	
	return null	

func perform_preliminary_level_setup():
#	print("-Game singleton performing preliminary level setup")
	player = get_node("/root/Level/YSort/actors/player")
	if player == null:
		print("Warning: game_singleton unable to find player")
		
	player.connect("on_initial_sun_check", self, "perform_sun_setups")
	var start_position = Vector2(30,126)
	
	cameracontroller = player.get_node("cameracontroller")
	if cameracontroller == null:
		print("Warning: gameinit.gd found cameracontroller null")
		
	
	connect_player_to_interactibles()
	connect_player_to_speechhittables()
	connect_player_to_searchareas()
	connect_player_to_hopareas()
	connect_player_to_leapareas()
	connect_player_to_jumpareas()
	connect_player_to_heightchangers()
	connect_cameracontroller_to_camareas()
	connect_player_to_sun_areas()
	connect_player_to_climbswitchareas()
	
	connect_sceneblocks()
	
	#Added or else scene is not set up enough for player to search for objects
	yield(get_tree().create_timer(.01), "timeout")

	var found_correct_sceneblock = false
	for sceneblock in sceneblocks:
		if sceneblock.entrance_number == new_entrance_number:
			entrance_scene_block = sceneblock
			found_correct_sceneblock = true
#			print("Scene block chosen for entrance is " + sceneblock.name)
#			print("It is located at " + String(sceneblock.position))

	if !found_correct_sceneblock:
		print("Unable to find starting sceneblock. Likely because the entrance number has not been set.")
		assert(found_correct_sceneblock)
			
#	print("Player running setup at position " + String(entrance_scene_block.spawnpoint.global_position) + " and facedir " + String(entrance_scene_block.entrance_facedir))
	player.run_setup(entrance_scene_block.spawnpoint.global_position, entrance_scene_block.entrance_facedir)

	var start_camarea = get_camarea_at_point(entrance_scene_block.spawnpoint.global_position)
	if start_camarea == null:
		pass
	else:
		cameracontroller.set_position_manual(true, entrance_scene_block.spawnpoint.global_position, start_camarea)
	
	healthbar.setup(player)
	staminabar.setup(player)
	
func perform_sun_setups(player, sun_start_strength):
	screencover.setup(player, sun_start_strength)
	pass
	
func perform_concluding_level_setup():
#	print("-Game singleton performing concluding level setup")
	player.run_startup()
#	print("Perform_setup() called from game singleton")
	pass
	
	
func change_scene(level_name, delay = 0.5):
	scenechanger.change_scene(level_name, delay)
	
func connect_sceneblocks():
	sceneblocks.clear()
	sceneblocks = get_tree().get_nodes_in_group("sceneblock")
	for i in range(sceneblocks.size()):
#		print("Found sceneblock " + String(i))
		var currentnode = get_node(sceneblocks[i].get_path())
		var area2Dnode = currentnode.get_node("Area2D")
		if(area2Dnode == null):
			print("Error: no area2D node found on sceneblock")
			return
		var args = Array([currentnode])
		area2Dnode.connect("body_entered", scenechanger, "on_Area2D_body_entered", args)
	pass
	
func get_changing_sceneblock(connecting_sceneblock):
	new_entrance_number = connecting_sceneblock.connecting_entrance
#	print("Game_singleton got the number of the entrance it is supposed to go to.")
#	print("This entrance is " + String(new_entrance_number))
	pass

func connect_player_to_interactibles():
	var interactibles = get_tree().get_nodes_in_group("interactible")
	for i in range(interactibles.size()):
		var currentnode = get_node(interactibles[i].get_path())
		var area2Dnode = currentnode.get_node("Area2D")
		if(area2Dnode == null):
			print("Error: no area2D node found on interactible")	
			return
		var args = Array([currentnode])
		area2Dnode.connect("body_entered", player, "_on_Area2D_body_entered",args)
		area2Dnode.connect("body_exited", player, "_on_Area2D_body_exited",args)
		
func connect_player_to_speechhittables():
	var speechhittables = get_tree().get_nodes_in_group("speechhittable")
	for i in range(speechhittables.size()):
		var currentnode = get_node(speechhittables[i].get_path())
		var area2Dnode = currentnode.get_node("Area2D")
		if(area2Dnode == null):
			print("Error: no area2D node found on speechhittable")	
			return
		var args = Array([currentnode])
		area2Dnode.connect("body_entered", player, "_on_Area2D_body_entered", args)
		area2Dnode.connect("body_exited", player, "_on_Area2D_body_exited", args)
	pass
	
func connect_player_to_searchareas():
	var searchareas = get_tree().get_nodes_in_group("searcharea")
	for i in range(searchareas.size()):
		var currentnode = get_node(searchareas[i].get_path())
		var area2Dnode = currentnode.get_node("Area2D")
		if(area2Dnode == null):
			print("Error: no area2D node found on searcharea")	
			return
		var args = Array([currentnode])
		area2Dnode.connect("body_entered", player, "_on_Area2D_body_entered", args)
		area2Dnode.connect("body_exited", player, "_on_Area2D_body_exited", args)
	pass
		
#func connect_player_to_hopareas():
#	var hopareas = get_tree().get_nodes_in_group("hoparea")
#	for i in range(hopareas.size()):
#		var currentnode = get_node(hopareas[i].get_path())
##		print(currentnode.name + " is a found hoparea")
#		var args = Array([currentnode])
#		currentnode.connect("body_exited", player, "_on_Area2D_body_exited", args)
#		currentnode.connect("body_entered", player, "_on_Area2D_body_entered", args)

func connect_player_to_hopareas():
	connect_player_to_area_type("hoparea")
	
func connect_player_to_leapareas():
	connect_player_to_area_type("leaparea")
	
func connect_player_to_jumpareas():
	connect_player_to_area_type("jumparea")
		
func connect_player_to_area_type(areatype):
	var areas = get_tree().get_nodes_in_group(areatype)
	for i in range(areas.size()):
		var currentnode = get_node(areas[i].get_path())
		var args = Array([currentnode])
		currentnode.connect("body_exited", player, "_on_Area2D_body_exited", args)
		currentnode.connect("body_entered", player, "_on_Area2D_body_entered", args)
		
func connect_player_to_heightchangers():
	var heightchangers = get_tree().get_nodes_in_group("heightchanger")
	for i in range(heightchangers.size()):
		var currentnode = get_node(heightchangers[i].get_path())
		var args = Array([currentnode])
		currentnode.connect("body_exited", player, "_on_Area2D_body_exited", args)

func add_interactible(interactible):
	print(interactible.name)
	var currentnode = get_node(interactible.name)
	var area2Dnode = currentnode.get_node("Area2D")
	if(area2Dnode == null):
		print("Error: no area2D node found on interactible")
	var args = Array([currentnode])
	area2Dnode.connect("body_entered", player, "_on_Area2D_body_entered",args)
	area2Dnode.connect("body_exited", player, "_on_Area2D_body_exited",args)
	print("Added interactible as interactible to scene: " + String(interactible.name))
	
func connect_cameracontroller_to_camareas():
	camareas = get_tree().get_nodes_in_group("camarea")
	for i in range(camareas.size()):
		var currentnode = get_node(camareas[i].get_path())
		var args = Array([currentnode])
		currentnode.connect("body_entered", cameracontroller, "_on_Area2D_body_entered", args)
		currentnode.connect("body_exited", cameracontroller, "_on_Area2D_body_exited", args)

func connect_player_to_sun_areas():
	var sun_areas = get_tree().get_nodes_in_group("sun_area")
	var sun_area_count
	for i in range(sun_areas.size()):
		sun_area_count = i + 1
		var currentnode = get_node(sun_areas[i].get_path())
		var args = Array([currentnode])
		currentnode.connect("body_entered", player, "_on_Area2D_body_entered", args)
		currentnode.connect("body_exited", player, "_on_Area2D_body_exited", args)
#	print("Connected " + String(sun_area_count) + " sun areas to player") 

func connect_player_to_climbswitchareas():
	connect_player_to_area_type("climbswitcharea")