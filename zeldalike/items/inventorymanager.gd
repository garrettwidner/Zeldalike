extends Node2D

#Handles all item requests, storage/deletion, and interaction. 

var inventory = {}
var inventory_master = {}
var item_notification_panel
var item_notification_text

signal on_item_added

var inv_menu

func _ready():
	inventory = load_file_as_JSON("res://dialogue/data/inventory.json")
	inventory_master = load_file_as_JSON("res://dialogue/data/inventory_master.json")
	
	item_notification_panel = get_node("../item_notification/Panel")
	item_notification_text = get_node("../item_notification/Panel/MarginContainer/Label")
	
	if(typeof(inventory) != TYPE_DICTIONARY):
		print("ERROR: inventory file has errors")
		
	if item_notification_panel != null:
		if item_notification_panel.is_visible():
			item_notification_panel.hide()
			
	inv_menu = get_node("../inventory_menu")
	connect("on_item_added", inv_menu, "add_to_inventory")
	inv_menu.connect("menu_opened", self, "menu_opened")
	inv_menu.connect("menu_closed", self, "menu_closed")

func add_test_items():
	add_item("veil")
	pass
	
func _process(delta):
#	if Input.is_action_just_pressed("action"):
#		add_test_items()
	pass

func has(item):
	if inventory["items"].has(helper.string_strip(item)):
		return true
	return false
	
func get_item_dict():
	return inventory["items"]
	
func get_item_1():
	return inv_menu.get_item_1()

func get_item_2():
	return inv_menu.get_item_2()

func add_item(item, count = 1):
	item = helper.string_strip(item)
	if(!inventory_master["list"].has(item)):
		print("Warning: '" + item + "' not found in inventory master list")
		return
	
	var item_entry = inventory_master["list"][item]
	var type = item_entry["type"]
	print("Found '" + item + "' of type '" + type + "'")
	
	if type == "collectible":
		if has(item):
			inventory["items"][item]["count"] = inventory["items"][item] + count
		else:
			inventory["items"][item]["type"] = type
			inventory["items"][item]["count"] = count
			emit_signal("on_item_added", item)
			
			
	if type == "usable":
		if has(item):
			pass
		else:
			emit_signal("on_item_added", item)
			inventory["items"][item] = {}
			inventory["items"][item] = type
		
func menu_opened():
	print("Inventory manager noticed menu was OPENED")
	pass
	
func menu_closed():
	print("Inventory manager noticed menu was CLOSED")
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