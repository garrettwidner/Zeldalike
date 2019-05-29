extends KinematicBody2D

const TYPE : String = "ENEMY"
const SPEED : int = 0

var movedir : Vector2 = Vector2(0,0)
var knodkdir : Vector2 = Vector2(0,0)
var spritedir : String = "down"

var hitstun = 0
