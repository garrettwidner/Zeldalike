extends KinematicBody2D

const TYPE : String = "ENEMY"
var speed : int = 0

var knodkdir : Vector2 = Vector2(0,0)

var facedir : Vector2 = dir.DOWN
var movedir : Vector2 = dir.CENTER
var spritedir : String = "down"

var hitstun = 0

func set_facingdir():
	if movedir.x == 0 and movedir.y == 0:
		facedir = dir.CENTER
	elif movedir.x == 1:
		facedir = dir.RIGHT
	elif movedir.x == -1:
		facedir = dir.LEFT
	elif movedir.y == 1:
		facedir = dir.DOWN
	elif movedir.y == -1: 
		facedir = dir.UP

func set_spritedir():
	match facedir:
		dir.UP:
			spritedir = "up"
		dir.DOWN:
			spritedir = "down"
		dir.LEFT:
			spritedir = "left"
		dir.RIGHT:
			spritedir = "right"

func switch_anim(animation):
	var nextanim : String = animation + spritedir
	if $anim.current_animation != nextanim:
		$anim.play(nextanim)

func movement_loop():
	var motion = movedir.normalized() * speed
	move_and_slide(motion, Vector2(0,0))