extends Button

@export var forceps_slipped_checkbox : CheckBox 
@export var element_fractured_checkbox : CheckBox 
@export var expoxy_failed_checkbox : CheckBox
@export var post_extraction_notes_field : TextEdit 

func generate_filename(timestamp: int):
	return Time.get_datetime_string_from_unix_time(timestamp)

func flatten_vector(vecs):
	var xs = []
	var ys = []
	var zs = []

	for v in vecs:
		xs.append(v.x)
		ys.append(v.y)
		zs.append(v.z)

	return [xs, ys, zs]

func save_extraction_to_file():
	var filename = generate_filename(Global.startTimestamp)
	var fl_raw_forces = flatten_vector(Global.raw_forces)
	var fl_raw_torques = flatten_vector(Global.raw_torques)
	var fl_corrected_forces = flatten_vector(Global.corrected_forces)
	var fl_corrected_torques = flatten_vector(Global.corrected_torques)
	var extraction_data = {
		"quadrant": Global.selectedQuadrant,
		"tooth": Global.selectedTooth,
		"jaw_type": Global.selectedType,
		"forceps_slipped": Global.forceps_slipped,
		"element_fractured": Global.element_fractured,
		"epoxy_failed": Global.epoxy_failed,
		"post_extraction_notes": Global.post_extraction_notes,
		"person_type": Global.loggedInAs,
		"start_timestamp": Global.startTimestamp,
		"end_timestamp": Global.endTimestamp,

		# Force data (kept for compatibility)
		"raw_forces": Global.raw_forces,
		"raw_torques": Global.raw_torques,
		"corrected_forces": Global.corrected_forces,
		"corrected_torques": Global.corrected_torques,

		# Force data split by axis
		"corrected_forces_x": fl_corrected_forces[0],
		"corrected_forces_y": fl_corrected_forces[1],
		"corrected_forces_z": fl_corrected_forces[2],
		"corrected_torques_x": fl_corrected_torques[0],
		"corrected_torques_y": fl_corrected_torques[1],
		"corrected_torques_z": fl_corrected_torques[2],
		"raw_forces_x": fl_raw_forces[0],
		"raw_forces_y": fl_raw_forces[1],
		"raw_forces_z": fl_raw_forces[2],
		"raw_torques_x": fl_raw_torques[0],
		"raw_torques_y": fl_raw_torques[1],
		"raw_torques_z": fl_raw_torques[2],
	}
	var json_data = JSON.stringify(extraction_data, "\t")
	
	# Stores file in user data directory 
	# see https://docs.godotengine.org/en/latest/tutorials/io/data_paths.html#doc-data-paths
	var save_file = FileAccess.open("user://extraction_data_"+filename+".json", FileAccess.WRITE)
	save_file.store_line(json_data)

# Called when the node enters the scene tree for the first time.
func _pressed():
	Global.forceps_slipped = forceps_slipped_checkbox.button_pressed
	Global.element_fractured = element_fractured_checkbox.button_pressed
	Global.epoxy_failed = expoxy_failed_checkbox.button_pressed
	Global.post_extraction_notes = post_extraction_notes_field.text
	save_extraction_to_file()
	Global.reset_extraction_data()
	Global.goto_scene("res://scenes/dashboard.tscn")
