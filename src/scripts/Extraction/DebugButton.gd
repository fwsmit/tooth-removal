extends Button

@export var debugText : RichTextLabel 

# Called when the node enters the scene tree for the first time.
func _toggled(button_pressed_bool):
	if button_pressed_bool:
		text = "Debug ▲"
		debugText.visible = true
	else:
		text = "Debug ▶"
		debugText.visible = false
