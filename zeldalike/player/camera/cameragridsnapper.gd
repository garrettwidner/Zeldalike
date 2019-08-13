extends Position2D


var cam_start_position = Vector2()

var grid_size = Vector2()
var grid_offset = Vector2()

var grid_quadrant = Vector2()


func _ready():
	grid_size = get_viewport().get_visible_rect().size
	
	grid_offset.x += grid_size.x / 2
	grid_offset.y += grid_size.y / 2
	
	cam_start_position = Vector2(0,0)
	cam_start_position.x += grid_offset.x
	cam_start_position.y += grid_offset.y
	
	position = cam_start_position
	set_as_toplevel(true)
	
	
func _physics_process(delta):
	position = cam_start_position
	print(position)

