extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var girl
var cake
var UIcover

# Called when the node enters the scene tree for the first time.
func _ready():
	girl = get_node("/root/Level/girl")
	cake = get_node("/root/Level/Cake2")
	UIcover = get_node("/root/Level/UI")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(body):
	if body.name == "Granny":
		if body.cakes == 1:
			body.freeze()
			cake.position = position + Vector2(-5, -10)
			girl.celebrate()
			UIcover.fade_out()
