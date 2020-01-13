extends "res://engine/entity.gd"


var runspeed = 37
var walkspeed = 37
var berries = 0
var berrycounter
var berryshadow

var cakes = 0
var cakecounter
var cakeshadow

var canmove = true

var is_running = false
func _ready():
	TYPE = "PLAYER"
	knock_strength = 5
	berrycounter = get_node("/root/Level/UI/CanvasLayer/Control/RichTextLabel")
	berryshadow = get_node("/root/Level/UI/CanvasLayer/Control/RichTextLabel2")
	cakecounter = get_node("/root/Level/UI/CanvasLayer/Control/RichTextLabel3")
	cakeshadow = get_node("/root/Level/UI/CanvasLayer/Control/RichTextLabel4")
	
	update_cake_counters()
	update_berry_counters()
	
	connect("health_changed", self, "play_ooh")
	
	speed = runspeed
	is_running = true
	$anim.playback_speed = 1.5

func _process(delta):
	
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
	
	if canmove:
		set_speed()
	
		set_movedir()
		set_facedir()
		set_spritedir()
		damage_loop()
		
		if movedir != Vector2(0,0):
			switch_anim("walk")
		else:
			switch_anim("idle")
			
	
			
		
			
			
	#	elif Input.is_action_just_pressed("x"):
	##		print("Pressed wind talk button")
	#		if caninteract:
	##			print("Should be interacting with " + interacttarget.name + "!")
	#			var is_valid_target = dialogueparser.activate(interacttarget, true)
	#			if is_valid_target:
	##				print("Set state to listen")
	#				set_state_listen()
	##		staticdir = spritedir
	##		use_item(preload("res://items/shield/shield.tscn"))
	#		pass
		
		
		movement_loop()
	
	pass

func play_ooh(health, damage):
	$ooh_player.play()

func set_movedir():
	var LEFT : bool = Input.is_action_pressed("left")
	var RIGHT : bool = Input.is_action_pressed("right")
	var UP : bool = Input.is_action_pressed("up")
	var DOWN : bool = Input.is_action_pressed("down")
	
	if LEFT:
		movedir.x = -1
	elif RIGHT:
		movedir.x = 1
	else:
		movedir.x = 0
	
	if UP:
		movedir.y = -1
	elif DOWN:
		movedir.y = 1
	else:
		movedir.y = 0

func set_speed():
	pass
#	if Input.is_action_pressed("b"):
#		speed = runspeed
#		is_running = true
#		$anim.playback_speed = 1.5
#	else:
#		speed = walkspeed
#		is_running = false
#		$anim.playback_speed = 1
		
func berry_collected():
	berries = berries + 1
	$aha_player.play()
	update_berry_counters()
	
func update_berry_counters():
	berrycounter.text = String(berries)
	berryshadow.text = String(berries)
	
func drain_berries():
	berries = 0
	update_berry_counters()
	
func cake_collected():
	cakes = 1
	$aha_happy_player.play()
	update_cake_counters()
	
func update_cake_counters():
	cakecounter.text = String(cakes)
	cakeshadow.text = String(cakes)

func freeze():
	canmove = false
	movedir = dir.UP
	switch_anim("idle")
	

	
func unfreeze():
	canmove = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
