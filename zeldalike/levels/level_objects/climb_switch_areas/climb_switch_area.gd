extends Area2D

export var climb_string_1 : String
export var climb_string_2 : String

var climb_type_1 
var climb_type_2 

func _ready():
	climb_type_1 = terrain.get_from_string(climb_string_1)
	climb_type_2 = terrain.get_from_string(climb_string_2)
	
	pass 

