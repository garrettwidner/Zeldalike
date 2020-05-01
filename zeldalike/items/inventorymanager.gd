extends Node2D

var inventory = {}
var item_notification_panel
var item_notification_text

func _ready():
	inventory = load_file_as_JSON("res://dialogue/data/inventory.json")
	
	item_notification_panel = get_node("../item_notification/Panel")
	item_notification_text = get_node("../item_notification/Panel/MarginContainer/Label")
	
	if(typeof(inventory) != TYPE_DICTIONARY):
		print("ERROR: inventory file has errors")
		
	if item_notification_panel != null:
		if item_notification_panel.is_visible():
			item_notification_panel.hide()
			
	

func add_test_items():
	add_item("veil", "collectible")
	pass

func has(item):
	if inventory["items"].has(item):
		return true
	return false
	
func get_item_dict():
	return inventory["items"]

func add_item(item, type, count = 1):
	print(item + " of type " + type + " added to inventory") 
	
	if type == "collectible":
		
		if has(item):
			
			inventory["items"][item]["count"] = inventory["items"][item] + count
		else:
			inventory["items"][item]["type"] = type
			inventory["items"][item]["count"] = count
			
	if type == "usable":
		if has(item):
			pass
		else:
			inventory["items"][item] = type
			

func load_file_as_JSON(file_path):
	var file = File.new()
	assert file.file_exists(file_path)
	
	file.open(file_path, file.READ)
	var filejson = JSON.parse(file.get_as_text())
	if filejson.error == 0:
		return filejson.result
	else:
		return ""