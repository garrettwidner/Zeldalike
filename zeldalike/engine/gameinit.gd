extends Node2D

var player
var cameracontroller

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
	connect_player_to_interactibles()
	connect_player_to_heightchangers()
	connect_player_to_zindexchangers()
	connect_player_to_hopareas()
	connect_cameracontroller_to_camareas()

func connect_cameracontroller_to_camareas():
	cameracontroller = get_node("player/cameracontroller")
	var camareas = get_tree().get_nodes_in_group("camarea")
	for i in range(camareas.size()):
		var currentnode = get_node(camareas[i].get_path())
		var args = Array([currentnode])
		currentnode.connect("body_entered", cameracontroller, "_on_Area2D_body_entered", args)
		currentnode.connect("body_exited", cameracontroller, "_on_Area2D_body_exited", args)
	
func connect_player_to_interactibles():
	player = get_node("player")
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

func connect_player_to_heightchangers():
	player = get_node("player")
	var heightchangers = get_tree().get_nodes_in_group("heightchanger")
	for i in range(heightchangers.size()):
		var currentnode = get_node(heightchangers[i].get_path())
		var area2Dnode = currentnode.get_node("Area2D")
		if area2Dnode == null:
			print("Error: no area2D node found on heightchanger")
			return
		var args = Array([currentnode])
		area2Dnode.connect("body_exited", player, "_on_Area2D_body_exited",args)
		
func connect_player_to_zindexchangers():
	player = get_node("player")
	var zindexchangers = get_tree().get_nodes_in_group("zindexchanger")
	for i in range(zindexchangers.size()):
		var currentnode = get_node(zindexchangers[i].get_path())
		var area2Dnode = currentnode.get_node("Area2D")
		if area2Dnode == null:
			print("Error: no area2D node found on zindexchanger")
			return
		var args = Array([currentnode])
		area2Dnode.connect("body_exited", player, "_on_Area2D_body_exited", args)
		area2Dnode.connect("body_entered", player, "_on_Area2D_body_entered", args)
		
func connect_player_to_hopareas():
	player = get_node("player")
	var hopareas = get_tree().get_nodes_in_group("hoparea")
	for i in range(hopareas.size()):
		var currentnode = get_node(hopareas[i].get_path())
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