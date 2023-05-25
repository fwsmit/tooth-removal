extends SceneTree

const Global = preload("res://scripts/Common/global.gd")
const ft = preload("res://scripts/Extraction/Sensor/ft_translation.gd")

func test_data_user():
	var locs_f = [Vector3(0,9,-80), Vector3(0,0,1), Vector3(1,2,4)]
	var locs_t = [Vector3(0,9,-80), Vector3(0,0,0), Vector3(1,2,3)]
	var forces = [Vector3(1, 1, 100), Vector3(1,0,0), Vector3(1,0,0)]
	var exp_torques = [Vector3.ZERO, Vector3(0,1,0), Vector3(0,1,0)]
	
	for i in range(len(locs_f)):
		var torque = locs_f[i].cross(forces[i])
		torque = ft.convert_torque(torque, forces[i], locs_t[i])
		print(torque)
		# Make sure torque translation works
		assert(torque == exp_torques[i])

func _init():
	test_data_user()
	quit()
