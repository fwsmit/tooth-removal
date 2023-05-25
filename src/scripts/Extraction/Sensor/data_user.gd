extends Node3D

#const HOST: String = "127.0.0.1"
const HOST: String = "192.168.0.100"
const PORT: int = 2001
const RECONNECT_TIMEOUT: float = 3.0

const Client = preload("res://scripts/Extraction/Sensor/client.gd")
const ft = preload("res://scripts/Extraction/Sensor/ft_translation.gd")
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



func _handle_client_data(force, torque) -> void:
	emit_signal("data", force, torque)
	Global.raw_forces.append(force)
	Global.raw_torques.append(torque)
  
	var locatie = ft.tand_locatie(Global.selectedQuadrant, Global.selectedTooth)
	torque = ft.convert_torque(torque, force, locatie)
	torque = ft.vector_tand_frame(Global.selectedQuadrant, Global.selectedTooth, torque)
	force = ft.vector_tand_frame(Global.selectedQuadrant, Global.selectedTooth, force)
	
	Global.corrected_forces.append(force)
	Global.corrected_torques.append(torque)

	# Order forces and torques in various directions
	var dir = ft.type_force_torque(Global.selectedQuadrant, Global.selectedTooth, force, torque)
	
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
