extends Position2D

onready var parent = get_parent()

func _ready():
	update_pivot_angle()
	pass
	
func _physics_process(delta):
	update_pivot_angle()
	
func update_pivot_angle():
	var lookangle = parent.facedir.angle()
	rotation = lookangle