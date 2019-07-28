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
	sceneStory = load_file_as_JSON("res://dialogue/story/story_1.json")
	events = load_file_as_JSON("res://dialogue/story/events.json")
	experiences = load_file_as_JSON("res://dialogue/story/experiences.json")
	
	
	#TODO!!!!!!------ Save events and other editable story files as copies of the original.
	#                 whenever loading the game, create a copy and write to that to pull from
	#   			  when the game is finished, you can save this copy as persistent.
	
	if(typeof(sceneStory) != TYPE_DICTIONARY):
		print("ERROR: story file has errors")
	if(typeof(events) != TYPE_DICTIONARY):
		print("ERROR: events file has errors")
	if(typeof(experiences) != TYPE_DICTIONARY):
		print("ERROR: experiences file has errors")
	
	print(events["eventTarget"]["farmer"]["Beginning"]["Flags"]["hasBeenUsed"])
	print("--------")
	
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
	
	currTarget = target
	
	var dialogue_branch = choose_dialogue_branch(target)
	print(dialogue_branch)
	get_node("../" + target.name).update_experiences(experiences)
	
	if dialogue_branch == null:
		print("ERROR: No dialogue branch found")
		return
	
	initStory = sceneStory["data"][dialogue_branch]
#	print(initStory["0"]["content"][1])
	#currDialogue = initStory["0"]["content"]
	#textContainer.get_node("text").set_text(currDialogue[0])
	
	#within here, make sure to check whether the story branch has an 'experiences'
	#field associated with it and if so, flip the experience to true or false depending on specifications
	
	pass

func choose_dialogue_branch(target):
	var possibleBranches = look_up_events(target)
	var dialogue = choose_dialogue(possibleBranches)
	return dialogue
	
#Returns a dictionary of event information based on the target name
func look_up_events(target):
	var eventdict = events["eventTarget"][target.name]
	#print(eventdict["Beginning"])
	return eventdict
	
	
# returns the name of a dialogue branch from the events file given a target's possible events
#  ??????????????????   ---- This has been logically completed, it should work
func choose_dialogue(possibilities):
	
	for option in possibilities:
		var allTrue : bool = true
		var checkHasBeenUsed = false
		
		if possibilities[option]["Name"] == "FarmerInitial":
			print("allTrue is " + String(allTrue))
		
		for key in possibilities[option]["Flags"].keys():
			if possibilities[option]["Name"] == "FarmerInitial":
				print(key)
			if key == "default":
#				if possibilities[option]["Name"] == "FarmerInitial":
#					print("default")
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
#				for event in events["eventTarget"][currTarget.name]:
#					if events["eventTarget"][currTarget.name][event]["Name"] == possibilities[option]["Name"]:
#						events["eventTarget"][currTarget.name][event]["Flags"]["hasBeenUsed"] = true
				pass
		
		if possibilities[option]["Name"] == "FarmerInitial":	
			print("allTrue is now " + String(allTrue))
		
		if allTrue:
			print("returning " + possibilities[option]["Name"])
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

		
