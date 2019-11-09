extends Node

var bulb_resource = preload("res://environment/springs/triggerables/Bulb.tscn")
var bulb = null

func _ready():
	$AnimationPlayer.play("bud")

func on_spring_unblocked():
	$AnimationPlayer.play("grow")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "grow":
		spawn_bulb()
		$AnimationPlayer.play("grown")
		
		
func spawn_bulb():
	if bulb == null:
		bulb = bulb_resource.instance()
		print(bulb.position)
		self.get_parent().add_child(bulb)
		bulb.global_position = $bulb_spawn_point.global_position
		print(bulb.position)
		
	pass
