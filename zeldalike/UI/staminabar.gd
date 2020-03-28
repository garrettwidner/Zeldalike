extends Control

onready var bar = $bar
onready var under = $barunder
onready var tween = $updatetween

var player


export (Color) var full_color = Color.green
export (Color) var caution_color = Color.yellow
export (Color) var danger_color = Color.red
export (float, 0, 1, 0.05) var caution_zone = 0.5
export (float, 0, 1, 0.05) var danger_zone = 0.2

func setup(player_node):
	player = player_node
	player.connect("stamina_changed", self, "_on_stamina_updated")
	bar.value = player.stamina
	bar.max_value = player.maxstamina
	under.value = player.maxstamina
	under.max_value = player.maxstamina
	_assign_color(player.stamina)
	
func _on_stamina_updated(stamina, change):
	bar.value = stamina
	tween.interpolate_property(under, "value", bar.value, stamina, 0.2 , Tween.TRANS_SINE, Tween.EASE_OUT, 0.2)
	tween.start()
	_assign_color(stamina)
	
func on_max_stamina_updated(max_stamina):
	bar.max_value = max_stamina
	under.max_value = max_stamina

func _assign_color(stamina):
	if stamina < bar.max_value * danger_zone:
		bar.tint_progress = danger_color
	elif stamina < bar.max_value * caution_zone:
		bar.tint_progress = caution_color
	else: bar.tint_progress = full_color
		
	