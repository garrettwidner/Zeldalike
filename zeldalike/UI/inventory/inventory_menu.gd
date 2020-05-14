extends Control

#Determines only which item is given as item1 and item2 through the inventorymanager.
# responsible for handling display and cycling through items through all UI.
# includes keeping track of the 'order' of all items in the inventory and hotbars

const ICON_PATH = "res://UI/inventory/"

const SLOT_WIDTH = 19
const CURSOR_OFFSET = Vector2(16,15)
const ICON_OFFSET = Vector2(1,2)

enum UI_BOX {INV, HOTBAR1, HOTBAR2}

const ITEMS = {
	"sword": {
		"icon": ICON_PATH + "sword_icon.png",
		"equippable": true  
		},
	"bow": {
		"icon": ICON_PATH + "bow_icon.png",
		"equippable": true
		},
	"cover": {
		"icon": ICON_PATH + "cover_icon.png",
		"equippable": true
		},
	"error": {
		"icon": ICON_PATH + "error_icon.png",
		"equippable": true
		}
	}
	
onready var CURSOR_ICON = load("res://UI/inventory/cursor.png")
onready var cursor_resource = load("res://UI/inventory/cursor.tscn") 
var cursor
var cursor_grid_position = Vector2(0,0)
var current_UI_BOX
#var current_slot_count
#var current_menu_name

onready var icon_resource = load("res://UI/inventory/icon.tscn")

onready var inventory_ui = get_node("inventory_hold")
const INV_START_POS = Vector2(0,9)
const INV_SLOT_COUNT = Vector2(6,3)
var inv_matrix = []
const inv_matrix_width = 6
const inv_matrix_height = 3

onready var hotbar_1 = get_node("hotbar_1")
const HOTBAR_1_START_POS = Vector2(1,5)
const HOTBAR_1_SLOT_COUNT = Vector2(3,1)

onready var hotbar_2 = get_node("hotbar_2")
const HOTBAR_2_START_POS = Vector2(2,8)
const HOTBAR_2_SLOT_COUNT = Vector2(3,1)

func add_to_inventory(item):
	print("Need to add " + item + " to inventory menu")
	var open_slot = get_first_open_inv_slot()
	var icon_object = create_icon(item)
	pass
	
func get_item(item_name):
	if item_name in ITEMS:
		return ITEMS[item_name]
	else:
		return ITEMS["error"]


func _ready():
#	inventory_ui.hide()
#	hotbar_1.hide()
#	hotbar_2.hide()

	current_UI_BOX = UI_BOX.INV
	create_cursor()
	create_inv_matrix()

	
func create_cursor():
	cursor = cursor_resource.instance()

	add_child(cursor)
	cursor.rect_position = inventory_ui.rect_position + CURSOR_OFFSET
	cursor_grid_position = Vector2(0,0)
	place_cursor(Vector2(0,0))
	
func create_inv_matrix():
	for x in range(inv_matrix_width):
			inv_matrix.append([])
			inv_matrix[x] = []
			for y in range(inv_matrix_height):
				inv_matrix[x].append([])
				inv_matrix[x][y] = null
	
func create_icon(item_name):
	var icon_object
	if ITEMS.has(item_name):
		var icon = load(ITEMS[item_name]["icon"])
		icon_object = icon_resource.instance()
		
		add_child(icon_object)
		icon_object.name = item_name
		icon_object.rect_position = inventory_ui.rect_position
		icon_object.get_node("TextureRect").texture = icon
		#------------------------------------------------> TODO: Add icon to inventory <---
		var new_slot = get_first_open_inv_slot()
		if new_slot != null:
			print("New slot: " + String(new_slot))
			place_icon_in_inventory(icon_object, new_slot)
		
	return icon_object
	
func _process(delta):
	move_cursor()
	
	if Input.is_action_just_pressed("item1"):
		print("-- Cursor grid position: " + String(cursor_grid_position))
	if Input.is_action_just_pressed("item2"):
#		place_cursor(Vector2(1,0))
		create_icon("bow")
		print("Trying to create bow icon")
#		get_icon_at_grid_position(Vector2(0,0), UI_BOX.INV)
	
	pass
	
func move_cursor():
	var direction = dir.direction_just_pressed_from_input()
	if direction.y != 0 && direction.x != 0:
		direction.y = 0
	
	if direction != Vector2(0,0):
		match current_UI_BOX:
			UI_BOX.INV:
				inv_box_movement_logic(direction)
			UI_BOX.HOTBAR1:
				hotbar_1_movement_logic(direction)
			UI_BOX.HOTBAR2:
				hotbar_2_movement_logic(direction)
				pass
		pass
	
	pass
	
func get_first_open_inv_slot():
	#TODO: Make it so that the full inventory fills, not just one away from the edge
	
	for y in range (inv_matrix_height):
		for x in range (inv_matrix_width):
			if inv_matrix[x][y] == null:
				return Vector2(x,y)
	
func inv_box_movement_logic(direction):
	if direction == dir.RIGHT:
		if cursor_grid_position.x < INV_SLOT_COUNT.x - 1:
			cursor.rect_position.x += SLOT_WIDTH
			cursor_grid_position.x = cursor_grid_position.x + 1
	elif direction == dir.LEFT:
		if cursor_grid_position.x > 0:
			cursor.rect_position.x -= SLOT_WIDTH
			cursor_grid_position.x = cursor_grid_position.x - 1
	elif direction == dir.DOWN:
		if cursor_grid_position.y < INV_SLOT_COUNT.y - 1:
			cursor.rect_position.y += SLOT_WIDTH
			cursor_grid_position.y = cursor_grid_position.y + 1
	elif direction == dir.UP:
		if cursor_grid_position.y > 0:
			cursor.rect_position.y -= SLOT_WIDTH
			cursor_grid_position.y = cursor_grid_position.y - 1
		else:
			var new_grid_position = Vector2(cursor_grid_position.x, 0)
			if is_grid_position_valid(new_grid_position, UI_BOX.HOTBAR2):
				current_UI_BOX = UI_BOX.HOTBAR2
				cursor_grid_position = new_grid_position
				place_cursor(cursor_grid_position)
			
func hotbar_1_movement_logic(direction):
	if direction == dir.RIGHT:
		if cursor_grid_position.x < HOTBAR_1_SLOT_COUNT.x - 1:
			cursor.rect_position.x += SLOT_WIDTH
			cursor_grid_position.x += 1
	elif direction == dir.LEFT:
		if cursor_grid_position.x > 0:
			cursor.rect_position.x -= SLOT_WIDTH
			cursor_grid_position.x -= 1
	elif direction == dir.DOWN:
		var new_grid_position = Vector2(cursor_grid_position.x, 0)
		if is_grid_position_valid(new_grid_position, UI_BOX.HOTBAR2):
			current_UI_BOX = UI_BOX.HOTBAR2
			cursor_grid_position = new_grid_position
			place_cursor(cursor_grid_position)
	
func hotbar_2_movement_logic(direction):
	if direction == dir.RIGHT:
		if cursor_grid_position.x < HOTBAR_2_SLOT_COUNT.x - 1:
			cursor.rect_position.x += SLOT_WIDTH
			cursor_grid_position.x += 1
	elif direction == dir.LEFT:
		if cursor_grid_position.x > 0:
			cursor.rect_position.x -= SLOT_WIDTH
			cursor_grid_position.x -= 1
	elif direction == dir.DOWN:
		var new_grid_position = Vector2(cursor_grid_position.x, 0)
		if is_grid_position_valid(new_grid_position, UI_BOX.INV):
			current_UI_BOX = UI_BOX.INV
			cursor_grid_position = new_grid_position
			place_cursor(cursor_grid_position)
	elif direction == dir.UP:
		var new_grid_position = Vector2(cursor_grid_position.x, 0)
		if is_grid_position_valid(new_grid_position, UI_BOX.HOTBAR1):
			current_UI_BOX = UI_BOX.HOTBAR1
			cursor_grid_position = new_grid_position
			place_cursor(cursor_grid_position)
	pass
	
func place_cursor(menu_coordinates):
	
	if(is_grid_position_valid(menu_coordinates, current_UI_BOX)):
		var rect_position = get_rect_position(current_UI_BOX)
	
		cursor.rect_position = rect_position + CURSOR_OFFSET
		cursor.rect_position += menu_coordinates * SLOT_WIDTH
		cursor_grid_position = menu_coordinates
	
	pass
	
func place_icon_in_inventory(icon, menu_coordinates):
	if(is_grid_position_valid(menu_coordinates, current_UI_BOX)):
		var rect_position = get_rect_position(current_UI_BOX)
	
		icon.rect_position = rect_position + ICON_OFFSET
		icon.rect_position += menu_coordinates * SLOT_WIDTH
		inv_matrix[menu_coordinates.x][menu_coordinates.y] = icon
	pass

	

func get_rect_position(current_UI_BOX):
	match current_UI_BOX:
			UI_BOX.INV:
				return inventory_ui.rect_position
			UI_BOX.HOTBAR1:
				return hotbar_1.rect_position
			UI_BOX.HOTBAR2:
				return hotbar_2.rect_position
	
	print("Warning: Invalid UI_BOX given")
	return
	
func is_grid_position_valid(grid_position, menu):
	var slot_count = get_slot_count(menu)
	var menu_name = get_menu_string_name(menu)
	
	#--------------- In error, grid position not showing up when creating many icons
#
#	print("Grid position: " + String(grid_position))
#	print("Slot count: " + String(slot_count))
			
	if grid_position.x < slot_count.x && grid_position.x >= 0:
		if grid_position.y < slot_count.y && grid_position.y >= 0:
#			print("Grid position " + String(grid_position) + " is valid on " + menu_name)
			return true
	
#	print("Grid position " + String(grid_position) + " is NOT valid on " + menu_name)
	return false
	
#Returns the item at the grid position. Returns null if no item present.
func get_icon_at_grid_position(grid_position, menu):
	if !is_grid_position_valid(grid_position, menu):
		return
	match menu:
		UI_BOX.INV:
			var found_icon = inv_matrix[grid_position.x][grid_position.y]
			if found_icon == null:
				return
			else:
				return found_icon
		UI_BOX.HOTBAR1:
			pass
		UI_BOX.HOTBAR2:
			pass
	print("Error: Invalid menu type")
	return " -error- " 
	
	
	
func get_menu_string_name(menu):
	match menu:
		UI_BOX.INV:
			return "inventory"
		UI_BOX.HOTBAR1:
			return "hotbar 1"
		UI_BOX.HOTBAR2:
			return "hotbar 2"
	print("Error: Invalid menu type")
	return " -error- "
	
func get_slot_count(menu):
	match menu:
		UI_BOX.INV:
			return INV_SLOT_COUNT
		UI_BOX.HOTBAR1:
			return HOTBAR_1_SLOT_COUNT
		UI_BOX.HOTBAR2:
			return HOTBAR_2_SLOT_COUNT
	print("Error: Invalid menu type")
	return Vector2(0,0)


