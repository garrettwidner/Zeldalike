extends Position2D

onready var tilemap = $TileMap
onready var collision = get_node("TileMap/Area2D/CollisionPolygon2D")

var start_opacity = 0
var end_opacity = 1

var a
var b
var t
var speed = .7

var is_becoming_visible = false

func _ready():
	tilemap.modulate.a = 0
	collision.disabled = true

func on_spring_unblocked():
	is_becoming_visible = true
	a = start_opacity
	b = end_opacity
	t = 0
	collision.disabled = false
	pass
	
func _process(delta):
	if is_becoming_visible:
		t += delta * speed
		
		if t >= 1:
			t = 1
			is_becoming_visible = false
					
		var new_opacity = a + (b - a) * t
		tilemap.modulate.a = new_opacity
		

