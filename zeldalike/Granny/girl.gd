extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$anim.play("normal")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func celebrate():
	$anim.play("party")
	$giggler.play()

func _on_Area2D_body_entered(body):
	if body.name == "Granny":
		$laugher.play()
		$anim.play("smile")


func _on_Area2D_body_exited(body):
	if body.name == "Granny":
		$anim.play("normal")
