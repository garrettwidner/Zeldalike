extends Node2D

var arr = []

func _ready():
	arr.resize(4)
	arr[0] = 1
	arr[1] = 2
	arr[2] = 3
	arr[3] = 4
	pass
	
func _process(delta):
	if Input.is_action_just_pressed("item1"):
		increment_array()
	if Input.is_action_just_pressed("item2"):
		print_array()
	pass
	
func increment_array():
	print("-incrementing array-")
	var first_holder
	var final_space = arr.size() - 1
	
	for i in range(0,arr.size()):
		if i == 0:
			first_holder = arr[i]
			arr[i] = arr[i+1]
		elif i == final_space:
			arr[i] = first_holder
			pass
		else:
			arr[i] = arr[i+1]
		pass
	pass
	
func print_array():
	print("-size: " + String(arr.size()) + "-")
	for i in arr:
		print(i)
	print("--")
	pass
