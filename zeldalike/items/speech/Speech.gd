extends Node2D

var TYPE : String = "PLAYER"
var DAMAGE : int = 0
var maxamount : int = 2
var is_purified = false

func _ready():
	TYPE = "PLAYER"
	$anim.play("sound")
	purify_speech()
#	print("Speech created")

func purify_speech():
	is_purified = true
	DAMAGE = 2

func _on_anim_animation_finished(anim_name):
	queue_free()
