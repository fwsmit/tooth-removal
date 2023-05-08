extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.selectedFile != null:
		text = Global.selectedFile
	else:
		text = "No file selected"
