extends "res://levels/level_objects/knockable.gd"

export(NodePath) var triggerable_1
export(NodePath) var triggerable_2
export(NodePath) var triggerable_3
export(NodePath) var triggerable_4
export(NodePath) var triggerable_5
export(NodePath) var triggerable_6

var trig_object_1
var trig_object_2
var trig_object_3
var trig_object_4
var trig_object_5
var trig_object_6

var trig_objects = []

onready var anim = $AnimationPlayer
onready var water_opacity = $water/opacityanim
onready var water_anim = $water/AnimationPlayer

var is_unblocked = false

func _ready():
	anim.play("closed")
	water_opacity.play("closed")
	
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
	if triggerable_6 != "":
		trig_object_6 = get_node(triggerable_6)
		trig_objects.append(trig_object_6)
	
	pass
	
#func _process(delta):
#	if Input.is_action_just_pressed("a"):
#		if !is_unblocked:
#			unblock_spring()
#
#
#	pass
	
func get_knocked(knocked_by):
	unblock_spring()
	
func unblock_spring():
	is_unblocked = true
#	print("Spring was unblocked")
	anim.play("crumble")
	water_opacity.play("unblock")
	water_anim.play("flow")
	for object in trig_objects:
			object.on_spring_unblocked()
	pass
	
	
	
	
	
	
	
	
	
	
	