extends Node

enum TYPE {
				GROUND
				WALL
				LEDGE
				AIR
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
		"air":
			return TYPE.AIR
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
		TYPE.AIR:
			return "air"
		TYPE.NONE:
			return "none"