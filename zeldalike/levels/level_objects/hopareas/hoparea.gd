extends Area2D

export var updirection = dir.UP
export var canhopup = true
export var canhopdown = false

onready var hoptop = get_node("hoptop")
onready var hopbott = get_node("hopbott")
onready var hopcling = get_node("hopcling")

var highesthoppoint
var lowesthoppoint
var clingpoint

var height

func _ready():
	if updirection != dir.UP && updirection != dir.DOWN && updirection != dir.LEFT && updirection != dir.RIGHT:
		print("WARNING: Hoparea variable updirection must be a cardinal direction vector")
		
	var extents = get_node("CollisionShape2D").shape.extents
	height = extents.y * 2
	
	highesthoppoint = hoptop.global_position
	lowesthoppoint = hopbott.global_position
	clingpoint = hopcling.global_position