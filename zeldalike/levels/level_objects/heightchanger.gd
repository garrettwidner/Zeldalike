extends Area2D

var center_point
var upward_signifier_point
export var magnitude = 1

func _ready():
	center_point = global_position
	upward_signifier_point = $upward_signifier.global_position
	pass
	
func is_point_above(point):
	if point.distance_to(upward_signifier_point) < point.distance_to(center_point):
		return true
	return false
	
	pass