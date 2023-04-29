extends Node
# Loads scene when button is pressed

@export var sceneName : String

func get_scene_path():
	return "res://scenes/" + sceneName

func _ready():
	assert(FileAccess.file_exists(get_scene_path()))

func _pressed():
	Global.goto_scene(get_scene_path())
