extends Node

var sceneStory = {}
var events = {}
var experiences = {}

var panelNode
var textContainer
var nameContainer

var currDialogue
var currBranch

var isActivated = false
var isRunning = false

var currTarget

signal dialogue_finished

var inventorymanager


func _ready():
	#TODO: Get inventory_manager to call on whenever a dialogue gives an item
	var scene_name = get_tree().get_current_scene().scene_name
	
	
	
	sceneStory = load_file_as_JSON("res://dialogue/story/" + String(scene_name) + "_story.json")
	events = load_file_as_JSON("res://dialogue/events/" + String(scene_name) + "_events.json")
	experiences = load_file_as_JSON("res://dialogue/data/experiences.json")
	
	if(typeof(sceneStory) != TYPE_DICTIONARY):
		print("ERROR: story file has errors")
	if(typeof(events) != TYPE_DICTIONARY):
		print("ERROR: events file has errors")
	if(typeof(experiences) != TYPE_DICTIONARY):
		print("ERROR: experiences file has errors")
	
	panelNode = get_node("../dialogue/dialogue_box/Panel")
	textContainer = get_node("../dialogue/dialogue_box/Panel/MarginContainer/VBoxContainer/text")
	nameContainer = get_node("../dialogue/dialogue_box/Panel/MarginContainer/VBoxContainer/name")
	
	if(panelNode.is_visible()):
		panelNode.hide()
		
	inventorymanager = get_node("../inventorymanager")
	
func _process(delta):
	if isActivated and Input.is_action_just_pressed("a"):
		if !isRunning:
			start_dialogue()
		else:
			change_dialogue_branch()
		pass

func activate(target):
	var target_is_valid = events["eventTarget"].has(target.name)
	
	if target_is_valid:
		currTarget = target
		isActivated = true
		
	return target_is_valid

func change_dialogue_branch():
	var nextText = ""
	set_next_branch()
	nextText = currBranch["content"]
	textContainer.set_text(nextText)
	
func set_next_branch():
	if! (currBranch["conditions"].keys().has("isEnd")):
		var nextBranch = currDialogue[currBranch["conditions"]["divert"]]
		currBranch = nextBranch
		set_experiences_from_dialogue()
		set_items_from_dialogue()
		
	else:
		emit_signal("dialogue_finished")
		panelNode.hide()
		isRunning = false
		isActivated = false
	pass
	
func start_dialogue():
	
	currDialogue = null
	currBranch = null
	
	isRunning = true
	
	var dialogue_branch = choose_dialogue_branch()
	var current_node = get_node("../" + currTarget.name)
	if current_node.has_method("update_experiences"):
		current_node.update_experiences(experiences, inventorymanager.get_item_dict())
	
	if dialogue_branch == null:
		print("ERROR: No dialogue branch found")
		return
	
	currDialogue = sceneStory["data"][dialogue_branch]
	currBranch = currDialogue["0"]
	set_experiences_from_dialogue()
	set_items_from_dialogue()
	
	var currText = currBranch["content"]
	
	#TODO: 
	#	   Make it so 'experiences' are drawn from to change which dialogue plays
	#      Make it so items can be added to inventory through dialogue
	
	panelNode.show()
	nameContainer.set_text(currTarget.name)
	textContainer.set_text(currText)
	
	#within here, make sure to check whether the story branch has an 'experiences'
	#field associated with it and if so, flip the experience to true or false depending on specifications
	
	pass
	
func set_experiences_from_dialogue():
	if currBranch.keys().has("experiences"):
		for experience in currBranch["experiences"]:
			if experiences.keys().has(experience):
				experiences[experience] = currBranch["experiences"][experience]
				print("Experience *" + experience + "* set to " + String(experiences[experience]))
		pass
	pass
	
func set_items_from_dialogue():
	if currBranch.keys().has("items"):
		for key in currBranch["items"].keys():
			if key == "gold":
				inventorymanager.add_gold(currBranch["items"][key])
			else:
				inventorymanager.add_item(key, currBranch["items"][key])
			

func choose_dialogue_branch():
	var possibleBranches = look_up_events()
	var dialogue = choose_dialogue(possibleBranches)
	return dialogue
	
#Returns a dictionary of event information based on the target name
func look_up_events():
	var eventdict = events["eventTarget"][currTarget.name]
	return eventdict
	
#Returns the name of a dialogue branch from the events file given a target's possible events
func choose_dialogue(possibilities):
	
	var starts = {}
	var repeats = {}
	var uniques = {}
	
	var prioritizePriorityOverType = false
	
	for option in possibilities:
		
		var allTrue : bool = true
		var checkAlreadyUsed = false
		
		for key in possibilities[option]["Flags"].keys():
			if key == "default" or key == "priority":
				pass
			elif key == "alreadyUsed":
				#Note: Do NOT remove "Start" designation. Check the tech doc for its usage.
				if(possibilities[option]["Type"] == "Unique" or possibilities[option]["Type"] == "Start"):
					if possibilities[option]["Flags"]["alreadyUsed"]:
						allTrue = false
			elif key.find("has") == 0:
				var item = key 
				item.erase(0,3)
				item = item.to_lower()
				
				if inventorymanager.has(item) != possibilities[option]["Flags"][key]:
					allTrue = false
			elif experiences.has(key):
				if experiences[key] != possibilities[option]["Flags"][key]:
					allTrue = false
					
			elif !experiences.has(key):
				print("Experience needs to be created/reconciled: " + key)
				
		#If the current possibility is a valid option, rank it according to its priority
		if allTrue:
			if (possibilities[option]["Type"] == "Unique"):
				if possibilities[option]["Flags"].keys().has("priority"):
					uniques[(possibilities[option]["Name"])] = possibilities[option]["Flags"]["priority"]
				else:
					uniques[(possibilities[option]["Name"])] = 0
			elif (possibilities[option]["Type"] == "Repeat"):
				if possibilities[option]["Flags"].keys().has("priority"):
					repeats[(possibilities[option]["Name"])] = possibilities[option]["Flags"]["priority"]
				else:
					repeats[(possibilities[option]["Name"])] = 0
			elif (possibilities[option]["Type"] == "Start"):
				if possibilities[option]["Flags"].keys().has("priority"):
					starts[(possibilities[option]["Name"])] = possibilities[option]["Flags"]["priority"]
				else:
					starts[(possibilities[option]["Name"])] = 0
					
	#Keep in mind, highest priority possible is 9, lowest is 0		
	var highest_priority = ""
	if !prioritizePriorityOverType:
		if uniques.size() > 0:
			for key in uniques.keys():
				if highest_priority == "":
					highest_priority = key
				else:
					if uniques[key] > uniques[highest_priority]:
						highest_priority = key
		elif starts.size() > 0:
			for key in starts.keys():
				if highest_priority == "":
					highest_priority = key
				else:
					if starts[key] > starts[highest_priority]:
						highest_priority = key
		else:
			for key in repeats.keys():
				if highest_priority == "":
					highest_priority = key
				else:
					if repeats[key] > repeats[highest_priority]:
						highest_priority = key
	else:
		if uniques.size() > 0:
			for key in uniques.keys():
				if highest_priority == "":
					highest_priority = key
				else:
					if uniques[key] > uniques[highest_priority]:
						highest_priority = key
		if starts.size() > 0:
			for key in starts.keys():
				if highest_priority == "":
					highest_priority = key
				else:
					if starts[key] > starts[highest_priority]:
						highest_priority = key
		if repeats.size() > 0:
			for key in repeats.keys():
				if highest_priority == "":
					highest_priority = key
				else:
					if repeats[key] > repeats[highest_priority]:
						highest_priority = key
	
	if highest_priority != "":
		var chosenType = ""
		
		#set alreadyUsed flag to true if it exists
		for option in possibilities:
			if possibilities[option]["Name"] == highest_priority:
				if possibilities[option]["Flags"].has("alreadyUsed"):
					possibilities[option]["Flags"]["alreadyUsed"] = true
					print("alreadyUsed set to true on " + option)
					
					#find the chosen dialogue's type
					chosenType = possibilities[option]["Type"]
					pass
		
		#if chosen dialogue skips over a nonrepeatable start, set alreadyUsed on that start to true
		for option in possibilities:
			if chosenType == "Unique" or chosenType == "Repeat":
				if possibilities[option]["Type"] == "Start" and possibilities[option]["Flags"].has("default"):
					possibilities[option]["Flags"]["alreadyUsed"] = true
					
		return highest_priority
	
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

		
