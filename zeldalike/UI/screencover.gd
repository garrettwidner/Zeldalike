extends Sprite

var brightopacity = .3
var normalopacity = 0

var transitionstart : float = 0
var transitionend : float = 0
var transitionspeed : float = .015
var transitionweight : float = 0

var istransitioning = false

var player

func _ready():
	player = get_node("/root/Level/player")
	player.connect("on_entered_sun_area", self, "increase_brightness")
	player.connect("on_exited_sun_area", self, "decrease_brightness")

func _process(delta):
	if istransitioning:
		var newmodulate = transitionstart + (transitionend - transitionstart) * transitionweight
		
		modulate.a = newmodulate
		transitionweight += transitionspeed
		
		if transitionweight >= 1:
			istransitioning = false
		
		
	pass
	
func increase_brightness():
	print("Increasing brightness")
	transitionstart = modulate.a
	transitionend = brightopacity
	transitionweight = 0
	istransitioning = true
	pass
	
func decrease_brightness():
	print("Decreasing brightness")
	transitionstart = modulate.a
	transitionend = normalopacity
	transitionweight = 0
	istransitioning = true
	pass