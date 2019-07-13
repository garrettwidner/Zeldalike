extends Panel

var text = ""
func _ready():
	pass

func _on_Button_pressed():
	text = get_node("MarginContainer/VBoxContainer/HBoxContainer/TextEdit").get_text()
	get_node("MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Label").set_text(text)
	pass