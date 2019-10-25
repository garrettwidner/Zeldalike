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

var trig_objects = []

func _ready():
	if triggerable_1 != "":
		trig_object_1 = get_node(triggerable_1)
		trig_objects.append(trig_object_1)
	if triggerable_2 != "":
		trig_object_2 = get_node(triggerable_2)
		trig_objects.append(trig_object_2)
	if triggerable_3 != "":
		trig_object_3 = get_node(triggerable_3)
		trig_objects.append(trig_object_3)
	if triggerable_4 != "":
		trig_object_4 = get_node(triggerable_4)
		trig_objects.append(trig_object_4)
	if triggerable_5 != "":
		trig_object_5 = get_node(triggerable_5)
		trig_objects.append(trig_object_5)
	
	pass
	
func _process(delta):
	if Input.is_action_just_pressed("a"):
		print("Spring was unblocked")
		for object in trig_objects:
			object.on_spring_unblocked()
	pass