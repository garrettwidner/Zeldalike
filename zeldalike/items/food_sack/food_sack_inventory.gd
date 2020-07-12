extends Node2D

var contents = []
var current_item = 0

func _ready():
	var sack_closed_item = {
		"name" : "closed_sack",
		"food" : null,
		"count" : 1,
		}
		
	contents.append(sack_closed_item.duplicate())
	pass

func get_current_item():
	return contents[current_item]
	print("Current item index is " + current_item)
	pass
	
func increment_current_item():
	current_item = current_item + 1
	if current_item >= contents.size():
		current_item = 0
	
func decrement_current_item():
	current_item = current_item - 1
	if current_item < 0:
		current_item = contents.size() - 1
		
func reset_current_item():
	current_item = 0

func count():
	return contents.count()

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
	print("Added food named " + new_food["name"])
	
func print_contents():
	var contents_string = "food sack contents: "
	for f in contents:
#		print(f["name"])
		contents_string = contents_string + f["name"] + ":" + String(f["count"]) + " - "
	print(contents_string)
	pass
	