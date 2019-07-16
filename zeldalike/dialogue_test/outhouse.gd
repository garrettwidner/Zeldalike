extends Node2D

var hasfallen = false
var brickresource = preload("res://dialogue_test/brick.tscn")


func _ready():
	$anim.play("rise")
	
func fall():
	$anim.play("fall")
	var brick = brickresource.instance()
	brick.position = $spawnpoint.position