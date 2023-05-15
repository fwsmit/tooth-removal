@tool
extends EditorScript

const data_user = preload("res://scripts/Extraction/Sensor/data_user.gd")
var loc = data_user.new()
var no_quadrants = 4
var no_teeth = 8


# Called when the node enters the scene tree for the first time.
func _ready():
	for i1 in range(no_quadrants):
		var k = i1 + 1
		for i2 in range(no_teeth):
			var t = i2 + 1
			create_ball(loc.tand_locatie(k, t))
	print('check')
	
func _run():
	_ready()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func create_ball(position):
	var ball_instance = CSGSphere3D.new()
	ball_instance.set_radius(0.0055)	
	ball_instance.transform.origin = position
	add_child(ball_instance)
