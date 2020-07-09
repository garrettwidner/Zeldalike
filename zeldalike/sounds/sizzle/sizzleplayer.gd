extends AudioStreamPlayer2D

export(float) var loud_volume = 0
export(float) var soft_volume = -23.0

var transitionstart : float = 0
var transitionend : float = 0
var transitionspeed : float = .02
var transitionweight : float = 0

var istransitioning = false

var player

var is_setup = false

func _ready():
	player = get_node("../../../player")
	if player != null:
		player.connect("on_sun_strength_changed", self, "on_sun_changed")
#		print("Connected sizzleplayer to player")
	else:
		print("sizzleplayer found player node null")
		
	player.connect("on_initial_sun_check", self, "run_setup")
		
func run_setup(player, sun_strength):
	start_sizzle(sun_strength)
	is_setup = true
	
	
func start_sizzle(sun_strength):
	if sun_strength > 0:
		begin_sizzle()
	else:
		set_volume_db(soft_volume)
	
	pass
	
func _process(delta):
	if !is_setup:
		return
		
	
	if !playing:
		playing = true
		
	if istransitioning:
		var newmodulate = transitionstart + (transitionend - transitionstart) * transitionweight
		set_volume_db(newmodulate)
#		print(volume_db)
		transitionweight += transitionspeed
		
		if transitionweight >= 1:
			set_volume_db(transitionend)
			istransitioning = false
	
func on_sun_changed(new_strength):
#	print("Sizzleplayer noticed sun changed")
	if new_strength > 0:
		begin_sizzle()
	else:
		end_sizzle()
	
func begin_sizzle():
	transitionstart = volume_db
	transitionend = loud_volume
	transitionweight = 0
	istransitioning = true
	pass
	
func end_sizzle():
	transitionstart = volume_db
	transitionend = soft_volume
	transitionweight = 0
	istransitioning = true
	pass
	