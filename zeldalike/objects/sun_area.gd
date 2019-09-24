extends Area2D

export var mute_level = 0
export var reduction_per_mute = 0.025
export var base_damage = .1

func get_damage():
	return base_damage - (mute_level * reduction_per_mute)