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