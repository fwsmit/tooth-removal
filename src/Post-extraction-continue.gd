extends Button

func save_extraction_to_file(filename):
	var extraction_data = {
		"quadrant": Global.selectedQuadrant,
		"tooth": Global.selectedTooth,
		"type": Global.selectedType,
	}
	print(JSON.stringify(extraction_data, "\t"))

# Called when the node enters the scene tree for the first time.
func _pressed():
	save_extraction_to_file("test.json")
	Global.goto_scene("res://dashboard.tscn")
