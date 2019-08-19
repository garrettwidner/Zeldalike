extends Node2D

var player
var cameracontroller

func _ready():
	connect_player_to_interactibles()
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
	
		
#func add_interactible(interactible):
#	print(interactible.name)
#	var currentnode = get_node(interactible.name)
#	var area2Dnode = currentnode.get_node("Area2D")
#	if(area2Dnode == null):
#		print("Error: no area2D node found on interactible")
#	var args = Array([currentnode])
#	area2Dnode.connect("body_entered", player, "_on_Area2D_body_entered",args)
#	area2Dnode.connect("body_exited", player, "_on_Area2D_body_exited",args)
#	print("Added interactible as interactible to scene: " + String(interactible.name))