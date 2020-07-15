extends Area2D

export var health : float = 1.0
export var bites : int = 1
export var fits_in_sack : bool = true
signal on_eaten
var destroy_self = false

func _process(delta):
	if destroy_self:
		queue_free()

func was_bitten():
	bites = bites - 1
	if bites <= 0:
		emit_signal("on_eaten")
		destroy_self = true