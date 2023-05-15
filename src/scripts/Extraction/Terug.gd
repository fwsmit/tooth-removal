extends Button


func _pressed():
	Global.reset_extraction_data()
	Global.goto_scene("res://scenes/pre-extraction.tscn")
