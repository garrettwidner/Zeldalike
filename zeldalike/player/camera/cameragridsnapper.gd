extends Position2D

var grid_size = Vector2()
var grid_quadrant = Vector2()

onready var player = get_parent()

func _ready():
	grid_size = get_viewport().get_visible_rect().size
	set_as_toplevel(true)
	
func _physics_process(delta):
	position_camera()
	
func set_quadrant(quadrant):
	grid_quadrant = quadrant
	
func position_camera():
	position = grid_size * grid_quadrant
	
	
	
	
	

