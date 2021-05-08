extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(body):
	print("Body " + body.name + " entered")
	$Sprite.visible = true


func _on_Area2D_body_exited(body):
	print("Body " + body.name + " exited")
	$Sprite.visible = false
