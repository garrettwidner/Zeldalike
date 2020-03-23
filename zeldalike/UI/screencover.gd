extends Sprite

var bright3 = .75
var bright2 = .5
var bright1 = .25
var bright0 = 0

var current_brightness_level : int = 0
var max_brightness_level : int = 3

var transitionstart : float = 0
var transitionend : float = 0
var transitionspeed : float = .015
var transitionweight : float = 0

var istransitioning = false

var player
	
func _ready():
	var scenechanger = get_node("../scenechanger")
	scenechanger.connect("scene_changed", self, "setup")
	
func setup(found_player):
	player = found_player
#	print("Setup called on screencover")
#	player = get_node("/root/Level/YSort/actors/player")
	player.connect("on_sun_strength_changed", self, "on_sun_changed")
	
	set_starting_brightness(player.get_sun_current_strength())
	
	visible = true
	$anim.play("swelter")
	
	pass
	


func _process(delta):
#	if Input.is_action_just_pressed("a"):
#		increase_brightness()
#	elif Input.is_action_just_pressed("b"):
#		decrease_brightness()
	
	if istransitioning:
		var newmodulate = transitionstart + (transitionend - transitionstart) * transitionweight
		
		modulate.a = newmodulate
		transitionweight += transitionspeed
		
		if transitionweight >= 1:
			istransitioning = false
	pass
	
func on_sun_changed(new_strength):
#	print("Screencover notified that sun changed")
	var base_strength = floor(new_strength)
	if base_strength > current_brightness_level:
		set_brightness_level(base_strength)
		increase_brightness()
	elif base_strength < current_brightness_level:
		set_brightness_level(base_strength)
		decrease_brightness()
		
func set_starting_brightness(start_brightness):
	var start_strength = floor(start_brightness)
	set_brightness_level(start_strength)
#	print("current brightness level according to screencover: " + String(current_brightness_level))
	modulate.a = get_brightness_value()
	pass

func increase_brightness():
#	change_brightness_level(1)
	var new_brightness = get_brightness_value()
	transitionstart = modulate.a
	transitionend = new_brightness
	transitionweight = 0
	istransitioning = true
	pass
	
func decrease_brightness():
#	change_brightness_level(-1)
	var new_brightness = get_brightness_value()
	transitionstart = modulate.a
	transitionend = new_brightness
	transitionweight = 0
	istransitioning = true
	pass
	
func change_brightness_level(change):
	current_brightness_level += change
	constrain_brightness_level()
		
func set_brightness_level(new):
	current_brightness_level = new
	constrain_brightness_level()
	
func constrain_brightness_level():
	if current_brightness_level > max_brightness_level:
		current_brightness_level = max_brightness_level
	elif current_brightness_level < 0:
		current_brightness_level = 0
	
func get_brightness_value():
	match current_brightness_level:
		0:
			return bright0
		1:
			return bright1
		2: 
			return bright2
		3:
			return bright3