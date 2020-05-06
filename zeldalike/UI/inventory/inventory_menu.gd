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
	
#	var scene = get_tree().get_current_scene()
#	cursor.set_owner(self)
#	cursor.set_owner(scene)


	add_child(cursor)
	cursor.rect_position = inventory_ui.rect_position + CURSOR_OFFSET
	cursor_grid_position = Vector2(0,0)
	
	place_cursor(Vector2(2,2))

#	cursor.rect_position = Vector2(30,30)
	print("Added cursor")
	
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
			current_UI_BOX = UI_BOX.HOTBAR2
			cursor.rect_position = hotbar_2.rect_position + CURSOR_OFFSET
			cursor_grid_position = Vector2(0,0)
			
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
		current_UI_BOX = UI_BOX.HOTBAR2
		cursor.rect_position = hotbar_2.rect_position + CURSOR_OFFSET
		cursor_grid_position = Vector2(0,0)
	
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
		current_UI_BOX = UI_BOX.INV
		cursor.rect_position = inventory_ui.rect_position + CURSOR_OFFSET
		cursor_grid_position = Vector2(0,0)
	elif direction == dir.UP:
		current_UI_BOX = UI_BOX.HOTBAR1
		cursor.rect_position = hotbar_1.rect_position + CURSOR_OFFSET
		cursor_grid_position = Vector2(0,0)
	pass
	
func place_cursor(menu_coordinates):
	match current_UI_BOX:
		UI_BOX.INV:
			if menu_coordinates.x > INV_SLOT_COUNT.x || menu_coordinates.x < 0 || menu_coordinates.y > INV_SLOT_COUNT.y || menu_coordinates.y < 0:
				print("Warning: Given menu coordinates are invalid for inventory box")
				return
			cursor.rect_position = inventory_ui.rect_position + CURSOR_OFFSET
			cursor.rect_position += menu_coordinates * SLOT_WIDTH
			cursor_grid_position = menu_coordinates
		UI_BOX.HOTBAR1:
			if menu_coordinates.x > HOTBAR_1_SLOT_COUNT.x || menu_coordinates.x < 0 || menu_coordinates.y > HOTBAR_1_SLOT_COUNT.y || menu_coordinates.y < 0:
				print("Warning: Given menu coordinates are invalid for hotbar 1")
				return
			cursor.rect_position = hotbar_1.rect_position + CURSOR_OFFSET
			cursor.rect_position += menu_coordinates * SLOT_WIDTH
			cursor_grid_position = menu_coordinates
		UI_BOX.HOTBAR2:
			if menu_coordinates.x > HOTBAR_2_SLOT_COUNT.x || menu_coordinates.x < 0 || menu_coordinates.y > HOTBAR_2_SLOT_COUNT.y || menu_coordinates.y < 0:
				print("Warning: Given menu coordinates are invalid for hotbar 2")
				return
			cursor.rect_position = hotbar_2.rect_position + CURSOR_OFFSET
			cursor.rect_position += menu_coordinates * SLOT_WIDTH
			cursor_grid_position = menu_coordinates
	
	pass
	
	
	
	
	

