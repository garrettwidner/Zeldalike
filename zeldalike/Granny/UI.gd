extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	become_visible()
	pass # Replace with function body.

func fade_out():
	$anim.play("fade")
	pass
	
func become_visible():
	$anim.play("visible")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
