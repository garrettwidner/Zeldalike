extends Node2D

var TYPE : String = "Sprinkle"

func _ready():
	$anim.connect("animation_finished",self,"destroy")
	$anim.play("fall")
	
func destroy(animation):
	queue_free()
	