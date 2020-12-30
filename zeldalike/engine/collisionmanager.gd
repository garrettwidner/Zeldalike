extends Node

enum LAYER {
		DEFAULT
		PLAYER
		ENEMY
		GROUND
		MOUNTAIN
		CORRAL
		}

func layer_to_string(layer):
	match layer:
		LAYER.DEFAULT:
			return "default"
		LAYER.PLAYER:
			return "player"
		LAYER.ENEMY:
			return "enemy"
		LAYER.GROUND:
			return "ground"
		LAYER.MOUNTAIN:
			return "mountain"
		LAYER.CORRAL:
			return "corral"
			
func string_to_layer(string):
	match string:
		"default":
			return LAYER.DEFAULT
		"player":
			return LAYER.PLAYER
		"enemy":
			return LAYER.ENEMY
		"ground":
			return LAYER.GROUND
		"mountain":
			return LAYER.MOUNTAIN
		"corral":
			return LAYER.CORRAL
			
func supplantive_single_layer_true(layer):
	return pow(2,layer)
	
func additive_single_layer_true(layer, current_mask):
	pass
	
func additive_single_layer_false(layer, current_mask):
	
	pass

func _ready():
	pass # Replace with function body.

func get_full_layer():
	
	pass
