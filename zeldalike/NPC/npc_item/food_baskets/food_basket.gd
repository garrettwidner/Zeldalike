extends Area2D

var total_receipt = 0
export var connected_character = ""

func receive(food):
#	print("Food '" + food.name + "' received")
#	print("Received food has " + String(food.health) + " health")
	total_receipt = total_receipt + food.health
#	print("Food basket has received " + String(total_receipt) + " food points in total")
	$anim.play("bounce")
	
	var current_food_count = gamedata.get_experience(connected_character, food.name)
	gamedata.set_experience(connected_character, food.name, current_food_count + 1)
	var current_health_received = gamedata.get_experience(connected_character, "food_health_received")
	gamedata.set_experience(connected_character, "food_health_received", current_health_received + food.health)
	
#	print(connected_character + "'s " + food.name + " is now " + String(gamedata.get_experience(connected_character, food.name)))
#	print(connected_character + "'s total food is now " + String(gamedata.get_experience(connected_character, "food_health_received")))
	
	
	notify_connected_character(food.name, food.health)
	pass
	
func notify_connected_character(food_name, food_health):
	var found_character = get_node("../../actors/" + connected_character)
	if found_character != null:
		if found_character.has_method("received_food"):
			found_character.received_food(food_name, food_health)
	pass
	