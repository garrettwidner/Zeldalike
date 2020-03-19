extends Control

signal scene_changed()

var base_level_path = "res://levels/"
onready var anim = $anim

func _ready():
	pass
	
func change_scene(level_name, delay = 0.5):
	var scene_path = base_level_path + level_name + ".tscn"

	yield(get_tree().create_timer(delay), "timeout")
	anim.play("fade_black")
	yield(anim, "animation_finished")
	assert(get_tree().change_scene(scene_path) == OK)
	anim.play("fade_clear")
	yield(anim, "animation_finished")
	emit_signal("scene_changed")
