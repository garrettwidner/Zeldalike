extends Node2D

func action(inventory):
	# not sure yet how to really add items to inventory
	inventory.add("brick")
	queue_free()