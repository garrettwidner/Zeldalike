extends Node2D

var inventory = {}
var item_notification_panel
var item_notification_text

func add_item(type,item):
	if type == "collectible":
		pass
	if type == "usable":
		pass
	
func add_gold(amount):
	pass


func _ready():
	inventory = load_file_as_JSON("res://dialogue/story/inventory.json")
	
	item_notification_panel = get_node("../item_notification/Panel")
	item_notification_text = get_node("../item_notification/Panel/MarginContainer/Label")
	
	if(typeof(inventory) != TYPE_DICTIONARY):
		print("ERROR: inventory file has errors")
		
	if item_notification_panel.is_visible():
		item_notification_panel.hide()

func load_file_as_JSON(file_path):
	var file = File.new()
	assert file.file_exists(file_path)
	
	file.open(file_path, file.READ)
	var filejson = JSON.parse(file.get_as_text())
	if filejson.error == 0:
		return filejson.result
	else:
		return ""