extends Node
# Loads scene when button is pressed

@export var sceneName : String
@export var newMode : Global.MODE = Global.MODE.nochange

func get_scene_path():
	return "res://scenes/" + sceneName

func _ready():
	assert(FileAccess.file_exists(get_scene_path()))

func _pressed():
	if newMode != Global.MODE.nochange:
		Global.mode = newMode

	Global.goto_scene(get_scene_path())
