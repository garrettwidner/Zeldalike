extends Node

var sceneStory = {}
var events = {}
var experiences = {}

func _ready():
	#set_process_input(true)
	sceneStory = load_file_as_JSON("dialogue/story/story_1.json")
	events = load_file_as_JSON("dialogue/story/events.json")
	experiences = load_file_as_JSON("dialogue/story/experiences.json")
	
func choose_dialogue_branch(target):
	var possibleBranches
	
func load_file_as_JSON(file_path) -> Dictionary:
	var file = File.new()
	assert file.file_exists(file_path)
	
	file.open(file_path, file.READ)
	var filedict = parse_json(file.get_as_text())
	assert filedict.size() > 0
	return filedict
	
func _process(delta):
	if Input.is_action_just_pressed("a"):
		#cycle or start dialogue
		pass