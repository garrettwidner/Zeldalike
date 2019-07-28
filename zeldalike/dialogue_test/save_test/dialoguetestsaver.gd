extends Node

func _ready():
	pass
	
	
func _process(delta):
	if Input.is_action_just_pressed("a"):
		#Open a previously created file and read its content as a dictionary
		var old_file = File.new()
		old_file.open("res://dialogue_test/save_test/testdict.json", File.READ)
		var old_content = JSON.parse(old_file.get_as_text())
		print("attempting to print old_content")
		print(old_content.result)
		
		var new_file = File.new()
		new_file.open("res://dialogue_test/save_test/testdictnew.json", File.WRITE)
		
		#Manually store each key/value pair into the newly created blank file
		var counter = 0
		new_file.store_line("{")
		for key in old_content.result.keys():
			counter = counter + 1
			if counter != old_content.result.size():
				new_file.store_line("\"" + key + "\" : \"" + old_content.result[key] + "\" ,")
			else:
				new_file.store_line("\"" + key + "\" : \"" + old_content.result[key] + "\"")
				
		new_file.store_line("}")
		
		#NOTE: MUST specifically open each file to reading or writing
		new_file.close()
		new_file.open("res://dialogue_test/save_test/testdictnew.json", File.READ)
		
		#Get text contents of newly populated file as a String
		var new_content = new_file.get_as_text()
		print(new_content)
		
		#Take string and parse it into a dictionary
		var new_content_dict = JSON.parse(new_content)
		print(new_content_dict.result)

		#Attempt to read newly parsed file as a dictionary
		for key in new_content_dict.result.keys():
			print("key: " + key + " value: " + new_content_dict.result[key])

		#Close both files to reading and writing
		new_file.close()
		old_file.close()
		
	pass
	