extends Node2D

var hasfallen = false
var brickresource = preload("res://dialogue_test/brick.tscn")
var brickoffset = Vector2(-13,8)

func update_experiences(experiences, items):
	if items.has("pickaxe") and !hasfallen:
		crumble()
		hasfallen = true
	
	pass

func crumble():
	fall()
	var brick = brickresource.instance()
	brick.position = transform.get_origin()
	brick.position.x += brickoffset.x
	brick.position.y += brickoffset.y
	self.get_parent().add_child(brick)
	
	get_node("..").add_interactible(brick)

func _ready():
	$anim.play("rise")
	
func fall():
	$anim.play("fall")
	var brick = brickresource.instance()
	brick.position = $spawnpoint.position