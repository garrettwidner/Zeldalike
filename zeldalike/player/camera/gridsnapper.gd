extends Position2D

var grid_size = Vector2()
var grid_position = Vector2()

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
	var x = round(parent.position.x / (grid_size.x - grid_offset.x))
#	print((grid_size.x - grid_offset.x))
	var y = round(parent.position.y / (grid_size.y - grid_offset.y))
	var new_grid_position = Vector2(x, y)
#	new_grid_position.x += grid_offset.x
#	new_grid_position.y += grid_offset.y
	
	if grid_position == new_grid_position:
		return
	
	
#	print(String(grid_position))
	grid_position = new_grid_position
	position = (grid_position * grid_size) - grid_offset
	print(position)
	
	
	pass