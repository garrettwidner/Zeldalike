extends Node2D

var TYPE : String = "SPIRIT"
const DAMAGE : int = 1
var is_parry : bool = true
var can_delete = false

#how many of each item can be active in scene at once (ex 3 bombs)
var maxamount : int = 1



func _ready():
	$AnimationPlayer.play("flash_out")
	
	pass

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "flash_out":
#		print("Flash out finished")
		$AnimationPlayer.play("sustain")
		is_parry = false
		can_delete = true
	
