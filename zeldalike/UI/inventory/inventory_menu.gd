tool
extends Control

const ICON_PATH = "res://UI/inventory/"

const SLOT_WIDTH = 19
const CURSOR_OFFSET = Vector2(16,15)

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

onready var inventory_ui = get_node("inventory_hold")
const INV_START_POS = Vector2(0,9)
const INV_SLOT_COUNT = Vector2(6,3)


onready var hotbar_1 = get_node("hotbar_1")
const HOTBAR_1_START_POS = Vector2(1,5)
const HOTBAR_1_SLOT_COUNT = Vector2(3,1)

onready var hotbar_2 = get_node("hotbar_2")
const HOTBAR_2_START_POS = Vector2(2,8)
const HOTBAR_2_SLOT_COUNT = Vector2(3,1)


	
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
	
func create_cursor():
	cursor = cursor_resource.instance()

	add_child(cursor)
	cursor.rect_position = inventory_ui.rect_position + CURSOR_OFFSET
	cursor_grid_position = Vector2(0,0)
	place_cursor(Vector2(0,0))
	
func _process(delta):
	move_cursor()
	
	if Input.is_action_just_pressed("item1"):
		print("-- Cursor grid position: " + String(cursor_grid_position))
	if Input.is_action_just_pressed("item2"):
		place_cursor(Vector2(1,0))
	
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
		var rect_position
	
		match current_UI_BOX:
			UI_BOX.INV:
				rect_position = inventory_ui.rect_position
			UI_BOX.HOTBAR1:
				rect_position = hotbar_1.rect_position
			UI_BOX.HOTBAR2:
				rect_position = hotbar_2.rect_position
				
		cursor.rect_position = rect_position + CURSOR_OFFSET
		cursor.rect_position += menu_coordinates * SLOT_WIDTH
		cursor_grid_position = menu_coordinates
	
	pass
	
func is_grid_position_valid(grid_position, menu):
	var slot_count
	var menu_name
	match menu:
		UI_BOX.INV:
			slot_count = INV_SLOT_COUNT
			menu_name = "inventory"
		UI_BOX.HOTBAR1:
			slot_count = HOTBAR_1_SLOT_COUNT
			menu_name = "hotbar 1"
		UI_BOX.HOTBAR2:
			slot_count = HOTBAR_2_SLOT_COUNT
			menu_name = "hotbar 2"
			
	if grid_position.x < slot_count.x && grid_position.x >= 0:
		if grid_position.y < slot_count.y && grid_position.y >= 0:
#			print("Grid position " + String(grid_position) + " is valid on " + menu_name)
			return true
	
#	print("Grid position " + String(grid_position) + " is NOT valid on " + menu_name)
	return false
	
	

