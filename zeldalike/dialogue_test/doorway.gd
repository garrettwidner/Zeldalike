extends "res://objects/object.gd"

var isopen : bool = false

signal doorwasopened

func _ready():
	$anim.play("close")
	
func _process(delta):
	if Input.is_action_just_pressed("a"):
		print("Testing in doorway script for door to be opened")
		opendoor()

func action(inventory):
	#not sure if works
	if inventory.find("brick") != null:
		opendoor()
		
func opendoor():
	isopen = true
	emit_signal("doorwasopened")
	$anim.play("open")
	
func _on_Area2D_body_enter():
	print("Body entered")