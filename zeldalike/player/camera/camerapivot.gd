extends Position2D

onready var parent = get_parent()

var constraint_max = Vector2()
var constraint_min = Vector2()

onready var camera_holder = get_node("cameraholder")

var cam_extents

onready var movement_arm = get_node("cameraoffset")
onready var camera = get_node("cameraoffset/Camera2D")

var has_constraints = false

func _ready():
	update_pivot_angle()
	
	var cam_size = get_viewport().get_visible_rect().size
	cam_extents = Vector2(cam_size.x / 2, cam_size.y / 2)
	
func _physics_process(delta):
	update_pivot_angle()
	
	var newcamlocation = get_constrained_camera_location()
	if newcamlocation != null:
		camera_holder.global_position = newcamlocation
#	camera.position = movement_arm.position
#	if has_constraints:
#		camera.position = get_constrained_camera_location()
#	else:
#		camera.position = movement_arm.global_position
	
func set_constraints(extents, pos):
	has_constraints = true
	constraint_max = Vector2(pos.x + extents.x, pos.y - extents.y)
	constraint_min = Vector2(pos.x - extents.y, pos.y + extents.y)
	
func update_pivot_angle():
	var lookangle = parent.facedir.angle()
	rotation = lookangle

func get_constrained_camera_location():
	if !has_constraints:
		return
	
	var cam_max = Vector2(movement_arm.global_position.x + cam_extents.x, movement_arm.global_position.y - cam_extents.y)
	var cam_min = Vector2(movement_arm.global_position.x - cam_extents.y, movement_arm.global_position.y + cam_extents.y)

	var correction_y = 0
	var correction_x = 0

	if cam_max.x > constraint_max.x:
		correction_x = constraint_max.x - cam_extents.x
	elif cam_min.x < constraint_min.x:
		correction_x = constraint_min.x + cam_extents.x

	if cam_max.y < constraint_max.y:
		correction_y = constraint_max.y + cam_extents.y
	elif cam_min.y > constraint_min.y:
		correction_y = constraint_min.y - cam_extents.y
	
	
	
	var unconstrained_position = movement_arm.global_position
	
	if correction_x == 0:
		correction_x = unconstrained_position.x
	if correction_y == 0:
		correction_y = unconstrained_position.y
	
	return Vector2(correction_x,correction_y)
	
