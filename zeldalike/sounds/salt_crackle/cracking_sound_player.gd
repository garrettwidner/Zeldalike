extends Node2D

export(float) var min_time
export(float) var max_time
export(Array, AudioStreamSample) var cracksounds = []
var soundcount : int

func _ready():
	soundcount = cracksounds.size()
	set_timer_rand()
#	print("Found " + String(soundcount) + " crack sounds")

func play_rand_sound():
	var rand_sound_index = floor(rand_range(0, soundcount -1))
	$audioplayer.stream = cracksounds[rand_sound_index]
	$audioplayer.play()
	pass
	
func set_timer_rand():
	$Timer.wait_time = rand_range(min_time,max_time)
	$Timer.start()
	pass

func _on_Timer_timeout():
	play_rand_sound()
	set_timer_rand()
