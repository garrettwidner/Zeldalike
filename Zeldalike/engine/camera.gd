extends Camera2D

func _ready():
	$area.connect("body_entered", self, "body_entered")
	$area.connect("body_exited", self, "body_exited")
	$area.connect("area_exited", self, "area_exited")

func _process(delta):
	#goes up one level and looks for a node called player
	var pos = get_node("../player").global_position - Vector2(0,16)
	#finds player's position on a grid, with each screen size being a single grid point.
	#so (1,2) would be right 1, down 2 screens
	var x = floor(pos.x / 160) * 160
	var y = floor(pos.y / 128) * 128
	global_position = Vector2(x,y)
	
func body_entered(body):
	if body.get("TYPE") == "ENEMY":
		body.set_physics_process(true)
		
func body_exited(body):
	if body.get("TYPE") == "ENEMY":
		body.set_physics_process(false)

func area_exited(area):
	if area.get("disappears") == true:
		area.queue_free()
	