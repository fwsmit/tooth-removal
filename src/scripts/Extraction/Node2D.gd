extends Node2D

signal data
# Called when the node enters the scene tree for the first time.
	
func _ready():
	rotation = 0
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	print(rotation)
	print(len(Global.corrected_torques))
	if len(Global.corrected_torques) > 0:
		rotation = Global.corrected_torques[-1].x
	print(Global.corrected_torques)
