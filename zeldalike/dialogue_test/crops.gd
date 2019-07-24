extends Node2D

func _ready():
	$anim.play("desprout")
	#var door = get_node("/root/Game/doorway")
	var door = get_node("../floodgate")
	door.connect("doorwasopened", self, "was_watered")

func was_watered():
	$anim.play("sprout")
	pass