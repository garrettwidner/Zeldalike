extends Control

#Determines only which item is given as item1 and item2 through the inventorymanager.
# responsible for handling display and cycling through items through all UI.
# includes keeping track of the 'order' of all items in the inventory and hotbars

#Note: For any remove_and_get functions, remember that removing an icon from the space only 
#removes it in memory; within the scene it still visually occupies the space and must 
#be queue_free()'d or moved

const ICON_PREFIX = "res://UI/inventory/"
const ICON_SUFFIX = "_icon.png"

const SLOT_WIDTH = 19
const CURSOR_OFFSET = Vector2(16,15)
const ICON_OFFSET = Vector2(-2,-3)
const HELD_ICON_OFFSET = Vector2(-3,-4)
const PLACEHOLDER_ALPHA = .5

enum UI_BOX {INV, HOTBAR1, HOTBAR2}
enum MENU {PLAY, PAUSE}
	
onready var CURSOR_ICON = load("res://UI/inventory/cursor.png")
onready var cursor_resource = load("res://UI/inventory/cursor.tscn") 
var cursor
var cursor_grid_position = Vector2(0,0)
var current_UI_BOX
var held_icon = null
var placeholder_icon = null
var placeholder_slot = null

#var current_slot_count
#var current_menu_name

onready var icon_resource = load("res://UI/inventory/icon.tscn")

onready var inventory_ui = get_node("pause_menu/inventory_hold")
const INV_START_POS = Vector2(0,9)
const INV_SLOT_COUNT = Vector2(6,3)
var inv_matrix = []

onready var hotbar_1_ui = get_node("pause_menu/hotbar_1")
const HOTBAR_1_START_POS = Vector2(1,5)
const HOTBAR_1_SLOT_COUNT = Vector2(3,1)
var hotbar_1 = []

onready var hotbar_2_ui = get_node("pause_menu/hotbar_2")
const HOTBAR_2_START_POS = Vector2(2,8)
const HOTBAR_2_SLOT_COUNT = Vector2(3,1)
var hotbar_2 = []

onready var selected_hotbar_1 = get_node("play_menu/selected_hotbar_icon_1")
var selected_hotbar_1_item = null

onready var selected_hotbar_2 = get_node("play_menu/selected_hotbar_icon_2")
var selected_hotbar_2_item = null

onready var pause_menu = get_node("pause_menu")
onready var play_menu = get_node("play_menu")

var is_open 

signal menu_opened
signal menu_closed

func add_to_inventory(item_name):
#	print("Need to add " + item + " to inventory menu")
	var created_icon = create_icon(item_name)
	var new_slot = find_icon_slot(item_name)
	
	if get_item_1() == null:
		pick_icon_from_inv(new_slot)
		pick_icon_from_hotbar(1,Vector2(0,0))
		populate_play_menu()
		pass
		
	elif get_item_2() == null:
		pick_icon_from_inv(new_slot)
		pick_icon_from_hotbar(2,Vector2(0,0))
		populate_play_menu()
		pass
	pass
	
func get_item_1():
	if selected_hotbar_1_item != null:
		return helper.string_strip(selected_hotbar_1_item.name)
	return null
	
func get_item_2():
	if selected_hotbar_2_item != null:
		return helper.string_strip(selected_hotbar_2_item.name)
	return null

func _ready():
	is_open = false
	pause_menu.hide()
	play_menu.show()
	


	current_UI_BOX = UI_BOX.INV
	create_cursor()
	create_inv_matrix()
	create_hotbar1()
	create_hotbar2()
	
#	create_icon("bow")
#	create_icon("veil")
#	create_icon("sword")
	
func create_cursor():
	cursor = cursor_resource.instance()

	pause_menu.add_child(cursor)
	cursor.rect_position = inventory_ui.rect_position + CURSOR_OFFSET
	cursor_grid_position = Vector2(0,0)
	place_cursor(Vector2(0,0))
	
func create_inv_matrix():
	for x in range(INV_SLOT_COUNT.x):
			inv_matrix.append([])
			for y in range(INV_SLOT_COUNT.y):
				inv_matrix[x].append(null)
				inv_matrix[x][y] = null
				
func create_hotbar1():
	for x in range(HOTBAR_1_SLOT_COUNT.x):
		hotbar_1.append(null)
		
func create_hotbar2():
	for x in range(HOTBAR_2_SLOT_COUNT.x):
		hotbar_2.append(null)
	
func create_icon(item_name):
	var icon_object
	var new_slot = get_first_open_inv_slot()
	if new_slot != null:
		var icon = load(ICON_PREFIX + item_name + ICON_SUFFIX)
		icon_object = icon_resource.instance()
		
		pause_menu.add_child(icon_object)
		icon_object.name = item_name
		icon_object.rect_position = inventory_ui.rect_position
		icon_object.get_node("TextureRect").texture = icon
		
#		print("New slot: " + String(new_slot))
		place_icon_in_inv(icon_object, new_slot)
		
	return icon_object
	
func create_icon_in_play_menu(item_name, hotbar_number):
	
	var clean_name = helper.string_strip(item_name)
	
	var icon = load(ICON_PREFIX + clean_name + ICON_SUFFIX)
	if icon == null:
		print("Did not find icon with name " + clean_name)
		return
	remove_icon_from_play_menu(hotbar_number)
	var icon_object = icon_resource.instance()
	play_menu.add_child(icon_object)
	icon_object.name = clean_name
	icon_object.get_node("TextureRect").texture = icon
	
	match hotbar_number:
		1:
			icon_object.rect_position = selected_hotbar_1.rect_position + ICON_OFFSET
			selected_hotbar_1_item = icon_object
		2:
			icon_object.rect_position = selected_hotbar_2.rect_position + ICON_OFFSET
			selected_hotbar_2_item = icon_object
			
	pass
	
func remove_icon_from_play_menu(hotbar_number):
	match hotbar_number:
		1:
			if selected_hotbar_1_item != null:
				selected_hotbar_1_item.queue_free()
				selected_hotbar_1_item = null
				pass
		2:
			if selected_hotbar_2_item != null:
				selected_hotbar_2_item.queue_free()
				selected_hotbar_2_item = null
				pass
	pass
	
func create_placeholder_icon(item_name, slot):
	var clean_name = helper.string_strip(item_name)
	var icon = load(ICON_PREFIX + clean_name + ICON_SUFFIX)
	var icon_object = icon_resource.instance()
	
#	print("Placeholder base name is " + item_name)
	
	pause_menu.add_child(icon_object)
	icon_object.name = clean_name
#	print("Placeholder " + icon_object.name + " created at slot " + String(slot))
	icon_object.rect_position = inventory_ui.rect_position
	icon_object.get_node("TextureRect").texture = icon 
	icon_object.modulate.a = PLACEHOLDER_ALPHA
	place_icon_in_inv(icon_object, slot)
	
	placeholder_icon = icon_object
	placeholder_slot = slot

func hide_menu():
	populate_play_menu()
	is_open = false
	pause_menu.hide()
	play_menu.show()
	clear_picked_icon()
	emit_signal("menu_closed")
	get_tree().paused = false
	
func populate_play_menu():
#	var hotbar_1_item = get_icon_at_grid_position(Vector2(0,0), UI_BOX.HOTBAR1)
#	var hotbar_2_item = get_icon_at_grid_position(Vector2(0,0), UI_BOX.HOTBAR2)
	var hotbar_1_item = hotbar_1[0]
	var hotbar_2_item = hotbar_2[0]
	
	
	if hotbar_1_item != null:
		create_icon_in_play_menu(hotbar_1_item.name, 1)
	else:
		remove_icon_from_play_menu(1)
	if hotbar_2_item != null:
		create_icon_in_play_menu(hotbar_2_item.name, 2)
	else:
		remove_icon_from_play_menu(2)
	pass
	
func show_menu():
	pause_menu.show()
	play_menu.hide()
	is_open = true
	emit_signal("menu_opened")
	get_tree().paused = true

#func _process(delta):
#	if Input.is_action_just_pressed("inventory"):
#		if !is_open:
#			show_menu()
#		else:
#			hide_menu()
#
#	if Input.is_action_pressed("itemchange"):
#			if Input.is_action_just_pressed("item1"):
##				print("Should increment hotbar 1")
#				increment_hotbar(1)
#				populate_play_menu()
#			elif Input.is_action_just_pressed("item2"):
##				print("Should increment hotbar 2")
#				increment_hotbar(2)
#				populate_play_menu()
#			pass
#
#	if is_open:
#		move_cursor()
#		move_held_icon()
#
#
#		if Input.is_action_just_pressed("action"):
#			pick_icon()
#			pass
#
#		pass

	
func find_icon_slot(icon_name):
	for y in range(INV_SLOT_COUNT.y):
		for x in range(INV_SLOT_COUNT.x):
			if inv_matrix[x][y] != null:
				if helper.string_strip(inv_matrix[x][y].name) == icon_name:
					return Vector2(x,y)
	return null
	
func increment_hotbar(hotbar_number):
	var ui_box
	var hotbar
	var slot_count
	var hotbar_item_count = get_hotbar_item_count(hotbar_number)
#	print("Incrementing hotbar " + String(hotbar_number))
	
	match hotbar_number:
		1:
			ui_box = UI_BOX.HOTBAR1
			hotbar = hotbar_1
			slot_count = HOTBAR_1_SLOT_COUNT
		2:
			ui_box = UI_BOX.HOTBAR2
			hotbar = hotbar_2
			slot_count = HOTBAR_2_SLOT_COUNT
			
	if hotbar_item_count == 0:
		return
	#if not there already, move first found item to hotbar's first place
	if get_icon_at_grid_position(Vector2(0,0), ui_box) == null:
		for x in range(slot_count.x):
			if hotbar[x] != null:
				var icon = remove_and_get_icon_at_hotbar_slot(Vector2(x,0),ui_box)
				place_icon_in_hotbar(icon, Vector2(0,0), hotbar_number)
				return
	#return if there's only one item which is already in the first place
	elif hotbar_item_count == 1:
		return
	#otherwise if there are only two items, switch them, keeping both in their respective slots.
	elif hotbar_item_count == 2:
		var item_1 = remove_and_get_icon_at_hotbar_slot(Vector2(0,0), ui_box)
		var item_2 = null
		for x in range(slot_count.x):
			if hotbar[x] != null:
				item_2 = remove_and_get_icon_at_hotbar_slot(Vector2(x,0), ui_box)
				place_icon_in_hotbar(item_2, Vector2(0,0), hotbar_number)
				place_icon_in_hotbar(item_1, Vector2(x,0), hotbar_number)
				return
	
	#increment the space of each item by one, moving item 1 to last place
	else:
		var first_item
		var previous_space
		var item_count = 0
		for x in range(slot_count.x):
			if x == 0:
				first_item = remove_and_get_icon_at_hotbar_slot(Vector2(0,0), ui_box)
				previous_space = Vector2(0,0) 
				item_count = item_count + 1
			else: 
				
				var found_icon = get_icon_at_grid_position(Vector2(x,0), ui_box)
				if found_icon != null:
					if item_count == hotbar_item_count - 1:
						var move_item = remove_and_get_icon_at_hotbar_slot(Vector2(x,0), ui_box)
						place_icon_in_hotbar(move_item, previous_space, hotbar_number)
						place_icon_in_hotbar(first_item, Vector2(x,0), hotbar_number)
					else: 
						var move_item = remove_and_get_icon_at_hotbar_slot(Vector2(x,0), ui_box)
						place_icon_in_hotbar(move_item, previous_space, hotbar_number)
						item_count = item_count + 1
						previous_space = Vector2(x,0)
					
	
	

	
func print_inventory_contents():
	print("Inv Menu Contents: ")
	for y in range(INV_SLOT_COUNT.y):
		for x in range(INV_SLOT_COUNT.x):
			if inv_matrix[x][y] == null:
				print("Item at position " + String(Vector2(x,y)) + " was _ _ _")
			else:
				print("Item at position " + String(Vector2(x,y)) + " was " + inv_matrix[x][y].name)
	print("Hotbar1 Contents: ")
	for x in range(HOTBAR_1_SLOT_COUNT.x):
		if hotbar_1[x] == null:
			print("Item at position " + String(x) + " was _ _ _")
		else:
			print("Item at position " + String(x) + " was " + hotbar_1[x].name)
			
	print("Hotbar2 Contents: ")
	for x in range(HOTBAR_2_SLOT_COUNT.x):
		if hotbar_2[x] == null:
			print("Item at position " + String(x) + " was _ _ _")
		else:
			print("Item at position " + String(x) + " was " + hotbar_2[x].name)
	
func pick_icon():
	if current_UI_BOX == UI_BOX.INV:
		pick_icon_from_inv()
	elif current_UI_BOX == UI_BOX.HOTBAR1:
		pick_icon_from_hotbar(1)
	elif current_UI_BOX == UI_BOX.HOTBAR2:
		pick_icon_from_hotbar(2)
		pass
		
func pick_icon_from_inv(chosen_slot = null):
	var selection_position 
	if chosen_slot == null:
		selection_position = cursor_grid_position
	else:
		selection_position = chosen_slot
	
	if held_icon == null:
		var icon_at_current_slot = get_icon_at_grid_position(selection_position, UI_BOX.INV)
		if icon_at_current_slot != null:
			var icon = remove_and_get_icon_at_inv_matrix_slot(selection_position, true)
			held_icon = icon
	else:
		remove_placeholder_icon()
		var icon_at_current_slot = get_icon_at_grid_position(selection_position, UI_BOX.INV)
#		print("Held icon: " + held_icon.name)
		if icon_at_current_slot != null:
#			print("Slot icon: " + icon_at_current_slot.name)
			if is_item_in_inv(held_icon.name):
				if same_icon_name(held_icon.name,icon_at_current_slot.name):
#					print("Duplicate item found in same slot")
					held_icon.queue_free()
					held_icon = null
				elif !same_icon_name(held_icon.name,icon_at_current_slot.name):
#					print("Different item found in same slot, duplicate found elsewhere")
					#switch held icon with icon in slot, remove extraneous version in inv_matrix
#					remove_placeholder_icon()
					
					remove_and_get_icon_in_inv(held_icon.name).queue_free()
					
					var icon = remove_and_get_icon_at_inv_matrix_slot(selection_position)
					var duplicate_icon = held_icon
					place_icon_in_inv(held_icon, selection_position)
					create_placeholder_icon(icon.name, get_first_open_inv_slot())
					held_icon = icon
			else:
				#switch held icon with icon in slot
#				print("Different item found in same slot, duplicate item not found in inventory")
				var icon = remove_and_get_icon_at_inv_matrix_slot(selection_position)
				place_icon_in_inv(held_icon, selection_position)
				create_placeholder_icon(icon.name, get_first_open_inv_slot())
				held_icon = icon
		else:
			var debug_string = ""
			if is_item_in_inv(held_icon.name):
				remove_and_get_icon_in_inv(held_icon.name).queue_free()
				debug_string = "Removed item present in inventory and "
			place_icon_in_inv(held_icon, selection_position)
#			print(debug_string + "Placed held item in empty spot")
			held_icon = null
		pass

func same_icon_name(name1, name2):
	if helper.string_strip(name1) == helper.string_strip(name2):
		return true
	return false

func remove_placeholder_icon():
	if placeholder_icon != null:
		remove_and_get_icon_at_inv_matrix_slot(placeholder_slot).queue_free()
		placeholder_icon = null
		placeholder_slot = null
		
func reinstate_placeholder_icon():
	if placeholder_icon != null:
		placeholder_icon.modulate.a = 1
		placeholder_icon = null
		placeholder_slot = null
		
		pass



func pick_icon_from_hotbar(hotbar_number, chosen_slot = null):
	var selection_position 
	if chosen_slot == null:
		selection_position = cursor_grid_position
	else:
		selection_position = chosen_slot
	
	var ui_box
	var hotbar
	
	match hotbar_number:
		1:
			ui_box = UI_BOX.HOTBAR1
			hotbar = hotbar_1
		2:
			ui_box = UI_BOX.HOTBAR2
			hotbar = hotbar_2
	
	if held_icon == null:
		var icon_at_current_slot = get_icon_at_grid_position(selection_position, ui_box)
		if icon_at_current_slot != null:
			var icon = remove_and_get_icon_at_hotbar_slot(selection_position,hotbar_number)
			held_icon = icon
		pass
	else:
		reinstate_placeholder_icon()
		var icon_at_current_slot = get_icon_at_grid_position(selection_position, ui_box)
		if icon_at_current_slot != null:
			if same_icon_name(icon_at_current_slot.name, held_icon.name):
				#icon is same as held icon
				held_icon.queue_free()
				held_icon = null
			else:
				#icons are different
				var placed_icon_name = held_icon.name
				var icon = remove_and_get_icon_at_hotbar_slot(selection_position,hotbar_number)
				place_icon_in_hotbar(held_icon, selection_position, hotbar_number)
				held_icon = icon
				remove_hotbar_duplicates(placed_icon_name, selection_position.x, hotbar_number)
		else:
			var placed_icon_name = held_icon.name
			place_icon_in_hotbar(held_icon, selection_position, hotbar_number)
			held_icon = null
			remove_hotbar_duplicates(placed_icon_name, selection_position.x, hotbar_number)
			pass
		pass
		
#	populate_play_menu()
	pass
	
func clear_picked_icon():
	if held_icon != null:
		held_icon.queue_free()
		held_icon = null
		reinstate_placeholder_icon()
	pass
	
func remove_hotbar_duplicates(item_name, slot_to_skip, hotbar_number):
	var hotbar
	var slot_count
	
	match hotbar_number:
		1:
			hotbar = hotbar_1
			slot_count = HOTBAR_1_SLOT_COUNT
		2:
			hotbar = hotbar_2
			slot_count = HOTBAR_2_SLOT_COUNT
			
	for x in range(slot_count.x):
		if x != slot_to_skip:
			if hotbar[x] != null:
				if helper.string_strip(item_name) == helper.string_strip(hotbar[x].name):
					var remove_icon = remove_and_get_icon_at_hotbar_slot(Vector2(x,0),hotbar_number)
					remove_icon.queue_free()
		pass
	
	pass

func is_item_in_inv(item_name):
	var true_name = helper.string_strip(item_name)
	var is_in_inv = false
	for x in range(INV_SLOT_COUNT.x):
		for y in range(INV_SLOT_COUNT.y):
			if inv_matrix[x][y] != null:
				if helper.string_strip(inv_matrix[x][y].name) == true_name:
					is_in_inv = true
	return is_in_inv
		
func remove_and_get_icon_at_inv_matrix_slot(slot, create_placeholder = false):
	var icon = get_icon_at_grid_position(slot, UI_BOX.INV)
	if icon != null:
		inv_matrix[slot.x][slot.y] = null
		if create_placeholder:
			create_placeholder_icon(helper.string_strip(icon.name), slot)
		return icon
		
func remove_and_get_icon_in_inv(item_name):
	var true_name = helper.string_strip(item_name)
	var icon
	for x in range(INV_SLOT_COUNT.x):
		for y in range(INV_SLOT_COUNT.y):
			if inv_matrix[x][y] != null:
				if helper.string_strip(inv_matrix[x][y].name) == true_name:
					icon = inv_matrix[x][y] 
					inv_matrix[x][y] = null
					return icon
	return null
	
func remove_and_get_icon_at_hotbar_slot(slot, hotbar_number):
	var ui_box
	var hotbar
	
	match hotbar_number:
		1:
			ui_box = UI_BOX.HOTBAR1
			hotbar = hotbar_1
		2:
			ui_box = UI_BOX.HOTBAR2
			hotbar = hotbar_2
	
	var icon = get_icon_at_grid_position(slot, ui_box)
	if icon != null:
		hotbar[slot.x] = null
		return icon
	
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
	
func move_held_icon():
	if held_icon != null:
		held_icon.rect_position = cursor.rect_position + HELD_ICON_OFFSET
	
func get_first_open_inv_slot():
	for y in range (INV_SLOT_COUNT.y):
		for x in range (INV_SLOT_COUNT.x):
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
	else:
		print("Given position was not valid, cursor not placed at menu coordinates")
	pass
	
func place_icon_in_inv(icon, menu_coordinates):
	if(is_grid_position_valid(menu_coordinates, UI_BOX.INV)):
		var rect_position = get_rect_position(UI_BOX.INV)
	
		icon.rect_position = rect_position + ICON_OFFSET
		icon.rect_position += menu_coordinates * SLOT_WIDTH
		inv_matrix[menu_coordinates.x][menu_coordinates.y] = icon
	else:
		print("Given position was not valid, item not placed in inv_matrix")
	pass

func place_icon_in_hotbar(icon, menu_coordinates, hotbar_number):
	var ui_box
	var hotbar
	
	match hotbar_number:
		1:
			ui_box = UI_BOX.HOTBAR1
			hotbar = hotbar_1
		2:
			ui_box = UI_BOX.HOTBAR2
			hotbar = hotbar_2
			
	if(is_grid_position_valid(menu_coordinates, ui_box)):
		var rect_position = get_rect_position(ui_box)
	
		icon.rect_position = rect_position + ICON_OFFSET
		icon.rect_position += menu_coordinates * SLOT_WIDTH
		hotbar[menu_coordinates.x] = icon
	pass

func get_rect_position(current_UI_BOX):
	match current_UI_BOX:
			UI_BOX.INV:
				return inventory_ui.rect_position
			UI_BOX.HOTBAR1:
				return hotbar_1_ui.rect_position
			UI_BOX.HOTBAR2:
				return hotbar_2_ui.rect_position
	
	print("Warning: Invalid UI_BOX given")
	return
	
func is_grid_position_valid(grid_position, menu):
	var slot_count = get_slot_count(menu)
	var menu_name = get_menu_string_name(menu)
	
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
		print("Error: Grid position is not valid")
		return
	match menu:
		UI_BOX.INV:
			return inv_matrix[grid_position.x][grid_position.y]
		UI_BOX.HOTBAR1:
			return hotbar_1[grid_position.x]
		UI_BOX.HOTBAR2:
			return hotbar_2[grid_position.x]
	print("Error: Invalid menu type")
	return " -error- " 
	
func get_hotbar_item_count(hotbar_number):
	var hotbar
	var slot_count
	var item_count = 0
	
	match hotbar_number:
		1:
			hotbar = hotbar_1
			slot_count = HOTBAR_1_SLOT_COUNT
		2:
			hotbar = hotbar_2
			slot_count = HOTBAR_2_SLOT_COUNT
	
	for x in range(slot_count.x):
		if(hotbar[x] != null):
			item_count = item_count + 1
	
	return item_count
	pass
	
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


