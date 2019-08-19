extends Position2D

onready var cameragridsnapper = get_node("../cameragridsnapper")
onready var camerapivot = get_node("../pivot")
onready var cameraoffset = get_node("../pivot/cameraoffset")
onready var camera = get_node("../pivot/cameraoffset/Camera2D")

var isFree = true

var grid_size
var grid_quadrant

var player

var camhold = 0
var camstyle = TYPE.FREE

enum  TYPE {LOCKED,FREE}

func _ready():
	grid_size = get_viewport().get_visible_rect().size
	player = get_parent()
	switch_camera_style()
	
	grid_quadrant = get_camera_quadrant()
	cameragridsnapper.set_quadrant(grid_quadrant)
	
func _process(delta):
#	if Input.is_action_just_pressed("a"):
#		switch_camera_style()
	grid_quadrant = get_camera_quadrant()
	cameragridsnapper.set_quadrant(grid_quadrant)
#	print(camhold)
		
func get_camera_quadrant():
	var quadrant_x = int(player.position.x / grid_size.x)
	if player.position.x < 0:
		quadrant_x -= 1
	var quadrant_y = int(player.position.y / grid_size.y)
	if player.position.y < 0:
		quadrant_y -= 1

	return Vector2(quadrant_x, quadrant_y)

func switch_camera_style():
	if camstyle == TYPE.FREE:
		switch_to_locked()
	else:
		switch_to_free()
	
func switch_to_free():
	cameragridsnapper.remove_child(camera)
	cameraoffset.add_child(camera)
	camera.position = Vector2(0,0)
	camstyle = TYPE.FREE
		
func switch_to_locked():
	cameraoffset.remove_child(camera)
	cameragridsnapper.add_child(camera)
	camera.position = Vector2(grid_size.x / 2, grid_size.y / 2)
	camstyle = TYPE.LOCKED
	
func _on_Area2D_body_entered(body, obj):
	if body.get_name() == "player":
		print(obj.name)
#		print("Player entered cam area")
		camhold += 1
		
		var new_extents = obj.get_node("CollisionShape2D").shape.extents
		camerapivot.set_constraints(new_extents,obj.global_position)
	
		if camstyle == TYPE.LOCKED:
#			print("Moved from a locked area to a free area")
			
			switch_to_free()

func _on_Area2D_body_exited(body, obj):
	if body.get_name() == "player":
#		print("Player exited cam area")
		if camhold > 1:
#			print("Moved from one free movement area to another")
			pass
		else:
#			print("Moved from a free movement area to a locked area")
			if camstyle == TYPE.FREE:
				switch_to_locked()
			
		camhold -= 1
		
	
