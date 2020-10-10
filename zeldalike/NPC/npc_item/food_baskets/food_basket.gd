extends Area2D

var total_receipt = 0
export var connected_character = ""
var experiences 

func _ready():
	experiences = helper.load_file_as_JSON("res://dialogue/data/experiences.json")

func receive(food):
#	print("Food '" + food.name + "' received")
#	print("Received food has " + String(food.health) + " health")
	total_receipt = total_receipt + food.health
#	print("Food basket has received " + String(total_receipt) + " food points in total")
	$anim.play("bounce")
	
	experiences[connected_character][food.name] = experiences[connected_character][food.name] + 1
	experiences[connected_character]["food_health_received"] = experiences[connected_character]["food_health_received"] + food.health
	
	print(connected_character + "'s " + food.name + " is now " + String(experiences[connected_character][food.name]))
	print(connected_character + "'s total food is now " + String(experiences[connected_character]["food_health_received"]))
	
	
	notify_connected_character(food.name, food.health)
	pass
	
func notify_connected_character(food_name, food_health):
	var found_character = get_node("../../actors/" + connected_character)
	if found_character != null:
		if found_character.has_method("received_food"):
			found_character.received_food(food_name, food_health)
	pass
	