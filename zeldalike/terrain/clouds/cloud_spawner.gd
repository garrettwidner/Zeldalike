extends Node2D

var cloud = preload("res://terrain/clouds/cloud.tscn")

export var spawn_frequency = 20
export var cloud_speed = 10

func _ready():
	spawn_new_cloud()
	$Timer.start(spawn_frequency)
	print("Cloud spawner's global position is: " + String(global_position))
	pass

func _process(delta):
	
	pass
	
func spawn_new_cloud():
	var c1 = cloud.instance()
	c1.speed = cloud_speed
	self.add_child(c1)
	c1.global_position = global_position
	print("Cloud should spawn")

func _on_Timer_timeout():
	spawn_new_cloud()
	$Timer.start(spawn_frequency)
	pass
