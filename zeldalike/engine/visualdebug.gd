extends Node

var vanish_reticule_resource = preload("res://testing/vanish_reticule.tscn")


func instantiate_vanish_reticule(location):
	var reticule = vanish_reticule_resource.instance()
	reticule.global_position = location
	self.get_parent().add_child(reticule)