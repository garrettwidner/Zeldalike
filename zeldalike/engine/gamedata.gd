extends Node2D

var experiences

func _ready():
	load_experiences_from_disk()
	pass
	
#To be called initially on game load
func load_experiences_from_disk():
	experiences = helper.load_file_as_JSON("res://dialogue/data/experiences.json")
	if(typeof(experiences) != TYPE_DICTIONARY):
			print("ERROR: experiences file has errors")

func set_experience(character,experience,new_value):
	if experiences.keys().has(character):
		if experiences[character].keys().has(experience):
			experiences[character][experience] = new_value
		else:
			print("Error: in experiences file, " + character + " has no '" + experience + "' experience.")
	else:
		print("ERROR: experiences file has no '" + character + "' character.")
#		print("Experience *" + experience + "* set to " + String(experiences[experience]))
	pass
	
func get_experience(character,experience):
	if experiences.keys().has(character):
		if experiences[character].keys().has(experience):
			return experiences[character][experience]
		else:
			print("Error: no such experience found.")
			print("Remember: Starts are nonrepeating and are cancelled if a Unique plays first.")
			return "no_such_experience"
	else:
		print("Error: no such character found in experiences file")
		return "no_such_character"
	pass
	
# To be called when game closes, and modified either for testing or final purposes.
func save_experiences_to_disk():
	#During testing, should save nothing
	
	#During final game, should save 'experiences' dictionary to json file on disk
	#helper.save_file_as_JSON("res://dialogue/data/experiences.json", experiences)
	
	
	pass