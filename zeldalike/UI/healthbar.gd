extends Control

onready var health_bar = $bar
onready var health_under = $barunder
onready var tween = $updatetween

var player


export (Color) var healthy_color = Color.green
export (Color) var caution_color = Color.yellow
export (Color) var danger_color = Color.red
export (float, 0, 1, 0.05) var caution_zone = 0.5
export (float, 0, 1, 0.05) var danger_zone = 0.2

func _ready():
	pass
	
func setup(player_node):
	player = player_node
	player.connect("health_changed", self, "_on_health_updated")
	health_bar.value = player.health
	health_bar.max_value = player.maxhealth
	health_under.value = player.health
	health_under.max_value = player.maxhealth
	_assign_color(player.health)
	pass

func _on_health_updated(health, change):
	health_bar.value = health
	tween.interpolate_property(health_under, "value", health_bar.value, health, 0.2 , Tween.TRANS_SINE, Tween.EASE_OUT, 0.2)
	tween.start()
	_assign_color(health)
	
func on_max_health_updated(max_health):
	health_bar.max_value = max_health
	health_under.max_value = max_health

func _assign_color(health):
	if health < health_bar.max_value * danger_zone:
		health_bar.tint_progress = danger_color
	elif health < health_bar.max_value * caution_zone:
		health_bar.tint_progress = caution_color
	else: health_bar.tint_progress = healthy_color
		
	