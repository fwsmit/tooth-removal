extends "res://scripts/Common/SceneLoader.gd"

@export var backButton : Button
@export var continueButton : Button

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	if Global.fromExtraction:
		backButton.visible = false
	else:
		continueButton.visible = false
