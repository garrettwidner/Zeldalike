extends Node2D

var events

func _ready():
	events = load_file_as_JSON("res://dialogue/story/events.json")
	
func _process(delta):
	if Input.is_action_pressed("a"):
		#print(events.result)
		
		if typeof(events.result) != TYPE_DICTIONARY:
			print("load_file_as_JSON() has not yet returned a dictionary")
		elif typeof(events.result) == TYPE_DICTIONARY:
			print("load_file_as_JSON() has returned a dictionary")
			
		print(events.result["1"])

func load_file_as_JSON(file_path):
	var file = File.new()
	assert file.file_exists(file_path)
	
	file.open(file_path, file.READ)
	var filedict = JSON.parse(file.get_as_text())
	
	return filedict