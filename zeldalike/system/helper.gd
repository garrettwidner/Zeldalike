extends Node

func string_strip(string):
	return string.rstrip("@1234567890").lstrip("@1234567890")
	
func nodepath_to_usable_string_path(generalPath, relativeNodePath):
	return String(generalPath) + String(relativeNodePath).lstrip("..")
	

#old version; seems to only work outside of builds?
#func load_file_as_JSON(file_path):
#	var file = File.new()
##	assert file.file_exists(file_path)
#	file.open(file_path, file.READ)
#	var filejson = JSON.parse(file.get_as_text())
#	file.close()
#	if filejson.error == 0:
#		return filejson.result # as Dictionary
#	print("LARGE ERROR: Returning json file as an empty string- this is wrong.")
#	return ""
		
func load_file_as_JSON(file_path):
	var file = File.new()
	file.open(file_path, file.READ)
	var text = file.get_as_text()
	var result_json = JSON.parse(text)
	
	if result_json.error != OK:
		print("[load_json_file] Error loading JSON file '" + str(file_path) + "'.")
		print("\tError: ", result_json.error)
		print("\tError Line: ", result_json.error_line)
		print("\tError String: ", result_json.error_string)
		return null
	
	return result_json.result
		
func save_file_as_JSON(file_path, dict_to_save):
	var file = File.new()
	assert file.file_exists(file_path)
	
	file.open(file_path, file.WRITE)
	
#	file.store_line(dict_to_save.to_json())
	file.store_line(JSON.print(dict_to_save, "\t"))
	file.close()
	pass