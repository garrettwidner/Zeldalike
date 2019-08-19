extends Position2D

onready var parent = get_parent()

var constraint_max = Vector2()
var constraint_min = Vector2()

var cam_extents
var movement_arm

var has_constraints = false

func _ready():
	update_pivot_angle()
	movement_arm = get_node("cameraoffset")
	
	
	var cam_size = get_viewport().get_visible_rect().size
	cam_extents = Vector2(cam_size.x / 2, cam_size.y / 2)
	
func _physics_process(delta):
	update_pivot_angle()
	constrain()
	
func set_constraints(extents, pos):
	has_constraints = true
	constraint_max = Vector2(pos.x + extents.x, pos.y - extents.y)
	constraint_min = Vector2(pos.x - extents.y, pos.y + extents.y)
	
func update_pivot_angle():
	var lookangle = parent.facedir.angle()
	rotation = lookangle
	
func constrain():
	if !has_constraints:
		return
	
	var cam_max = Vector2(movement_arm.global_position.x + cam_extents.x, movement_arm.global_position.y - cam_extents.y)
	var cam_min = Vector2(movement_arm.global_position.x - cam_extents.y, movement_arm.global_position.y + cam_extents.y)

	var correction_y
	var correction_x
#	print("LLLLL")
	
	if cam_max.x > constraint_max.x:
		correction_x = constraint_max.x
	elif cam_min.x < constraint_min.x:
		correction_x = constraint_min.x
		
	if cam_max.y < constraint_max.y:
		correction_y = constraint_max.y
	elif cam_min.y > constraint_min.y:
		correction_y = constraint_min.y
	
	print(constraint_max)
	print(constraint_min)
	if correction_x != null:
		print("Correction X: " + String(correction_x))
	if correction_y != null:
		print("Correction Y: " + String(correction_y))
	
	print("--------")

	pass