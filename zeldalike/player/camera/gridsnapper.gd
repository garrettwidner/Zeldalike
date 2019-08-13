extends Position2D

var grid_size = Vector2()
var grid_quadrant = Vector2()

var grid_offset = Vector2()

onready var parent = get_parent()

func _ready():
	grid_size = get_viewport().get_visible_rect().size
	
	grid_offset.x += grid_size.x / 2
	grid_offset.y += grid_size.y / 2


	#top level nodes don't inherit their position from their parent
	set_as_toplevel(true)
	update_grid_position()
	
func _physics_process(delta):
	update_grid_position()
	pass

func update_grid_position():
	var xQuadrant = grid_size.x
	
	
	var x = round(parent.position.x / (grid_size.x))
#	print((grid_size.x - grid_offset.x))
	var y = round(parent.position.y / (grid_size.y))
	var new_grid_quadrant = Vector2(x, y)
	
	if grid_quadrant == new_grid_quadrant:
		return
	
	
#	print(String(grid_position))
	grid_quadrant = new_grid_quadrant
	position = (grid_quadrant * grid_size) - grid_offset
#	print(position)
	
	
	pass