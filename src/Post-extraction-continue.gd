extends Button

@export var forceps_slipped_checkbox : CheckBox 
@export var element_fractured_checkbox : CheckBox 
@export var post_extraction_notes_field : TextEdit 

func generate_filename(timestamp: int):
	return Time.get_datetime_string_from_unix_time(timestamp)

func save_extraction_to_file():
	var timestamp = int(Time.get_unix_time_from_system())
	var filename = generate_filename(timestamp)
	var extraction_data = {
		"quadrant": Global.selectedQuadrant,
		"tooth": Global.selectedTooth,
		"type": Global.selectedType,
		"forceps_slipped": Global.forceps_slipped,
		"element_fractured": Global.element_fractured,
		"post_extraction_notes": Global.post_extraction_notes,
		"unix_timestamp": timestamp,
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
	Global.post_extraction_notes = post_extraction_notes_field.text
	save_extraction_to_file()
	Global.goto_scene("res://dashboard.tscn")
