extends SceneTree

const Global = preload("res://scripts/Common/global.gd")
const ft = preload("res://scripts/Extraction/Sensor/ft_translation.gd")

func test_data_user():
	var loc = Vector3(0,9,-80)
	var force = Vector3(1, 1, 100)
	var torque = loc.cross(force)
	torque = ft.convert_torque(torque, force, loc)
	
	# Make sure torque translation works
	assert(torque == Vector3.ZERO)

func _init():
	test_data_user()
	quit()
