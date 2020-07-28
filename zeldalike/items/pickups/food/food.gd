extends Area2D

export var health : float = 1.0
var bite_health
export var bites : int = 1
export var fits_in_sack : bool = true
signal on_eaten
var destroy_self = false
export(Array, Texture) var bite_visuals
var bite_visual_index = 0

func _ready():
	bite_health = health / bites
	if bite_visuals.size() != bites:
		print("WARNING: ''" + name + "'' does not have a visual for every level of bite")

func _process(delta):
	if destroy_self:
		queue_free()

func was_bitten():
	bites = bites - 1
	bite_visual_index = bite_visual_index + 1
	if bites <= 0:
		emit_signal("on_eaten")
		destroy_self = true
	else:
		$Sprite.texture = bite_visuals[bite_visual_index]