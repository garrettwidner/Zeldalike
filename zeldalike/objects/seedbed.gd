extends Node2D

var isdead : bool = true

func _ready():
	$anim.play("die")
	pass
	
func _process(delta):
	for area in $Area2D.get_overlapping_areas():
		var body = area.get_parent()
		
		if body.get("TYPE") != null && body.get("TYPE") == "Sprinkle" && isdead:
			isdead = false
			$anim.play("grow")
			
		