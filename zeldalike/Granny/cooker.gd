extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var cookarea
var cakewasspawned = false
var cake
var needed_berries = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	cake = get_node("/root/Level/Cake")
	$anim.play("firo")

	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func spawncake():
	cake.position = transform.get_origin() + Vector2(-14, 0)


func _on_Area2D_body_entered(body):
	
	if body.name == "Granny" && !cakewasspawned:
		if body.berries >= needed_berries:
			print("Cake spawned")
			spawncake()
			$anim_stretch.play("cook")
			$ding.play()
			body.drain_berries()
			cakewasspawned = true
