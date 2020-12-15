extends Position2D

onready var cameragridsnapper = get_node("../cameragridsnapper")
onready var camerapivot = get_node("../pivot")
onready var camera = get_node("../pivot/cameraholder/Camera2D")
onready var cameraholder = get_node("../pivot/cameraholder")

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
	switch_to_free()
	
	grid_quadrant = get_camera_quadrant()
	cameragridsnapper.set_quadrant(grid_quadrant)
	
func _process(delta):
	grid_quadrant = get_camera_quadrant()
	cameragridsnapper.set_quadrant(grid_quadrant)
		
func get_camera_quadrant():
	var quadrant_x = int(player.position.x / grid_size.x)
	if player.position.x < 0:
		quadrant_x -= 1
	var quadrant_y = int(player.position.y / grid_size.y)
	if player.position.y < 0:
		quadrant_y -= 1

	return Vector2(quadrant_x, quadrant_y)

func set_position_manual(starts_free, new_position, new_camarea):
	
	if new_camarea != null:
		print("Cameracontroller received new camarea, called " + new_camarea.name)
	else:
		print("Cameracontroller did not receive a new connecting camarea")
	
	switch_to_locked()
	
	var new_extents = new_camarea.get_node("CollisionShape2D").shape.extents
	#Note: if you find yourself here, the entrance sceneblock needs to be placed within the camarea in the scene at game start
	camerapivot.set_constraints(new_extents,new_camarea.global_position)
	
	if starts_free:
		switch_to_free()
		
	
	
	pass

func switch_to_free():
	cameragridsnapper.remove_child(camera)
	cameraholder.add_child(camera)
	camera.position = Vector2(0,0)
	camstyle = TYPE.FREE
		
func switch_to_locked():
	cameraholder.remove_child(camera)
	cameragridsnapper.add_child(camera)
	camera.position = Vector2(grid_size.x / 2, grid_size.y / 2)
	camstyle = TYPE.LOCKED
	
func _on_Area2D_body_entered(body, obj):
	if body.get_name() == "player":
#		print("Player entered camarea: " + obj.name)
		camhold += 1
		
		var new_extents = obj.get_node("CollisionShape2D").shape.extents
		camerapivot.set_constraints(new_extents,obj.global_position)
	
		if camstyle == TYPE.LOCKED:
			switch_to_free()

func _on_Area2D_body_exited(body, obj):
	if body.get_name() == "player":
		if camhold > 1:
			pass
		if body.state == "ledge" || body.state == "fall" || body.state == "pullup":
			pass
		else:
			if camstyle == TYPE.FREE:
				switch_to_locked()
		camhold -= 1
		
	
