extends Node

var sceneStory = {}
var events = {}
var experiences = {}

var panelNode
var textContainer

var isDialogueEvent 
var initStory
var currDialogue
var isEnd

var currTarget

func _ready():
	#set_process_input(true)
	sceneStory = load_file_as_JSON("dialogue/story/story_1.json")
	events = load_file_as_JSON("dialogue/story/events.json")
	experiences = load_file_as_JSON("dialogue/story/experiences.json")
	
	panelNode = get_node("../dialogue_box/Panel")
	textContainer = get_node("..dialogue_box/Panel/MarginContainer/VBoxContainer")
	
	if(panelNode.is_visible()):
		panelNode.hide()
	
func _process(delta):
	##if Input.is_action_just_pressed("a"):
		#TODO: Do this from the player, or at least check the player's current state to see if it works.
		##change_panel_dialogue(currTarget)
		pass

#  ??????????????????   ---- This has been logically completed, it should work
func change_panel_dialogue(target):
	if(isEnd):
		panelNode.hide()
	var textToShow = ""
	set_next_dialogue(currTarget)
	textToShow = currDialogue[0]
	textContainer.get_node("text").set_text(textToShow)
	
func set_next_dialogue(target):
	if !("isEnd" in currDialogue[1]):
		var nextDialogue = initStory[currDialogue[1]["divert"]]
		currDialogue = nextDialogue["content"]
	else:
		isEnd = true
		get_node("../player").set_state_default()
	pass
	

#  ??????????????????   ---- This has been logically completed, it should work
func init_dialogue(target):
	
	isDialogueEvent = false
	initStory = null
	currDialogue = null
	isEnd = false
	
	print("flip")
	#TODO: Remove this and fix the functionality
	return
	currTarget = target
	
	var dialogue_branch = choose_dialogue_branch(target)
	get_node("../" + target).update_experiences(experiences)
	
	initStory = sceneStory["data"][dialogue_branch]
	currDialogue = initStory["0"]["content"]
	textContainer.get_node("text").set_text(currDialogue[0])
	
	#within here, make sure to check whether the story branch has an 'experiences'
	#field associated with it and if so, flip the experience to true or false depending on specifications
	
	pass

func choose_dialogue_branch(target):
	var possibleBranches = look_up_events(target)
	var dialogue = choose_dialogue(possibleBranches)
	
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
	return filedict
	

		
