extends Node2D

var max_value = 8
var min_value = 1

var max_measurement = 45
var min_miasurement = 20



func _process(delta):
	
	#if x is <20, we want y to be 0
	#if x is 21, we want y to be 1
	#if x is 45, we want y to be 8
	#if x is 46, we want y to be 15
	#if x is 75, we want y to be 30
	#if x is 76, we want y to be 30
	#if x is >=100, we want y to be 50
	
	
	
	
	pass
	
func get_fall_damage(height):
	if height < 20:
		return 0
	if height <=45:
		pass
	pass
	
func get_t(input_val, scale_min, scale_max):
	
	pass	
