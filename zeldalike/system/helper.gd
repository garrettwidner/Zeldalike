extends Node

func string_strip(string):
	return string.rstrip("@1234567890").lstrip("@1234567890")
	
	
#Make it so that this pulls from the master, but that subsequent saves save to the general file 
func load_file_as_JSON(file_path):
	var file = File.new()
#	assert file.file_exists(file_path)
	
	var edited_path = file_path.replace(".json", "")
	edited_path = edited_path + "_master.json"
#	assert file.file_exists(edited_path)
	file.open(edited_path, file.READ)
	
	
	var filejson = JSON.parse(file.get_as_text())
	if filejson.error == 0:
		return filejson.result as Dictionary
	else:
#		print("Error in parsing JSON File")
		file.close()
		file = File.new()
		file.open(file_path, file.READ)
		filejson = JSON.parse(file.get_as_text())
		file.close()
		
		if filejson.error == 0:
			return filejson.result as Dictionary
		return ""
		
		
		
func save_file_as_JSON(file_path, dict_to_save):
	var file = File.new()
	assert file.file_exists(file_path)
	
	file.open(file_path, file.WRITE)
	
#	file.store_line(dict_to_save.to_json())
	file.store_line(JSON.print(dict_to_save))
	file.close()
	pass