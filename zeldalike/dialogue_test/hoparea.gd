extends Area2D

export var aboveheight = 1
export var abovez = 200
export var belowheight = 0
export var belowz = 100
export var canhopup = true
export var canhopdown = false

onready var hoptop = get_node("hoptop")
onready var hopbott = get_node("hopbott")

var highesthoppoint
var lowesthoppoint

var height

var clingpoint

var clingloweringmultiplier = 6

onready var spritetester = get_node("Sprite")
var extents

func _ready():
	var extents = get_node("CollisionShape2D").shape.extents
	height = extents.y * 2
	var topextents = hoptop.get_node("CollisionShape2D").shape.extents
	var bottomextents = hopbott.get_node("CollisionShape2D").shape.extents
#	highesthoppoint = Vector2(global_position.x, global_position.y - extents.y + (2 * topextents.y))
#	lowesthoppoint = Vector2(global_position.x, global_position.y + extents.y - (2 * bottomextents.y))
	highesthoppoint = hoptop.global_position
	lowesthoppoint = hopbott.global_position
	clingpoint = Vector2(global_position.x, global_position.y - extents.y + (clingloweringmultiplier * topextents.y))
	get_node("Sprite").global_position = highesthoppoint
	pass
	
func _process(delta):
	if(Input.is_key_pressed(KEY_H)):
		spritetester.global_position = clingpoint
		