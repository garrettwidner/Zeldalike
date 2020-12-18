extends Node

enum TYPE {
				GROUND
				WALL
				LEDGE
				}
				
func get_from_string(string):
	match string:
		"ground":
			return TYPE.GROUND
		"wall":
			return TYPE.WALL
		"ledge":
			return TYPE.LEDGE
			
func string_from_terrain(terrain):
	match terrain:
		TYPE.GROUND:
			return "ground"
		TYPE.WALL:
			return "wall"
		TYPE.LEDGE:
			return "ledge"