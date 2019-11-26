extends Node2D

var TYPE : String = ""
const DAMAGE : int = 1

#how many of each item can be active in scene at once (ex 3 bombs)
var maxamount : int = 2
var speed = 3

#LOOK---------------------------
#TODO: Destroy self if offscreen
#LOOK---------------------------


func _ready():
	TYPE = get_parent().TYPE
	$anim.play(str("swing", get_parent().spritedir))
	match get_parent().spritedir:
		dir.RIGHT:
			pass
		dir.LEFT: 
			rotation_degrees = 180
		dir.DOWN:
			rotation_degrees = 90
		dir.UP:
			rotation_degrees = 270

	
