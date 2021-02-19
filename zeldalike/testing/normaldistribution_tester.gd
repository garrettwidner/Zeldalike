extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_pressed("test_1"):
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		print("Ranomd number generated: " + String(rng.randfn(0.0, 1.7)))