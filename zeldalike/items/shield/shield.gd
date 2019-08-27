extends Node2D

var TYPE : String = ""
var maxamount = 1

func _ready():
	TYPE = get_parent().TYPE
	$anim.play(str("hold", get_parent().spritedir))
	if get_parent().has_method("state_block"):
		get_parent().set_state_block()
		
func _process(delta):
	if get_parent().state != "block":
		queue_free()
	
	