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
	var branch = choose_dialogue(possibleBranches, experiences)
	if(branch != null):
		return branch
		
	
#Returns a dictionary of event information based on the target name
func look_up_events(target):
	return events["eventTarget"][target]
	
func choose_dialogue(possibilities, experiences):
	for item in possibilities:
		if(item != "Start" and item != "Repeat"):
			#Need to rewrite this based on my own flag system
			
			var allTrue : bool = false
			for experience in experiences[possibilities[item]["Flags"]]:
				#have to ask here if the experience there is true. 
				#how to do this I'm not sure.
				pass
			
			#her old code:
			#if(experiences[possibilities[item]["Flag"]]):
				#return possibilities[item]["Name"]
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