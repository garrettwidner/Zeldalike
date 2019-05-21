extends Area2D

export(bool) var disappears = false

func _ready():
	connect("body_entered", self, "body_entered")
	connect("area_entered", self, "area_entered")
	
func area_entered(area):
	var area_parent = area.get_parent()
	#could later make this a group for multiple items that can pick up pickups
	if area_parent.name == "sword":
		body_entered(area_parent.get_parent())
		
func body_entered(body):
	pass