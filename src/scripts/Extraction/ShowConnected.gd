extends Container

@export var connectedSprite: Sprite2D
@export var disconnectedSprite: Sprite2D

func showConnected():
	connectedSprite.visible = true
	disconnectedSprite.visible = false
	
func showDisconnected():
	connectedSprite.visible = false
	disconnectedSprite.visible = true
