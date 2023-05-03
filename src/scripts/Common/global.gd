extends Node

var current_scene = null

# Data requested before extraction
var loggedInAs = "Unknown"
var selectedQuadrant = null
var selectedTooth = null
var selectedType = null

# Data stored during extraction
var raw_forces = []
var raw_torques = []
var corrected_forces = []
var corrected_torques = []
var clinical_directions = null
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
	startTimestamp = -1 # start of extraction
	endTimestamp = -1 # end of extraction
	selectedQuadrant = null
	selectedTooth = null
	selectedType = null
	forceps_slipped = null
	element_fractured = null
	epoxy_failed = null
	post_extraction_notes = null
	non_representative = null

func is_pre_extraction_data_valid():
	return selectedQuadrant != null and \
		selectedTooth != null and \
		selectedType != null
