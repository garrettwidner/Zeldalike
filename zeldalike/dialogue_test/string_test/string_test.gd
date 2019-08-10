extends Node2D

var stringo = "hello popey mole"


func ready():
	pass
	
func _process(delta):
	if Input.is_action_just_pressed("a"):
		var helloIndex = stringo.find("hello")
		print(helloIndex)
		pass
	pass