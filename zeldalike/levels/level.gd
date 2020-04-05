extends Node2D

export var scene_name : String = "Level"
export var default_entrance : int = 1

func _ready():
	game_singleton.perform_first_setup_if_needed(default_entrance)