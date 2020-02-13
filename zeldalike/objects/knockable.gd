extends Position2D

export var works_with_sword = true
export var works_with_bow = true
export var works_with_speech = false
onready var hitbox = $hitbox
var knockdir
var hitbynames = []
var was_hit = false
var is_one_shot = true

func _ready():
	if works_with_sword:
		hitbynames.append("sword")
	if works_with_bow:
		hitbynames.append("arrow")
	if works_with_speech:
		hitbynames.append("speech_hit_area")
	
func _process(delta):
	knock_loop()
	
func knock_loop():
	if is_one_shot && was_hit:
		pass
	else:
		for area in $hitbox.get_overlapping_areas():
			var body = area.get_parent()
			if !hitbynames.empty() && hitbynames.has(body.name):
				was_hit = true
				knockdir = global_transform.origin - body.global_transform.origin
				get_knocked(body)
				
			
func get_knocked(knocked_by):
#	print("Was knocked by " + knocked_by.name)
#	print(knockdir)
	var sprite = $Sprite
	if sprite != null:
		sprite.frame = 1
	pass