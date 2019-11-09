extends Node

export var health : float = 1.0
export var bites : int = 3
signal on_eaten
var destroy_self = false

func _process(delta):
	if destroy_self:
		print("edible is about to destroy self")
		queue_free()

func was_bitten():
	bites = bites - 1
	print("Bites went down by one")
	if bites <= 0:
		print("Just got eaten")
		emit_signal("on_eaten")
		destroy_self = true