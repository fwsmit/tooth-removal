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

func convert_torque(torque, force, location):
	var result = torque - location.cross(force)
	return result
	
#tandvectors = [[boven, onder],[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8]]
func tand_locatie(kwadrant, tand):
	var tandvectors = [[Vector3(0.0395, 0.249, 0), Vector3(0.226, 0.0623, 0)],\
	[Vector3(0.0332, -0.00759, 0.00336),Vector3(0.0336, -0.0101, 0.011),Vector3(0.0344, -0.0133, 0.0189),Vector3(0.0321, -0.0225, 0.0193),Vector3(0.0321, -0.0295, 0.0232),Vector3(0.0311, -0.0371, 0.0241),Vector3(0.0308, -0.0481, 0.0253),Vector3(0.0299, -0.0583, 0.0258)],\
	[Vector3(0.0332, -0.00759, -0.00336),Vector3(0.0336, -0.0101, -0.011),Vector3(0.0344, -0.0133, -0.0189),Vector3(0.0321, -0.0225, -0.0193),Vector3(0.0321, -0.0295, -0.0232),Vector3(0.0311, -0.0371, -0.0241),Vector3(0.0308, -0.0481, -0.0253),Vector3(0.0299, -0.0583, -0.0258)],\
	[Vector3(-0.0131, 0.0261, -0.00207),Vector3(-0.0136, 0.0263, -0.00779),Vector3(-0.0164, 0.0264, -0.0135),Vector3(-0.0225, 0.0225, -0.0155),Vector3(-0.0291, 0.0237, -0.0189),Vector3(-0.0383, 0.0226, -0.0214),Vector3(-0.0494, 0.0225, -0.0211),Vector3(-0.0602, 0.0229, -0.0228)],\
	[Vector3(-0.0131, 0.0261, 0.00207),Vector3(-0.0136, 0.0263, 0.00779),Vector3(-0.0164, 0.0264, 0.0135),Vector3(-0.0225, 0.0225, 0.0155),Vector3(-0.0291, 0.0237, 0.0189),Vector3(-0.0383, 0.0226, 0.0214),Vector3(-0.0494, 0.0225, 0.0211),Vector3(-0.0602, 0.0229, 0.0228)]]
	var locatie = []
	if kwadrant == 1 or kwadrant == 2:
		locatie = tandvectors[0][0] + tandvectors[kwadrant][tand - 1] + Vector3(-0.002, 0, 0)
	if kwadrant == 3 or kwadrant == 4:
		locatie = tandvectors[0][1] + tandvectors[kwadrant][tand - 1] + Vector3(0, -0.002, 0)

	# Corrigeer voor sensor center of gravity
	locatie = locatie + Vector3(0, 18./1000., 0)
	return locatie

var angles = [[0., -19.4, -53., -57.5, -66.3, -79.7, -79.7, -95.6], [0., 19.4, 53., 57.5, 66.3, 79.7, 79.7, 95.6],[0 , -19.7, -39.2, -67., -78., -78., -78., -90.],[0 , 19.7, 39.15, 67., 78., 78., 78., 90.]]

func vector_tand_frame(kwadrant, tand, vector):
	var angle = deg_to_rad(angles[kwadrant - 1][tand - 1])
	if kwadrant == 1 or kwadrant == 2:
		vector = Vector3(vector.x, cos(angle)*vector.y - sin(angle)*vector.z, sin(angle)*vector.y + cos(angle)*vector.z)
	if kwadrant == 3 or kwadrant == 4:
		vector = Vector3(cos(angle)*vector.x + sin(angle)*vector.z,vector.y, -sin(angle)*vector.x + cos(angle)*vector.z)
	return vector

func vector_godot_frame(kwadrant, tand, vector):
	var angle = deg_to_rad(-1*angles[kwadrant - 1][tand - 1])
	if kwadrant == 1 or kwadrant == 2:
		vector = Vector3(vector.x, cos(angle)*vector.y - sin(angle)*vector.z, sin(angle)*vector.y + cos(angle)*vector.z)
	if kwadrant == 3 or kwadrant == 4:
		vector = Vector3(cos(angle)*vector.x + sin(angle)*vector.z,vector.y, -sin(angle)*vector.x + cos(angle)*vector.z)
	return vector
# deze functie ordent de kracht en momentvectoren in de richtingen gedefinieerd in tandheelkunde. 
# De eerstegnoemde is altijd positief, dus bij buccal lingual, geldt dat een positieve waarde in de buccale richting is
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

func _handle_client_data(force, torque) -> void:
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
