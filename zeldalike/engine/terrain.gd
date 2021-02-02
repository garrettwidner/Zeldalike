extends Node

enum TYPE {
				GROUND
				WALL
				LEDGE
				CLING
				NONE
				}
				
func get_from_string(string):
	match string:
		"ground":
			return TYPE.GROUND
		"wall":
			return TYPE.WALL
		"ledge":
			return TYPE.LEDGE
		"cling":
			return TYPE.CLING
		"none":
			return TYPE.NONE
		_:
			print("WARNING: terrain.get_from_string() received string '" + string + "', which is not a valid type of terrain.")
			
func string_from_terrain(terrain):
	match terrain:
		TYPE.GROUND:
			return "ground"
		TYPE.WALL:
			return "wall"
		TYPE.LEDGE:
			return "ledge"
		TYPE.CLING:
			return "cling"
		TYPE.NONE:
			return "none"