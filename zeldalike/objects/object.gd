extends Node

#defines an object physically present within the world

func _ready():
	pass
	
#called just before dialogue commences. Never used to modify items or experiences, only references them
func update_experiences(experiences, items):
	pass
#called upon pressing interact button
func action(inventory):
	pass