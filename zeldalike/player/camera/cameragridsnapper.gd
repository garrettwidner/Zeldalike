extends Position2D

var grid_size = Vector2()
var grid_quadrant = Vector2()

onready var player = get_parent()

func _ready():
	grid_size = get_viewport().get_visible_rect().size
	set_as_toplevel(true)
	
func _physics_process(delta):
	grid_quadrant = get_camera_quadrant()
	position_camera()
	
func get_camera_quadrant():
	var quadrant_x = int(player.position.x / grid_size.x)
	if player.position.x < 0:
		quadrant_x -= 1
	var quadrant_y = int(player.position.y / grid_size.y)
	if player.position.y < 0:
		quadrant_y -= 1

	return Vector2(quadrant_x, quadrant_y)
	
func position_camera():
	position = grid_size * grid_quadrant
	
	
	
	
	

