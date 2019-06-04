extends Node2D

var TYPE : String = ""
const DAMAGE : int = 0

#how many of each item can be active in scene at once (ex 3 bombs)
var maxamount : int = 1

func _ready():
	TYPE = get_parent().TYPE
	$anim.connect("animation_finished",self,"destroy")
	$anim.play(str("swing", get_parent().spritedir))
	
func destroy(animation):
	queue_free()
	