extends Sprite

var invisible_alpha = 0.0
var visible_alpha = 0.4


var transitionstart : float = 0
var transitionend : float = 0
var transitionspeed : float = .015
var transitionweight : float = 0

var istransitioning = false

var player

func _ready():
	player = get_node("/root/Level/player")
	player.connect("on_entered_sun_area", self, "appear")
	player.connect("on_exited_sun_area", self, "disappear")
	get_node("anim").play("heat")
	visible = true
	modulate.a = 0
	
func _process(delta):
	if istransitioning:
		var newmodulate = transitionstart + (transitionend - transitionstart) * transitionweight
		modulate.a = newmodulate
		transitionweight += transitionspeed
		
		if transitionweight >= 1:
			istransitioning = false
		
		
	pass
	
func appear():
	transitionstart = modulate.a
	transitionend = visible_alpha
	transitionweight = 0
	istransitioning = true
	pass
	
func disappear():
	transitionstart = modulate.a
	transitionend = invisible_alpha
	transitionweight = 0
	istransitioning = true
	pass
	