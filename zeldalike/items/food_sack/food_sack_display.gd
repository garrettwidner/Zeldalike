extends Node

onready var inventory = $food_inventory
onready var closed_sack_icon = preload("res://UI/inventory/food/food_sack_closed.png")
onready var ui = get_node("UI")
onready var icon_holder = get_node("UI/ui_icon")

var current_item
var is_active = false
var is_usable = false
var time_until_usable_at_start = .2

var index = 0

signal on_closed

func _ready():
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
			if current_item["name"] == "closed_sack":
				close()
			else:
				print("Eating item: " + current_item["name"])
	pass

func open():
	ui.show()
	$Sprite.show()
	is_active = true
	inventory.reset_current_item()
	current_item = inventory.get_current_item()
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
	print(current_item["name"])
	pass
	
func decrement_icon():
	inventory.decrement_current_item()
	current_item = inventory.get_current_item()
	set_icon(current_item["name"])
	print(current_item["name"])
	pass

func add(food):
	inventory.add(food)
	
func print_contents():
	inventory.print_contents()
	
func set_icon(food_name):
	var new_icon = get_icon(food_name)
	if new_icon != null:
		icon_holder.texture = new_icon
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
