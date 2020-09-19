extends Area2D

var total_receipt = 0

func receive(food):
#	print("Food '" + food.name + "' received")
#	print("Received food has " + String(food.health) + " health")
	total_receipt = total_receipt + food.health
#	print("Food basket has received " + String(total_receipt) + " food points in total")
	$anim.play("bounce")
	pass