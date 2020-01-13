extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var recipe
var has_seen = false

# Called when the node enters the scene tree for the first time.
func _ready():
	recipe = get_node("RecipeSprite")
	hide_recipe()
	$anim.play("normal")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func show_recipe():
	recipe.show()
	has_seen = true
	$anim.play("normal")
	$hm.play()
	pass
	
func hide_recipe():
	recipe.hide()
	pass


func _on_Area2D_body_entered(body):
	if body.name == "Granny":
		show_recipe()


func _on_Area2D_body_exited(body):
	if body.name == "Granny":
		hide_recipe()


func _on_Timer_timeout():
	if !has_seen:
		$anim.play("glow")

func _on_glow_trigger_body_entered(body):
	if body.name == "Granny":
		if !has_seen:
			$anim.play("glow")
