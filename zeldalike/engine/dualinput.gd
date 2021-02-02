extends Node

var default_threshold = .3

var inputs_lastpressed = {"left": 0.0, "right": 0.0, "up": 0.0, "down": 0.0, "sack": 0.0, "action": 0.0}
var inputs_justpressed = {"left": 0.0, "right": 0.0, "up": 0.0, "down": 0.0, "sack": 0.0, "action": 0.0}

var has_started = false

func _ready():
	
	
	pass

func _physics_process(delta):
	for key in inputs_lastpressed.keys():
#		if key == debug_button:
#			print(key + " is at current value " + String(inputs_justpressed[key]))
#			print(key + " is at previous value " + String(inputs_lastpressed[key]))
#			print("---")
		
		inputs_lastpressed[key] = inputs_lastpressed[key] + delta
		inputs_justpressed[key] = inputs_justpressed[key] + delta
		
		if Input.is_action_just_pressed(key):
			inputs_lastpressed[key] = inputs_justpressed[key]
			inputs_justpressed[key] = 0.0
	
#	if  was_just_doublepressed_in_threshold(debug_button, 0.4):
#		print("Sensed a doublepress for " + debug_button + " --------------------------")
#		pass
	
	pass

func is_action_just_doublepressed_in_threshold(input_button, custom_threshold):
	if Input.is_action_just_pressed(input_button) && inputs_lastpressed[input_button] <= custom_threshold:
		return true
	return false
	
func is_action_just_doublepressed(input_button):
	return is_action_just_doublepressed_in_threshold(input_button, default_threshold)
	
#func was_just_doublepressed(input_button):
#	if Input.is_action_just_pressed(input_button) && inputs_lastpressed[input_button] <= default_threshold:
#		return true
#	return false