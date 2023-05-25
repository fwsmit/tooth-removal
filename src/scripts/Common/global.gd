extends Node

var current_scene = null

enum MODE{
	nochange,
	extractionTrainer,
	extractionList,
	automaticExtraction,
	nomode,
}

var mode = MODE.nomode

# Data requested before extraction
var loggedInAs = "Unknown"
var selectedQuadrant = null
var selectedTooth = null
var selectedType = null

# Used in automatic selection
var selectedJaw = null
var automaticModeStarted = false # True if first tooth is already selected

# Data stored during extraction
var raw_forces = []
var raw_torques = []
var corrected_forces = []
var corrected_torques = []
var clinical_directions = [{'buccal/lingual': [], 'mesial/distal': [], 'extrusion/intrusion': []},\
	{'mesial/distal angulation': [], 'bucco/linguoversion': [], 'mesiobuccal/lingual': []}]
var startTimestamp = -1 # start of extraction
var endTimestamp = -1 # end of extraction

# Data requested after extraction
var forceps_slipped = null
var element_fractured = null
var epoxy_failed = null
var post_extraction_notes = null
var non_representative = null

# View extractions
var selectedFile = "extraction_data_2023-04-26T10:09:01.json"
var extractionDict = null
var fromExtraction = false

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

	call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path):
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instantiate()

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene

func reset_extraction_data():
	raw_forces = []
	raw_torques = []
	corrected_forces = []
	corrected_torques = []
	clinical_directions = [{'buccal/lingual': [], 'mesial/distal': [], 'extrusion/intrusion': []},\
	{'mesial/distal angulation': [], 'bucco/linguoversion': [], 'mesiobuccal/lingual': []}]
	startTimestamp = -1 # start of extraction
	endTimestamp = -1 # end of extraction
	
	# Don't reset the selected tooth in automatic extraction mode
	if mode != MODE.automaticExtraction:
		selectedTooth = null
		
	forceps_slipped = null
	element_fractured = null
	epoxy_failed = null
	post_extraction_notes = null
	non_representative = null

func is_pre_extraction_data_valid():
	return selectedQuadrant != null and \
		selectedTooth != null and \
		selectedType != null

func is_pre_automatic_extraction_data_valid():
	return selectedJaw != null and \
		selectedType != null

func get_avg_vector(n, vecs):
	var total = Vector3.ZERO
	if len(vecs) < n:
		return Vector3.ZERO

	for i in range(n):
		total += vecs[-(i+1)]
	return total/n

# Get average force vector over last n sample points
func get_avg_force(n):
	return get_avg_vector(n, corrected_forces)

func get_avg_torque(n):
	return get_avg_vector(n, corrected_torques)

func python_run(args):
	var output = []
	var exit_code = OS.execute("python", args, output, true)
	if exit_code != 0:
		printerr("Python command has failed")
		printerr(output[0])
	else:
		print(output[0])

func update_index():
	python_run(["../python/analysis/dataAnalysis.py", "--update_index"])

func show_graphs(filename):
	print("Showing graphs for: ", filename)
	python_run(["../python/analysis/dataAnalysis.py", filename, "--graph_force_torque"])
