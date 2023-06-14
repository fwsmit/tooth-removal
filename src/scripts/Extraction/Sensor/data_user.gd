extends Node3D

#const HOST: String = "127.0.0.1"
const HOST: String = "192.168.0.100"
const PORT: int = 2001
const RECONNECT_TIMEOUT: float = 3.0

const Client = preload("res://scripts/Extraction/Sensor/client.gd")
var _client: Client = Client.new()

signal connected
signal disconnected
signal data
signal directions

@export var molar_3d : MeshInstance3D
@export var incisor_3d : MeshInstance3D
@export var canine_3d : MeshInstance3D
@export var premolar_3d : MeshInstance3D

# this function is called when scene tree is entered
func _ready() -> void:
	_client.connect("connected",Callable(self,"_handle_client_connected"))
	_client.connect("disconnected",Callable(self,"_handle_client_disconnected"))
	_client.connect("error",Callable(self,"_handle_client_error"))
	_client.connect("data",Callable(self,"_handle_client_data"))
	add_child(_client)
	_client.connect_to_host(HOST, PORT)
	Global.startTimestamp = Time.get_unix_time_from_system()

	var t = Global.selectedTooth
	molar_3d.visible = false
	if t == 1 or t == 2:
		incisor_3d.visible = true
	elif t == 3:
		incisor_3d.visible = true # Canine model is doing weird
	elif t == 4 or t == 5:
		molar_3d.visible = true # premolar model is doing weird
	elif t > 5:
		molar_3d.visible = true
		
	
func _connect_after_timeout(timeout: float) -> void:
	await get_tree().create_timer(timeout).timeout # Delay for timeout
	_client.connect_to_host(HOST, PORT)

func _handle_client_connected() -> void:
	emit_signal("connected")
	print("Client connected to server.")

# this function returns the torque at the tooth location, by taking the cross product
func convert_torque(torque, force, location):
	var result = torque - location.cross(force)
	return result
	
# this function returns a location vector for a given kwadrant and element number. The array tandvectors has 5 list entries, the first is a list of two vectors containinng a base vector
# for both the upper and lower jaw. The other four lists contain locations for each tooth in each kwadfrant to be added to the base vector. Change these vectors based on the measured tooth locations.
# a small correction vector is added as well
# format for tandvectors = [[upper,lower],[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8]]
func tand_locatie(kwadrant, tand):
	var tandvectors = [[Vector3(0.0395, 0.249, 0), Vector3(0.226, 0.0623, 0)],\
	[Vector3(0.0332, -0.00759, 0.00336),Vector3(0.0336, -0.0101, 0.011),Vector3(0.0344, -0.0133, 0.0189),Vector3(0.0321, -0.0225, 0.0193),Vector3(0.0321, -0.0295, 0.0232),Vector3(0.0311, -0.0371, 0.0241),Vector3(0.0308, -0.0481, 0.0253),Vector3(0.0299, -0.0583, 0.0258)],\
	[Vector3(0.0332, -0.00759, -0.00336),Vector3(0.0336, -0.0101, -0.011),Vector3(0.0344, -0.0133, -0.0189),Vector3(0.0321, -0.0225, -0.0193),Vector3(0.0321, -0.0295, -0.0232),Vector3(0.0311, -0.0371, -0.0241),Vector3(0.0308, -0.0481, -0.0253),Vector3(0.0299, -0.0583, -0.0258)],\
	[Vector3(-0.0131, 0.0261, -0.00207),Vector3(-0.0136, 0.0263, -0.00779),Vector3(-0.0164, 0.0264, -0.0135),Vector3(-0.0225, 0.0225, -0.0155),Vector3(-0.0291, 0.0237, -0.0189),Vector3(-0.0383, 0.0226, -0.0214),Vector3(-0.0494, 0.0225, -0.0211),Vector3(-0.0602, 0.0229, -0.0228)],\
	[Vector3(-0.0131, 0.0261, 0.00207),Vector3(-0.0136, 0.0263, 0.00779),Vector3(-0.0164, 0.0264, 0.0135),Vector3(-0.0225, 0.0225, 0.0155),Vector3(-0.0291, 0.0237, 0.0189),Vector3(-0.0383, 0.0226, 0.0214),Vector3(-0.0494, 0.0225, 0.0211),Vector3(-0.0602, 0.0229, 0.0228)]]
	var locatie = []
	if kwadrant == 1 or kwadrant == 2:
		locatie = tandvectors[0][0] + tandvectors[kwadrant][tand - 1] + Vector3(-0.002, -0.0025, 0)
	if kwadrant == 3 or kwadrant == 4:
		locatie = tandvectors[0][1] + tandvectors[kwadrant][tand - 1] + Vector3(-0.005, -0.002, 0)

	# Corrigeer voor sensor center of gravity
	locatie = locatie + Vector3(0, 18./1000., 0)
	return locatie

# this array contains 4 lists of angles. Each angle gives the relative rotation for the particular tooth-frame to the initial reference Frame as used by Godot. to be used in vector_tand_frame()
var angles = [[0., -19.4, -53., -57.5, -66.3, -79.7, -79.7, -95.6], [0., 19.4, 53., 57.5, 66.3, 79.7, 79.7, 95.6],[0 , -19.7, -39.2, -67., -78., -78., -78., -90.],[0 , 19.7, 39.15, 67., 78., 78., 78., 90.]]

# This function returns a given vector expressed in the tooth frame for a given kwadrand and tooth number.
func vector_tand_frame(kwadrant, tand, vector):
	var angle = deg_to_rad(angles[kwadrant - 1][tand - 1])
	if kwadrant == 1 or kwadrant == 2:
		vector = Vector3(vector.x, cos(angle)*vector.y - sin(angle)*vector.z, sin(angle)*vector.y + cos(angle)*vector.z)
	if kwadrant == 3 or kwadrant == 4:
		vector = Vector3(cos(angle)*vector.x + sin(angle)*vector.z,vector.y, -sin(angle)*vector.x + cos(angle)*vector.z)
	return vector

# this function is the opposite to the previous function. it returns a vector expressed in the initial frame of refence. Translating it back from the tooth frame for a given tooth and kwadrant.
func vector_godot_frame(kwadrant, tand, vector):
	var angle = deg_to_rad(-1*angles[kwadrant - 1][tand - 1])
	if kwadrant == 1 or kwadrant == 2:
		vector = Vector3(vector.x, cos(angle)*vector.y - sin(angle)*vector.z, sin(angle)*vector.y + cos(angle)*vector.z)
	if kwadrant == 3 or kwadrant == 4:
		vector = Vector3(cos(angle)*vector.x + sin(angle)*vector.z,vector.y, -sin(angle)*vector.x + cos(angle)*vector.z)
	return vector
	
# This function orders force and torque vectors by the directions as found in dentistry. 
# The first named directions is defined to be a positve value and the second negative, so for a buccal/lingual force a positive value lies in the buccal direction
func type_force_torque(kwadrant, _tand, force, torque):
	var result = [{'buccal/lingual': 0, 'mesial/distal': 0, 'extrusion/intrusion': 0},\
	{'mesial/distal angulation': 0, 'bucco/linguoversion': 0, 'mesiobuccal/lingual': 0}] # directions = [{forces}, {torques}]
	if kwadrant == 1 or kwadrant == 2:
		result[0]['buccal/lingual'] = force.y
		result[0]['extrusion/intrusion'] = force.x
		result[1]['bucco/linguoversion'] = torque.z
		if kwadrant == 1:
			result[0]['mesial/distal'] = -force.z
			result[1]['mesial/distal angulation'] = torque.y
			result[1]['mesiobuccal/lingual'] = torque.x
		if kwadrant == 2:
			result[0]['mesial/distal'] = force.z
			result[1]['mesial/distal angulation'] = -torque.y
			result[1]['mesiobuccal/lingual'] = -torque.x
	if kwadrant == 3 or kwadrant == 4:
		result[0]['buccal/lingual'] = force.x
		result[0]['extrusion/intrusion'] = force.y
		result[1]['bucco/linguoversion'] = -torque.z
		if kwadrant == 3:
			result[0]['mesial/distal'] = force.z
			result[1]['mesial/distal angulation'] = torque.x
			result[1]['mesiobuccal/lingual'] = torque.y
		if kwadrant == 4:
			result[0]['mesial/distal'] = -force.z
			result[1]['mesial/distal angulation'] = -torque.x
			result[1]['mesiobuccal/lingual'] = -torque.y
	return result

# this function combines all the previous functions to process the raw sensor data into usable data
func _handle_client_data(force, torque) -> void:
	# emits signal to debuginfo, this can be displayed during extractions
	emit_signal("data", force, torque)
	
	Global.raw_forces.append(force)
	Global.raw_torques.append(torque)
	
	var locatie = tand_locatie(Global.selectedQuadrant, Global.selectedTooth)
	torque = convert_torque(torque, force, locatie)
	torque = vector_tand_frame(Global.selectedQuadrant, Global.selectedTooth, torque)
	force = vector_tand_frame(Global.selectedQuadrant, Global.selectedTooth, force)
	
	Global.corrected_forces.append(force)
	Global.corrected_torques.append(torque)

	# Order forces and torques in various directions
	var dir = type_force_torque(Global.selectedQuadrant, Global.selectedTooth, force, torque)
	
	# store clinically orderd forces and torques in Global
	for key in dir[0].keys():
		Global.clinical_directions[0][key].append(dir[0][key])
	
	for key in dir[1].keys():
		Global.clinical_directions[1][key].append(dir[1][key])
		
	# Remove noise by using average
	var n = 100
	var avg_force = Global.get_avg_force(n)
	var avg_torque = Global.get_avg_torque(n)
	
	# Convert to numbers around 1
	avg_force = avg_force / 400
	avg_torque = avg_torque / 3
	
	# the following if statements relate to the translation of the forces and torques into movement of the 3d tooth model.
	if Global.selectedQuadrant == 1 or Global.selectedQuadrant == 2:
		transform.origin.x = avg_force.y
		transform.origin.y = avg_force.x
		transform.origin.z = avg_force.z

		var rot: Transform3D = Transform3D.IDENTITY
		rot = rot.rotated(Vector3( 1, 0, 0 ), avg_torque.y)
		rot = rot.rotated(Vector3( 0, 1, 0 ), avg_torque.x)
		rot = rot.rotated(Vector3( 0, 0, 1 ), avg_torque.z)
		transform.basis = rot.basis
	
	if Global.selectedQuadrant == 3 or Global.selectedQuadrant == 4:
		transform.origin.x = avg_force.x
		transform.origin.y = avg_force.y
		transform.origin.z = avg_force.z

		var rot: Transform3D = Transform3D.IDENTITY
		rot = rot.rotated(Vector3( 1, 0, 0 ), avg_torque.x)
		rot = rot.rotated(Vector3( 0, 1, 0 ), avg_torque.y)
		rot = rot.rotated(Vector3( 0, 0, 1 ), avg_torque.z)
		transform.basis = rot.basis

func _handle_client_disconnected() -> void:
	emit_signal("disconnected")
	print("Client disconnected from server.")
	_connect_after_timeout(RECONNECT_TIMEOUT) # Try to reconnect after 3 seconds

func _handle_client_error() -> void:
	print("Client error.")
	_connect_after_timeout(RECONNECT_TIMEOUT) # Try to reconnect after 3 seconds
