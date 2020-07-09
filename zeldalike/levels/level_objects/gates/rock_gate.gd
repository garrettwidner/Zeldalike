extends StaticBody2D

export(Array, NodePath) var enemy_paths

var enemies = []
var alive_count = 0
var gate_sound_delay = .21

func _ready():
	$AnimationPlayer.play("staid")
	$Timer.connect("timeout", self, "play_gate_noise")
	
	for p in enemy_paths:
		var enemy = get_node(p)
		enemies.push_back(enemy)
		alive_count = alive_count + 1
		
	for e in enemies:
		e.connect("on_died", self, "enemy_died")
#		print("Connected " + e.name + " to rock_gate")
		pass
		
func enemy_died(enemy):
	print("Enemy " + enemy.name + " died")
	alive_count = alive_count - 1
	print("Enemies alive: " + String(alive_count))
	if alive_count == 0:
		all_enemies_died()
	pass
	
func all_enemies_died():
	print("All enemies died")
	$AnimationPlayer.play("zip")
	$Timer.start(gate_sound_delay)
	
func play_gate_noise():
	$AudioStreamPlayer2D.play()