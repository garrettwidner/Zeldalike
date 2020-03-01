extends Node2D

var player
var cameracontroller
export var scene_name : String = "Level"

#In order to set up a new scene, must have the full suite of objects.

#Must also set up two new json files in dialogue/events and dialogue/story
#called "scenename_events.json" and "scenename_story.json".

#Must also change the Scene Name field of the base "Level" node to the actual
#name of the scene in the file system.

enum COLL_LAYER{
	default = 0,
	lv1 = 1,
	lv2 = 2,
	lv3 = 3,
	lv4 = 4,
	player = 5,
	enemy = 6
	}

func _ready():
	player = get_node("YSort/actors/player")
	connect_player_to_interactibles()
	connect_player_to_speechhittables()
	connect_player_to_searchareas()
#	connect_player_to_heightchangers()
#	connect_player_to_zindexchangers()
	connect_player_to_hopareas()
	connect_cameracontroller_to_camareas()
	connect_player_to_sun_areas()
	
	connect_player_to("interactible")

func connect_player_to(group):
#	var group_members = get_tree().get_nodes_in_group(group)
#	var groupings = get_tree().get_children()
#	for grouping in groupings:
#		print(grouping.name
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

#func connect_player_to_heightchangers():
#	var heightchangers = get_tree().get_nodes_in_group("heightchanger")
#	for i in range(heightchangers.size()):
#		var currentnode = get_node(heightchangers[i].get_path())
#		var area2Dnode = currentnode.get_node("Area2D")
#		if area2Dnode == null:
#			print("Error: no area2D node found on heightchanger")
#			return
#		var args = Array([currentnode])
#		area2Dnode.connect("body_exited", player, "_on_Area2D_body_exited",args)
		
#func connect_player_to_zindexchangers():
#	var zindexchangers = get_tree().get_nodes_in_group("zindexchanger")
#	for i in range(zindexchangers.size()):
#		var currentnode = get_node(zindexchangers[i].get_path())
#		var area2Dnode = currentnode.get_node("Area2D")
#		if area2Dnode == null:
#			print("Error: no area2D node found on zindexchanger")
#			return
#		var args = Array([currentnode])
#		area2Dnode.connect("body_exited", player, "_on_Area2D_body_exited", args)
#		area2Dnode.connect("body_entered", player, "_on_Area2D_body_entered", args)
		
func connect_player_to_hopareas():
	var hopareas = get_tree().get_nodes_in_group("hoparea")
	for i in range(hopareas.size()):
		var currentnode = get_node(hopareas[i].get_path())
#		print(currentnode.name + " is a found hoparea")
		var args = Array([currentnode])
		currentnode.connect("body_exited", player, "_on_Area2D_body_exited", args)
		currentnode.connect("body_entered", player, "_on_Area2D_body_entered", args)
		
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
	cameracontroller = get_node("YSort/actors/player/cameracontroller")
	if cameracontroller == null:
		print("Warning: gameinit.gd found cameracontroller null")
	
	var camareas = get_tree().get_nodes_in_group("camarea")
	for i in range(camareas.size()):
		var currentnode = get_node(camareas[i].get_path())
		var args = Array([currentnode])
		currentnode.connect("body_entered", cameracontroller, "_on_Area2D_body_entered", args)
		currentnode.connect("body_exited", cameracontroller, "_on_Area2D_body_exited", args)

func connect_player_to_sun_areas():
	var sun_areas = get_tree().get_nodes_in_group("sun_area")
	for i in range(sun_areas.size()):
		var currentnode = get_node(sun_areas[i].get_path())
		var args = Array([currentnode])
		currentnode.connect("body_entered", player, "_on_Area2D_body_entered", args)
		currentnode.connect("body_exited", player, "_on_Area2D_body_exited", args)