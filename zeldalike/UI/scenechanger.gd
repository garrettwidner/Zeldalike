extends Control

#should trigger majority of scene change logic and setups
signal scene_just_changed()
#should only 'start' the scene, if necessary (i.e. giving control to player, etc)
signal scene_change_finished()

var base_level_path = "res://levels/"
onready var anim = $anim

func _ready():
	pass
	
func change_scene(level_name, delay = 0.1):
	var scene_path = base_level_path + level_name + ".tscn"
	print("Scene change called")
	#Add delay here if you want to pause before scene fades out
#	yield(get_tree().create_timer(delay), "timeout")
	anim.play("fade_black")
	yield(anim, "animation_finished")
	assert(get_tree().change_scene(scene_path) == OK)
	yield(get_tree().create_timer(delay), "timeout")
	emit_signal("scene_just_changed")
	anim.play("fade_clear")
	yield(anim, "animation_finished")
	emit_signal("scene_change_finished")
	
	
	
## We need to make it so that there are two signals, one right when the scene changes, 
## and one when the animation has finished, which *starts* the scene.