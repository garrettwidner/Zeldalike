extends Node2D

var TYPE : String = "PLAYER"
const DAMAGE : int = 0
var maxamount : int = 2

func _ready():
	TYPE = "PLAYER"
	$anim.play("sound")



func _on_anim_animation_finished(anim_name):
	queue_free()
