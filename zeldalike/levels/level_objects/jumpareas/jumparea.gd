extends Area2D

export var linked_area1 : NodePath 
export var linked_area2 : NodePath	
export var linked_area3 : NodePath
export var linked_area4 : NodePath

var linked_areas

export var terrain_string : String
var terrain_type 

export var connected_object : NodePath

func _ready():
	linked_areas = []
	if linked_area1 != null:
		linked_areas.push_back(linked_area1)
	if linked_area2 != null:
		linked_areas.push_back(linked_area2)
	if linked_area3 != null:
		linked_areas.push_back(linked_area3)
	if linked_area4 != null:
		linked_areas.push_back(linked_area4)
		
#	print("--Jumpareas seen by " + name)
#	for jumparea in linked_areas:
#		print(jumparea)

		
	if terrain_string == "land":
		terrain_type = terrain.TYPE.GROUND
	elif terrain_string == "wall":
		terrain_type = terrain.TYPE.WALL
	elif terrain_string == "ledge":
		terrain_type = terrain.TYPE.LEDGE
		
	pass