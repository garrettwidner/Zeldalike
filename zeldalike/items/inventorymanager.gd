extends Node2D

var inventory = {}
var item_notification_panel
var item_notification_text

func _ready():
	inventory = load_file_as_JSON("res://dialogue/data/inventory.json")
	
	item_notification_panel = get_node("../canvas/item_notification/Panel")
	item_notification_text = get_node("../canvas/item_notification/Panel/MarginContainer/Label")
	
	if(typeof(inventory) != TYPE_DICTIONARY):
		print("ERROR: inventory file has errors")
		
	if item_notification_panel != null:
		if item_notification_panel.is_visible():
			item_notification_panel.hide()

func has(item):
	if inventory["items"].has(item):
		return true
	return false
	
func get_item_dict():
	return inventory["items"]

func add_item(item, type):
	print(item + " of type " + type + " added to inventory") 
	
	inventory["items"][item] = type
	
	
	#TODO: Differentiate by type
	if type == "collectible":
		pass
	if type == "usable":
		pass
	
func add_gold(amount):
	print("gold added in amount: " + String(amount))
	pass

func load_file_as_JSON(file_path):
	var file = File.new()
	assert file.file_exists(file_path)
	
	file.open(file_path, file.READ)
	var filejson = JSON.parse(file.get_as_text())
	if filejson.error == 0:
		return filejson.result
	else:
		return ""