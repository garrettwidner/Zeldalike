extends Node

onready var inventory = $food_inventory
onready var closed_sack_icon = preload("res://UI/inventory/food/food_sack_close-out.png")
onready var ui = get_node("UI")
onready var icon_holder = get_node("UI/ui_icon")
onready var count = get_node("UI/count")

var current_item
var is_active = false
var is_usable = false
var time_until_usable_at_start = .2
var is_in_front_of_givable = false

var index = 0

signal on_eat
signal on_closed

func _ready():
	inventory.connect("on_item_completely_removed", self, "switch_away_from_removed_item")
	close()
	
func _process(delta):
	if(is_active && is_usable):
		
		if Input.is_action_just_pressed("up"):
			increment_icon()
			pass
		elif Input.is_action_just_pressed("down"):
			decrement_icon()
			pass
		elif Input.is_action_just_pressed("item1") || Input.is_action_just_pressed("item2"):
			close()
		elif Input.is_action_just_pressed("action"):
			if current_item["name"] == "closed_sack":
				print("Closed food sack")
				close()
			else:
				use_current_item()
	pass

func open():
	ui.show()
	$Sprite.show()
	is_active = true
	inventory.reset_current_item()
	current_item = inventory.get_current_item()
	set_icon(current_item["name"])
	$Timer.start(time_until_usable_at_start)
	
func close():
	ui.hide()
	$Sprite.hide()
	is_active = false
	is_usable = false
	emit_signal("on_closed")
	pass
	
func increment_icon():
	inventory.increment_current_item()
	current_item = inventory.get_current_item()
	set_icon(current_item["name"])
#	print(current_item["name"])
	pass
	
func decrement_icon():
	inventory.decrement_current_item()
	current_item = inventory.get_current_item()
	set_icon(current_item["name"])
#	print(current_item["name"])
	pass
	
func use_current_item():
	if is_in_front_of_givable:
		print("Should write function to give to givable")
	else:
		eat_current_item()
	
	pass

func eat_current_item():
	var health = current_item["health"]
	var food_texture = icon_holder.texture
	var food_name = current_item["name"]
	print("Ate " + food_name + ", health regained was " + String(health))
	emit_signal("on_eat", health, food_texture)
	inventory.remove_single_current_item()
	set_icon(current_item["name"])

	return health

func add(food):
	inventory.add(food)
	
func print_contents():
	inventory.print_contents()
	
func set_icon(food_name):
	var new_icon = get_icon(food_name)
	if new_icon != null:
		icon_holder.texture = new_icon
		if food_name == "closed_sack":
			count.text = ""
		else:
			count.text = String(current_item["count"])
	else:
		print("WARNING: food sack display found no icon of name " + food_name)
	
	pass
	
func get_icon(food_name):
	if food_name == "closed_sack":
		return closed_sack_icon
	else:
		var path_string = "res://UI/inventory/food/" + food_name + ".png"
		return load(path_string)

func _on_Timer_timeout():
#	print("timer timed out, food sack should now be usable")
	is_usable = true
	
func switch_away_from_removed_item(new_current_item):
	current_item = new_current_item
	set_icon(current_item["name"])
	pass