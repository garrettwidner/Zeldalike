extends Control

const ICON_PATH = "res://UI/inventory/"

const ITEM_ICONS = {
	"sword": {
		"icon": ICON_PATH + "sword_icon.png",
		"equippable": true  
		},
	"bow": {
		"icon": ICON_PATH + "bow_icon.png",
		"equippable": true
		},
	"cover": {
		"icon": ICON_PATH + "cover_icon.png",
		"equippable": true
		},
	"error": {
		"icon": ICON_PATH + "error_icon.png",
		"equippable": true
		}
	}
	
func get_item(item_name):
	if item_name in ITEM_ICONS:
		return ITEM_ICONS[item_name]
	else:
		return ITEM_ICONS["error"]

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
