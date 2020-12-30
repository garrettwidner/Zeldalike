extends "res://engine/entity.gd"


func _ready():
	speed = 12
	movedir = dir.DOWN
	pass
	
	
func _physics_process(delta):
	movement_loop()
	pass