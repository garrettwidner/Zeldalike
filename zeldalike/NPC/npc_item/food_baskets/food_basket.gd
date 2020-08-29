extends Area2D

func receive(food):
	print("Food '" + food.name + "' received")
	print("Received food has " + String(food.health) + " health")
	pass