extends Node2D

var string_test_1 = "hello friends"
var string_test_2 = "dsjimbo_grapes"
var string_test_3 = "dsjameson_sausages"

func ready():
	pass
	
func _process(delta):
	
	
	
	if Input.is_action_just_pressed("sack"):
		test_json()
		pass
	pass
	
func find_hello_index():
	var helloIndex = string_test_1.find("hello")
	print(helloIndex)
	
func find_certain_characters(chars_to_find):
	var strings = [string_test_1, string_test_2, string_test_3]
	
	for string in strings:
		if string.begins_with(chars_to_find):
			var ds_stripped = string.trim_prefix(chars_to_find)
			var split = string.rsplit("_")
			print(split[0] + " has some " + split[1])
	pass
	
func test_json():
	
	
	var file_dict = {}
	file_dict = helper.load_file_as_JSON("res://dialogue/data/json_tester.json")
	
	if(typeof(file_dict) != TYPE_DICTIONARY):
			print("ERROR: dictionary test file has errors")
			return
	
	file_dict["test2"] = "horse"
	print("Under 'test1' in loaded file is " + file_dict["test1"])
	print("Under 'test2' in loaded file is " + file_dict["test2"])
	
	helper.save_file_as_JSON("res://dialogue/data/json_tester.json", file_dict)
	
	pass
