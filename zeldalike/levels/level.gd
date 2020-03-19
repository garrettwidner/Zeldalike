extends Node2D

export var scene_name : String = "Level"

func _ready():
	game_singleton.perform_first_setup_if_needed()