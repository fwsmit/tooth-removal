extends Panel

@export var sidebar: HBoxContainer

func _on_gui_input(event):
	print("input")
	if event is InputEventMouseButton:
		if event.is_pressed() and event.get_button_index() == 1:
			if sidebar.custom_minimum_size.x == 56:
				sidebar.custom_minimum_size.x = 100
			else:
				sidebar.custom_minimum_size.x = 56
