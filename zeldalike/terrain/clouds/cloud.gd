extends Area2D

export var speed = 8

var cloud1 = preload("res://terrain/clouds/cloud1.png")
var cloud2 = preload("res://terrain/clouds/cloud2.png")
var cloud3 = preload("res://terrain/clouds/cloud3.png")

func _ready():
	set_random_texture()
	
#	print("Cloud's starting position is: " + String(global_position))
	pass
	
func set_random_texture():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var rand_int = rng.randi_range(1,3)
	match rand_int:
		1:
			set_texture(cloud1)
			pass
		2:
			set_texture(cloud2)
			pass
		3: 
			set_texture(cloud2)
			pass
	pass
	
func _physics_process(delta):
#	move_and_slide(Vector2.RIGHT * delta * speed)
	global_position = Vector2(global_position.x + (delta * speed), global_position.y)
	pass

func set_texture(new_texture):
	$Sprite.texture = new_texture
	pass

func _on_cloud_area_entered(area):
#	print("Cloud entered area named " + area.name)
	
	if area.is_in_group("cloudstopper"):
		queue_free()
