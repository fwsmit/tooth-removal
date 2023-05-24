extends Node

const data_user = preload("res://scripts/Extraction/Sensor/data_user.gd")
const Post_extraction_continue = preload("res://scripts/Post-extraction/Post-extraction-continue.gd")

var filing = Post_extraction_continue.new()
var frame = data_user.new()
var directory_path = "E:/Extraction data/kaakchirurgen 17-5/Kaakchirurg 4"
var files = get_files_at(directory_path)
# Called when the node enters the scene tree for the first time.



func _ready():
	var i = 0
	for file_name in files:
		process_data(directory_path+'/'+file_name)
		filing.save_extraction_to_file()
		Global.reset_extraction_data()
		i += 1
		print(i, directory_path+'/'+file_name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func get_files_at(path: String):
	var dir = DirAccess.open(path)
	var files: Array = []
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				files.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return files


func load_json_file(filePath: String):
	if FileAccess.file_exists(filePath):
		
		var dataFile = FileAccess.open(filePath, FileAccess.READ)
		var parsed = JSON.parse_string(dataFile.get_as_text())
		
		if parsed is Dictionary:
			return parsed
		else:
			print('error reading file')
	else:
		print('file doesnt exist')


func get_raw_data(filePath: String, f_tq_q_tt: String):
	if FileAccess.file_exists(filePath):
		
		var dataFile = load_json_file(filePath)
		
		Global.selectedQuadrant = dataFile["quadrant"]
		Global.selectedTooth = dataFile["tooth"]
		Global.selectedType = dataFile["jaw_type"]
		Global.forceps_slipped = dataFile["forceps_slipped"]
		Global.element_fractured = dataFile["element_fractured"]
#		Global.epoxy_failed = dataFile["epoxy_failed"]
#		Global.non_representative = dataFile["nonrepresentative"]
		Global.post_extraction_notes = dataFile["post_extraction_notes"]
		Global.loggedInAs = dataFile["person_type"]
		Global.startTimestamp = dataFile["start_timestamp"]
		Global.endTimestamp = dataFile["end_timestamp"]
		
#		var raw_forces = dataFile["raw_forces"]
#		var raw_torques = dataFile["raw_torques"]
		var raw_forces = [dataFile["raw_forces_x"], dataFile["raw_forces_y"], dataFile["raw_forces_z"]] 
		var raw_torques = [dataFile["raw_torques_x"], dataFile["raw_torques_y"], dataFile["raw_torques_z"]] 
		var force_vector_list = []
		var torque_vector_list = []
		
		for i in range(len(dataFile["raw_forces_x"])):
			force_vector_list.append(Vector3(raw_forces[0][i], raw_forces[1][i], raw_forces[2][i]))
			torque_vector_list.append(Vector3(raw_torques[0][i], raw_torques[1][i], raw_torques[2][i]))
		
#		for v in raw_forces:
#			v = v.replace("(", "").replace(")", "")
#			var v_str_list = v.split(", ")
#			var v_float_list = []
#			for item in v_str_list:
#				v_float_list.append(float(item))
#			force_list.append(Vector3(v_float_list[0], v_float_list[1], v_float_list[2]))
#
#		for v in raw_torques:
#			v = v.replace("(", "").replace(")", "")
#			var v_str_list = v.split(", ")
#			var v_float_list = []
#			for item in v_str_list:
#				v_float_list.append(float(item))
#			torque_list.append(Vector3(v_float_list[0], v_float_list[1], v_float_list[2]))
		
		if f_tq_q_tt == "f":
			return force_vector_list
		
		if f_tq_q_tt == "tq":
			return torque_vector_list
		
		if f_tq_q_tt == "q":
			return dataFile["quadrant"]
		
		if f_tq_q_tt== "tt":
			return dataFile["tooth"]
		
		else:
			print('please input either f, tq, q or tt. For respectively force, torque, quadrant, tooth')
	
	else:
		print('file doesnt exist')

	
func process_data(filePath: String):
	if FileAccess.file_exists(filePath):
		
		var kwadrant = get_raw_data(filePath, "q")
		var tand = get_raw_data(filePath, "tt")
		var forces = get_raw_data(filePath, "f")
		var torques = get_raw_data(filePath, "tq")
		var location = frame.tand_locatie(kwadrant, tand) 
		
		Global.raw_forces = forces
		Global.raw_torques = torques
		
		for i in range(len(torques)):
			torques[i] = frame.convert_torque(torques[i], forces[i], location)
			torques[i] = frame.vector_tand_frame(kwadrant, tand, torques[i])
		
		for i in range(len(forces)):
			forces[i] = frame.vector_tand_frame(kwadrant, tand, forces[i])
		
		for i in range(len(forces)):
			var dir = frame.type_force_torque(kwadrant, tand, forces[i], torques[i])
			for key in dir[0].keys():
				Global.clinical_directions[0][key].append(dir[0][key])
		
			for key in dir[1].keys():
				Global.clinical_directions[1][key].append(dir[1][key])
	

	else:
		print('file doesnt exist')
