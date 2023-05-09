extends Label

# keys:  
var extractionDict = null

func updateText():
	if extractionDict == null:
		text = "No information"
		return

	text = ""
	var duration = extractionDict["end_timestamp"]\
		- extractionDict["start_timestamp"]
	text += "Duration: " + str(round(duration)) + " seconds\n"
	text += "Quadrant: " + str(extractionDict["quadrant"]) + "\n"
	text += "Tooth: " + str(extractionDict["tooth"]) + "\n"
	text += "Type: " + str(extractionDict["jaw_type"]) + "\n"
	text += "Date: " + Time.get_date_string_from_unix_time(extractionDict["start_timestamp"])\
		+ " " + Time.get_time_string_from_unix_time(extractionDict["start_timestamp"]) + "\n"
	
	var forceps_slipped = extractionDict["forceps_slipped"]
	var element_fractured = extractionDict["element_fractured"]
	var epoxy_failed = false
	if extractionDict.has("epoxy_failed"):
		epoxy_failed = extractionDict["epoxy_failed"]
	var notes = extractionDict["post_extraction_notes"]
	
	if forceps_slipped or element_fractured or epoxy_failed:
		text += "\nComplications\n"
	
	if forceps_slipped:
		text += "Forceps slipped\n"
	
	if element_fractured:
		text += "Element fractured\n"
	
	if epoxy_failed:
		text += "Epoxy failed\n"
	
	if notes != "":
		text += "\nNotes: " + notes + "\n"
	
	

func getExtractionDict():
	if Global.selectedFile == null:
		return null
	
	var file = FileAccess.open("user://"+Global.selectedFile, FileAccess.READ)
	return JSON.parse_string(file.get_as_text())

# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.extractionDict == null:
		extractionDict = getExtractionDict()
	else:
		extractionDict = Global.extractionDict
	updateText()
