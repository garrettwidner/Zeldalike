extends Node2D

var hasfallen = false
var brickinstance = preload("res://dialogue_test/brick.tscn")


func _ready():
	$anim.play("rise")
	
func fall():
	$anim.play("fall")