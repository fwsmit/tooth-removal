extends Panel

#@export var SidebarPath : NodePath

@export var sidebar: HBoxContainer

# Called when the node enters the scene tree for the first time.
#func _ready():
#	sidebar = get_node(SidebarPath)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_gui_input(event):
	print("input")
	if event is InputEventMouseButton:
		if event.is_pressed() and event.get_button_index() == 1:
			if sidebar.custom_minimum_size.x == 56:
				sidebar.custom_minimum_size.x = 100
			else:
				sidebar.custom_minimum_size.x = 56


func _on_csg_mesh_3d_disconnected():
	pass # Replace with function body.
