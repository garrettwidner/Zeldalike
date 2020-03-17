extends Control

signal scene_changed()

var screenblack
var animation_player
var base_level_path = "res://levels/"

func _ready():
	screenblack = get_node("../screenblack")
	animation_player = screenblack.animation_player
	pass
	
func change_scene(level_name, delay = 0.5):
	var scene_path = base_level_path + level_name + ".tscn"

	yield(get_tree().create_timer(delay), "timeout")
	animation_player.play("fade_on")
	yield(animation_player, "animation_finished")
	assert(get_tree().change_scene(scene_path) == OK)
	animation_player.play("fade_off")
	yield(animation_player, "animation_finished")
	emit_signal("scene_changed")
