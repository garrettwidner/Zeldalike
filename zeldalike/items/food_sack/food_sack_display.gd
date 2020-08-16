extends Node

onready var inventory = $food_inventory
onready var closed_sack_icon = preload("res://items/pickups/food/food_sack_close-out.png")
onready var ui = get_node("UI")
onready var icon_holder = get_node("UI/ui_icon")
onready var count = get_node("UI/count")

var current_item
var is_active = false
var is_usable = false
var time_until_usable_at_start = .2
var is_in_front_of_givable = false

var can_eat_again = true

var index = 0

signal on_eat
signal on_closed

var bag_sprite

func _ready():
	inventory.connect("on_item_completely_removed", self, "switch_away_from_removed_item")
	close()
	bag_sprite = get_node("Sprite")
	
func _process(delta):
	if(is_active && is_usable):
		
		if Input.is_action_just_pressed("up") || Input.is_action_just_pressed("right"):
			increment_icon()
			pass
		elif Input.is_action_just_pressed("down") || Input.is_action_just_pressed("left"):
			decrement_icon()
			pass
		elif Input.is_action_just_pressed("sack"):
			if(can_eat_again):
				close()
		elif Input.is_action_just_pressed("action"):
			if current_item["name"] == "closed_sack":
#				print("Closed food sack")
				if(can_eat_again):
					close()
			else:
				use_current_item()
	pass

func open(direction = dir.DOWN):
	
	remove_child(bag_sprite)
	
	match(direction):
		dir.DOWN:
			get_node("sprite_location/down").add_child(bag_sprite)
		dir.LEFT:
			get_node("sprite_location/left").add_child(bag_sprite)
		dir.UP:
			get_node("sprite_location/up").add_child(bag_sprite)
		dir.RIGHT:
			get_node("sprite_location/right").add_child(bag_sprite)
			
	bag_sprite.position = Vector2.ZERO

	ui.show()
	bag_sprite.show()
	is_active = true
	inventory.reset_current_item()
	current_item = inventory.get_current_item()
	set_icon(current_item["name"])
	$Timer.start(time_until_usable_at_start)
	
func close():
	ui.hide()
	if bag_sprite == null:
		$Sprite.hide()
	else:
		bag_sprite.hide()
	is_active = false
	is_usable = false
	emit_signal("on_closed")
	can_eat_again = true
	pass
	
func increment_icon():
	inventory.increment_current_item()
	current_item = inventory.get_current_item()
	set_icon(current_item["name"])
	get_node("UI/right_reticule/anim").play("select")
#	print(current_item["name"])
	pass
	
func decrement_icon():
	inventory.decrement_current_item()
	current_item = inventory.get_current_item()
	set_icon(current_item["name"])
	get_node("UI/left_reticule/anim").play("select")
#	print(current_item["name"])
	pass
	
func use_current_item():
	if is_in_front_of_givable:
		print("Should write function to give to givable")
	else:
		eat_current_item()
	
	pass

func eat_current_item():
	if can_eat_again:
		can_eat_again = false
		var health = current_item["health"]
		var food_texture = icon_holder.texture
		var food_name = current_item["name"]
		var food_bitten_texture = get_icon_bitten(food_name)
		
	#	print("Ate " + food_name + ", health regained was " + String(health))
		emit_signal("on_eat", health, food_texture, food_bitten_texture)
		inventory.remove_single_current_item()
		set_icon(current_item["name"])
		$UI/anim.play("icon_eat")
	
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
		var path_string = "res://items/pickups/food/" + food_name + "/" + food_name + ".png"
		return load(path_string)
		
func get_icon_bitten(food_name):
	if food_name == "closed_sack":
		return closed_sack_icon
	else:
		var path_string = "res://items/pickups/food/" + food_name + "/" + food_name + "_1bite.png"
		return load(path_string)

func _on_Timer_timeout():
#	print("timer timed out, food sack should now be usable")
	is_usable = true
	
func switch_away_from_removed_item(new_current_item):
	current_item = new_current_item
	set_icon(current_item["name"])
	pass

func eat_animation_finished():
	can_eat_again = true
	pass