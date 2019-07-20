extends Node

var sceneStory = {}
var events = {}
var experiences = {}

var isDialogueEvent 
var initStory
var currDialogue
var currChoices
var isChoice
var isChoiceDialogue
var isEnd

func _ready():
	#set_process_input(true)
	sceneStory = load_file_as_JSON("dialogue/story/story_1.json")
	events = load_file_as_JSON("dialogue/story/events.json")
	experiences = load_file_as_JSON("dialogue/story/experiences.json")
	
	

func choose_dialogue_branch(target):
	var possibleBranches = look_up_events(target)
	var dialogue = choose_dialogue(possibleBranches)
	
	#check if contains hasbeenused flag
	#check if it has no flags, no conditions, meaning it's the default
	
	
	#
	
#Returns a dictionary of event information based on the target name
func look_up_events(target):
	return events["eventTarget"][target]
	
# returns the name of a dialogue branch from the events file given a target's possible events
#  ??????????????????   ---- This has been logically completed, it should work
func choose_dialogue(possibilities):
	for option in possibilities:
		var allTrue : bool = true
		var checkHasBeenUsed = false
		
		for key in option["Flags"].keys():
			if key == "default":
				pass
			if key == "hasBeenUsed": 
				if (option["Type"] == "Unique" or option["Type"] == "Start"):
					checkHasBeenUsed = true
			elif experiences[key] != option["Flags"][key]:
				allTrue = false
				
		if checkHasBeenUsed:
			if option["Flags"]["hasBeenUsed"]:
				allTrue = false
			else:
				option["Flags"]["hasBeenUsed"] = true
				
		if allTrue:
			return possibilities[option]["Name"]
	return null
	
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
		
func init_dialogue(target):
	
	isDialogueEvent = false
	initStory = null
	currDialogue = null
	currChoices = []
	isChoice = false
	isChoiceDialogue = false
	isEnd = false
	
	var dialogue_branch = choose_dialogue_branch(target)
	get_node("../" + target).update_experiences(experiences)
	
	#within here, make sure to check whether the story branch has an 'experiences'
	#field associated with it and if so, flip the experience to true or false depending on specifications
	
	pass