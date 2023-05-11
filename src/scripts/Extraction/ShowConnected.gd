extends MarginContainer

@export var connectedSprite: Sprite2D
@export var disconnectedSprite: Sprite2D

func showConnected():
	connectedSprite.visible = true
	disconnectedSprite.visible = false
	
func showDisconnected():
	connectedSprite.visible = false
	disconnectedSprite.visible = true

func _on_csg_box_3d_connected():
	pass # Replace with function body.


func _on_csg_mesh_3d_connected():
	pass # Replace with function body.
