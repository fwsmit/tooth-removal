extends Button

# Called when the node enters the scene tree for the first time.
func _pressed():
	if Global.is_pre_extraction_data_valid():
		Global.goto_scene("res://scenes/extraction.tscn")
	else:
		OS.alert("Please select the quadrant, tooth and type")
		
