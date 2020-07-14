extends Node2D

var contents = []
var current_item_index = 0

signal on_item_completely_removed

func _ready():
	var sack_closed_item = {
		"name" : "closed_sack",
		"food" : null,
		"count" : 1,
		"health" : 0
		}
		
	contents.append(sack_closed_item.duplicate())
	pass
	
func _process(delta):
#	if Input.is_action_just_pressed("speech"):
#		TEST_aspberry_food_check()
			
	pass
		
func remove_single_current_item():
	if contents[current_item_index]["count"] > 1:
		contents[current_item_index]["count"] = contents[current_item_index]["count"] - 1
	else:
		contents.remove(current_item_index)
		decrement_current_item()
		emit_signal("on_item_completely_removed", contents[current_item_index])
	pass
	
func TEST_aspberry_food_check():
	print("Trying aspberry food check")
	var index = get_food_index("aspberry")
	if index != null:
		print("Aspberry's index was found to be " + String(index))
	else:
		print("Aspberry index was found null")

func get_current_item():
	return contents[current_item_index]
	print("Current item index is " + current_item_index)
	pass
	
func increment_current_item():
	current_item_index = current_item_index + 1
	if current_item_index >= contents.size():
		current_item_index = 0	
	
func decrement_current_item():
	current_item_index = current_item_index - 1
	if current_item_index < 0:
		current_item_index = contents.size() - 1
		
func reset_current_item():
	current_item_index = 0

func count():
	return contents.count()

func add(food):
	var food_name = helper.string_strip(food.name)
	if contains(food_name):
		var found_food = get(food_name)
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
	
func get_food_index(food_name):
	for i in range(contents.size()):
		if contents[i]["name"] == food_name:
			return i
	return null
		
	
func add_new_type(food):
	var new_food = { 
		"name" : helper.string_strip(food.name),
		"food" : food,
		"count" : 1,
		"health" : food.health
		}
	
	contents.append(new_food.duplicate())
#	print("Added food named " + new_food["name"])
	
func print_contents():
	var contents_string = "food sack contents: "
	for f in contents:
#		print(f["name"])
		contents_string = contents_string + f["name"] + ":" + String(f["count"]) + " - "
	print(contents_string)
	pass
	