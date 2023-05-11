extends Button

@export var forceps_slipped_checkbox : CheckBox 
@export var element_fractured_checkbox : CheckBox 
@export var expoxy_failed_checkbox : CheckBox
@export var non_representative_checkbox : CheckBox
@export var post_extraction_notes_field : TextEdit 

func generate_filename(timestamp: int):
	var filename = Time.get_datetime_string_from_unix_time(timestamp)
	var i = 0
	for c in filename:
		if c == ':':
			filename[i] = ';'
		i += 1
	return filename

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
	var extraction_data = {
		"quadrant": Global.selectedQuadrant,
		"tooth": Global.selectedTooth,
		"jaw_type": Global.selectedType,
		"forceps_slipped": Global.forceps_slipped,
		"element_fractured": Global.element_fractured,
		"epoxy_failed": Global.epoxy_failed,
		"nonrepresentative": Global.non_representative,
		"post_extraction_notes": Global.post_extraction_notes,
		"person_type": Global.loggedInAs,
		"start_timestamp": Global.startTimestamp,
		"end_timestamp": Global.endTimestamp,
		"format_version": 2, # version of the data format

		# Force data split by axis
		"raw_forces_x": fl_raw_forces[0],
		"raw_forces_y": fl_raw_forces[1],
		"raw_forces_z": fl_raw_forces[2],
		"raw_torques_x": fl_raw_torques[0],
		"raw_torques_y": fl_raw_torques[1],
		"raw_torques_z": fl_raw_torques[2],
		
	}
	
	var directions = {
	"buccal/lingual": Global.clinical_directions[0]['buccal/lingual'],
	"mesial/distal": Global.clinical_directions[0]['mesial/distal'],
	"extrusion/intrusion": Global.clinical_directions[0]['extrusion/intrusion'],
	"mesial/distal angulation": Global.clinical_directions[1]['mesial/distal angulation'],
	"bucco/linguoversion": Global.clinical_directions[1]['bucco/linguoversion'],
	"mesiobuccal/lingual": Global.clinical_directions[1]['mesiobuccal/lingual'],
	}
	extraction_data.merge(directions)
	Global.extractionDict = extraction_data
	var json_data = JSON.stringify(extraction_data, "\t")
	
	# Stores file in user data directory 
	# see https://docs.godotengine.org/en/latest/tutorials/io/data_paths.html#doc-data-paths
	var filepath = "user://extraction_data_"+filename+".json"
	var save_file = FileAccess.open(filepath, FileAccess.WRITE)
	save_file.store_line(json_data)
	return filename + ".json"

# Called when the node enters the scene tree for the first time.
func _pressed():
	Global.forceps_slipped = forceps_slipped_checkbox.button_pressed
	Global.element_fractured = element_fractured_checkbox.button_pressed
	Global.epoxy_failed = expoxy_failed_checkbox.button_pressed
	Global.non_representative = non_representative_checkbox.button_pressed
	Global.post_extraction_notes = post_extraction_notes_field.text
	Global.fromExtraction = true

	# Do not store extraction data for demo user
	if Global.loggedInAs != "Demo":
		Global.selectedFile = save_extraction_to_file()

	print("Updating index")
	Global.update_index()
	Global.reset_extraction_data()
	Global.goto_scene("res://scenes/show_extraction.tscn")
