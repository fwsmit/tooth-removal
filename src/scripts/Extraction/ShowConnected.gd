extends MarginContainer

@export var connectedSprite: Sprite2D
@export var disconnectedSprite: Sprite2D

func showConnected():
	connectedSprite.visible = true
	disconnectedSprite.visible = false
	
func showDisconnected():
	connectedSprite.visible = false
	disconnectedSprite.visible = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_csg_box_3d_connected():
	pass # Replace with function body.
