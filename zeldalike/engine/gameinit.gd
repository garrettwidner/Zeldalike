extends Node2D

func _ready():
	var player = get_node("player")
	var interactibles = get_tree().get_nodes_in_group("interactible")
	var debugcount = 0
	print(interactibles.size())
	for i in range(interactibles.size()):
		var currentnode = get_node(interactibles[i].get_path())
		var area2Dnode = currentnode.get_node("Area2D")
		if(area2Dnode == null):
			print("Error: no area2D node found on interactible")	
		var args = Array([currentnode])
		area2Dnode.connect("body_entered", player, "_on_Area2D_body_entered",args)
		area2Dnode.connect("body_exited", player, "_on_Area2D_body_exited",args)
		debugcount = debugcount + 1
#		print("Connected interactible #" + String(debugcount) + " name of " + currentnode.name)
		