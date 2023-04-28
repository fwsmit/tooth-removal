extends Button

func _pressed():
	Global.endTimestamp = Time.get_unix_time_from_system()
	Global.goto_scene("res://scenes/post-extraction.tscn")
