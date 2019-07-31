extends Node

var sceneStory = {}
var events = {}
var experiences = {}

var panelNode
var textContainer
var nameContainer

var isDialogueEvent 
var currDialogue
var currBranch

var isActivated = false
var isRunning = false

var currTarget

signal dialogue_finished

func _ready():
	sceneStory = load_file_as_JSON("res://dialogue/story/story_1.json")
	events = load_file_as_JSON("res://dialogue/story/events.json")
	experiences = load_file_as_JSON("res://dialogue/story/experiences.json")
	
	if(typeof(sceneStory) != TYPE_DICTIONARY):
		print("ERROR: story file has errors")
	if(typeof(events) != TYPE_DICTIONARY):
		print("ERROR: events file has errors")
	if(typeof(experiences) != TYPE_DICTIONARY):
		print("ERROR: experiences file has errors")
	
	panelNode = get_node("../dialogue_box/Panel")
	textContainer = get_node("../dialogue_box/Panel/MarginContainer/VBoxContainer/text")
	nameContainer = get_node("../dialogue_box/Panel/MarginContainer/VBoxContainer/name")
	
	if(panelNode.is_visible()):
		panelNode.hide()
	
func _process(delta):
	if isActivated and Input.is_action_just_pressed("a"):
		if !isRunning:
			init_dialogue()
		else:
			change_panel_dialogue()
		pass

func activate(target):
	currTarget = target
	isActivated = true

func change_panel_dialogue():
	var nextText = ""
	set_next_branch()
	nextText = currBranch["content"]
	textContainer.set_text(nextText)
	
func set_next_branch():
	if! (currBranch["conditions"].keys().has("isEnd")):
		var nextBranch = currDialogue[currBranch["conditions"]["divert"]]
		currBranch = nextBranch
	else:
		emit_signal("dialogue_finished")
		panelNode.hide()
		isRunning = false
		isActivated = false
	pass
	
func init_dialogue():
	
	print("dialogue initted")
	isDialogueEvent = false
	currDialogue = null
	currBranch = null
	
	isRunning = true
	
	var dialogue_branch = choose_dialogue_branch()
	var current_node = get_node("../" + currTarget.name)
	if current_node.has_method("update_experiences"):
		current_node.update_experiences(experiences)
	
	if dialogue_branch == null:
		print("ERROR: No dialogue branch found")
		return
	
	currDialogue = sceneStory["data"][dialogue_branch]
	currBranch = currDialogue["0"]
	var currText = currBranch["content"]
	print(currText)
	
	#TODO: 
	#	   Make it so 'experiences' are drawn from to change which dialogue plays
	#      Make it so items can be added to inventory through dialogue
	
	panelNode.show()
	nameContainer.set_text(currTarget.name)
	textContainer.set_text(currText)
	
	#within here, make sure to check whether the story branch has an 'experiences'
	#field associated with it and if so, flip the experience to true or false depending on specifications
	
	pass

func choose_dialogue_branch():
	var possibleBranches = look_up_events()
	var dialogue = choose_dialogue(possibleBranches)
	return dialogue
	
#Returns a dictionary of event information based on the target name
func look_up_events():
	var eventdict = events["eventTarget"][currTarget.name]
	return eventdict
	
# returns the name of a dialogue branch from the events file given a target's possible events
func choose_dialogue(possibilities):
	
	for option in possibilities:
		var allTrue : bool = true
		var checkHasBeenUsed = false
		
		for key in possibilities[option]["Flags"].keys():
			if key == "default":
				pass
			elif key == "hasBeenUsed":
				if(possibilities[option]["Type"] == "Unique" or possibilities[option]["Type"] == "Start"):
					checkHasBeenUsed = true
			elif experiences.has(key):
				if experiences[key] != possibilities[option]["Flags"][key]:
					allTrue = false
					
			elif !experiences.has(key):
				print("Experience needs to be created/reconciled: " + key)
		

		if checkHasBeenUsed and allTrue:
			if possibilities[option]["Flags"]["hasBeenUsed"]:
				allTrue = false
			elif !possibilities[option]["Flags"]["hasBeenUsed"]:
				#Sets hasBeenUsed to true in the events file
				for event in events["eventTarget"][currTarget.name]:
					if events["eventTarget"][currTarget.name][event]["Name"] == possibilities[option]["Name"]:
						events["eventTarget"][currTarget.name][event]["Flags"]["hasBeenUsed"] = true
				pass
				
		if allTrue:
			return possibilities[option]["Name"]
		
	return null
	
func load_file_as_JSON(file_path):
	var file = File.new()
	assert file.file_exists(file_path)
	
	file.open(file_path, file.READ)
	var filejson = JSON.parse(file.get_as_text())
	if filejson.error == 0:
		return filejson.result
	else:
		return ""

		
