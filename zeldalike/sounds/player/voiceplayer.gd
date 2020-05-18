extends AudioStreamPlayer2D

export(Array, AudioStreamSample) var ohs = []
var soundcount : int
var player

func _ready():
	soundcount = ohs.size()
	player = get_node("../../player")
	player.connect("on_spoke", self, "play_rand_oh")

func play_rand_oh():
	var rand_oh_index = floor(rand_range(0, soundcount))
	stream = ohs[rand_oh_index]
	play()
	pass
	