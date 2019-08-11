extends "res://objects/object.gd"

var isopen : bool = false

signal doorwasopened

func _ready():
	$anim.play("close")
	
func _process(delta):
	pass

func update_experiences(experiences, items):
	if items.has("brick") and items.has("pickaxe"):
		opendoor()

func action(inventory):
#	if inventory.find("brick") != null:
#		opendoor()
	pass
		
func opendoor():
	isopen = true
	emit_signal("doorwasopened")
	$anim.play("open")
	
func _on_Area2D_body_enter():
#	print("Body entered")
	pass