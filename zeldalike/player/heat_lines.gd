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
	if player != null:
		player.connect("on_sun_strength_changed", self, "on_sun_changed")
		
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
	
func on_sun_changed(new_strength):
	if new_strength > 0:
		appear()
	else:
		disappear()
	
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
	