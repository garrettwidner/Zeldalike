extends Position2D

onready var cameragridsnapper = get_node("../cameragridsnapper")
onready var cameraoffset = get_node("../pivot/cameraoffset")
onready var camera = get_node("../pivot/cameraoffset/Camera2D")

var isFree = true

var camerasize

func _ready():
	camerasize = get_viewport().get_visible_rect().size
	pass
	
func _process(delta):
	if Input.is_action_just_pressed("a"):
		switch_camera_style()
		
func switch_camera_style():
	if isFree:
		cameraoffset.remove_child(camera)
		cameragridsnapper.add_child(camera)
		camera.position = Vector2(camerasize.x / 2, camerasize.y / 2)
		isFree = false
	else:
		cameragridsnapper.remove_child(camera)
		cameraoffset.add_child(camera)
		camera.position = Vector2(0,0)
		isFree = true
	pass