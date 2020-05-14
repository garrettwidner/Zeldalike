extends Node2D

var inv_matrix = []
const inv_matrix_width = 6
const inv_matrix_height = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	create_inv_matrix()
	pass
	
func create_inv_matrix():
	for x in range(inv_matrix_width - 1):
			inv_matrix.append([])
			inv_matrix[x] = []
			for y in range(inv_matrix_height - 1):
				inv_matrix[x].append([])
				inv_matrix[x][y] = 0

func _process(delta):
	if Input.is_action_just_pressed("action"):
		print("Attempt: Matrix[0][1] set to 3")
		inv_matrix[0][1] = 3
		print("Matrix[0][1] is " + String(inv_matrix[0][1]))