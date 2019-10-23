extends Node

export(NodePath) var triggerable_1
export(NodePath) var triggerable_2
export(NodePath) var triggerable_3
export(NodePath) var triggerable_4
export(NodePath) var triggerable_5

var trig_object_1
var trig_object_2
var trig_object_3
var trig_object_4
var trig_object_5

func _ready():
	if triggerable_1 != null:
		trig_object_1 = get_node("/root/Level/" + triggerable_1)
	#TODO: TEST THISSSSSS!
	pass