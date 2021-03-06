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
	run_scene_setup()
	
	run_first_time_setup()
		
func run_scene_setup():
#	print("Scene setup being run on dialogue_parser")
	if get_tree().get_current_scene().name == "Level":
		var scene_name = get_tree().get_current_scene().scene_name
		print("Scene name is " + scene_name)
#		print("Loading scene story from 'res://dialogue/story/" + String(scene_name) + "_story.json'")
#		print("Loading scene events from 'res://dialogue/events/" + String(scene_name) + "_events.json'")
		
		sceneStory = helper.load_file_as_JSON("res://dialogue/story/" + String(scene_name) + "_story.json")
		events = helper.load_file_as_JSON("res://dialogue/events/" + String(scene_name) + "_events.json")
		experiences = helper.load_file_as_JSON("res://dialogue/data/experiences.json")
		
		if(typeof(sceneStory) != TYPE_DICTIONARY):
			print("ERROR: story file 'res://dialogue/story/" + String(scene_name) + "_story.json has errors'")
		if(typeof(events) != TYPE_DICTIONARY):
			print("ERROR: events file 'res://dialogue/events/" + String(scene_name) + "_events.json has errors'")
		
	else:
		print("Scene being tested is likely a test scene, no Level node")
		
func run_first_time_setup():
#	print("First time setup being run on dialogue_parser")
	game_singleton.get_node("scenechanger").connect("scene_just_changed", self, "run_scene_setup")
	
	panelNode = game_singleton.get_node("dialogue_box/Panel")
	if panelNode == null:
		print("Warning: dialogue panel node is null")
	else:
		if(panelNode.is_visible()):
			panelNode.hide()
	
	textContainer = game_singleton.get_node("dialogue_box/Panel/MarginContainer/VBoxContainer/text")
	if textContainer == null:
		print("Warning: dialogue text container is null")
		
	nameContainer = game_singleton.get_node("dialogue_box/Panel/MarginContainer/VBoxContainer/name")
	if nameContainer == null:
		print("Warning: dialogue name container is null")
		
	inventorymanager = game_singleton.get_node("inventorymanager")
	if inventorymanager == null:
		print("ERROR: No inventorymanager found by dialogueparser")
	pass
	

	
func _process(delta):
	if isActivated and (Input.is_action_just_pressed("action") || Input.is_action_just_pressed("x")):
		
		if isRunning:
#			print("dialogue_parser should change dialogue branch")
			change_dialogue_branch()
		pass
		
#func check_experience(experience):
#	if experiences.keys().has(experience):
#		return experiences[experience]
#
#func set_experience(experience, value):
#	if value != true && value != false:
#		print("ERROR: set_experience value must be true or false")
#		return
#	if experiences.keys().has(experience):
#		experiences[experience] = value
##		print("Experience *" + experience + "* set to " + String(experiences[experience]))
		
	

func activate(target):
	var target_is_valid = events["eventTarget"].has(target.name)
	
	if target_is_valid:
		currTarget = target
		isActivated = true
		start_dialogue()

		
	return isActivated

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
		end_dialogue()
	pass
	
func end_dialogue():
	emit_signal("dialogue_finished")
	panelNode.hide()
	isRunning = false
	isActivated = false
	
func start_dialogue():
	
	currDialogue = null
	currBranch = null
	
	isRunning = true
	
	var dialogue_branch = choose_dialogue_branch()
	var current_node = get_node("/root/Level/YSort/actors/" + currTarget.name)
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
	
	panelNode.show()
	nameContainer.set_text(currTarget.name)
	textContainer.set_text(currText)
	
	pass
	
func set_experiences_from_dialogue():
	
	
	
	
	var foundExperience = false
	var character
	
	if currBranch.keys().has("experiences"):
		if currBranch["experiences"].keys.has("character"):
			character = currBranch["experiences"]["character"]
		else:
			character = "player"
		
		for experience in currBranch["experiences"]:
			var result = gamedata.get_experience(character, experience)
			if result.begins_with("no_"):
				print("Warning: unable to find a valid experience in experiences file")
				pass
			else:
				foundExperience = true
				gamedata.set_experience(character, experience, result)
				print(character + "'s Experience *" + experience + "* set to " + String(gamedata.get_experience(character,experience)))
				
	if foundExperience == false:
#		print("Warning: No dialogue experience found.")
#		print("Remember: Starts are nonrepeating and are cancelled if a Unique plays first.")
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
		
		#Check every key to determine if all are true. If so, add to list to check usage priotiry.
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
			
			
#			elif key[0] == "
			
			elif "-" in key:
				
				var event_array = key.split("-")
				var person = event_array[0]
				var item = event_array[1]
#				print(item)
				var condition = event_array[2]
				var test_value = possibilities[option]["Flags"][key]
				var is_true = false
				var is_negated = false 
				
				if condition[0] == "!":
					is_negated = true
				
				var actual_value = gamedata.get_experience(person, item)
#				var actual_value = experiences[person][item]
				
				match condition.trim_prefix("!"):
					"<":
						if actual_value < test_value:
							is_true = true
					">":
						if actual_value > test_value:
							is_true = true

					"<=": 
						if actual_value <= test_value:
							is_true = true
					">=":
						if actual_value >= test_value:
							is_true = true
					"=":
						if actual_value == test_value:
							is_true = true
					
				if is_negated:
					is_true = !is_true
					
				if is_true == false:
					allTrue = false
				
				
#				print(person + "'s " + item + " " + condition + " " + String(test_value) + ": " + String(is_true))
#				print("the actual value is " + String(actual_value))
				
				
				pass
			
			
			
			
			
			#I think that now that everything is done with specific characters, the below is taken care of by 
			#The character-finding system above. Perhaps not though.
#			elif experiences.has(key):
#				if experiences[key] != possibilities[option]["Flags"][key]:
#					allTrue = false
#			elif !experiences.has(key):
#				print("Experience needs to be created/reconciled: " + key)
			else:
				print("Problem finding experience: " + key)
				
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
	


		
