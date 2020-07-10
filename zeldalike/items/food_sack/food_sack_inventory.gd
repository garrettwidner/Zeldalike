extends Node2D

var contents = []

func add(food):
	if contains(food.name):
		var found_food = get(food.name)
		found_food["count"] = found_food["count"] + 1
	else:
		add_new_type(food)
	
func contains(food_name):
	for f in contents:
		if f["name"] == food_name:
			return true
	return false
	
func get(food_name):
	for f in contents:
		if f["name"] == food_name:
			return f
	return null
	
func add_new_type(food):
	var new_food = { 
		"name" : food.name,
		"food" : food,
		"count" : 1
		}
	
	contents.append(new_food.duplicate())
	
func print_contents():
	for f in contents:
		print(f["name"])
	pass
	