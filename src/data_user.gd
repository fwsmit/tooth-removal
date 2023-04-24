extends CSGBox3D

#const HOST: String = "127.0.0.1"
const HOST: String = "192.168.0.100"
const PORT: int = 2001
const RECONNECT_TIMEOUT: float = 3.0

const Client = preload("res://client.gd")
var _client: Client = Client.new()

signal connected
signal disconnected

func _ready() -> void:
	_client.connect("connected",Callable(self,"_handle_client_connected"))
	_client.connect("disconnected",Callable(self,"_handle_client_disconnected"))
	_client.connect("error",Callable(self,"_handle_client_error"))
	_client.connect("data",Callable(self,"_handle_client_data"))
	add_child(_client)
	_client.connect_to_host(HOST, PORT)

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
	[Vector3(-0.0131, 0.0261, -0.00207),Vector3(-0.0136, 0.0263, -0.00779),Vector3(-0.0164, 0.0264, -0.0135),Vector3(-0.0225, 0.0225, -0.0155),Vector3(-0.0291, 0.0237, -0.0189),Vector3(-0.0383, 0.0226, -0.0214),Vector3(-0.0494, 0.0225, -0.0211),Vector3(-0.0602, 0.0229, -0.0228)]]
	var locatie = []
	if kwadrant == 1 or kwadrant == 2:
		locatie = tandvectors[0][0] + tandvectors[kwadrant][tand - 1]
	if kwadrant == 3 or kwadrant == 4:
		locatie = tandvectors[0][1] + tandvectors[kwadrant][tand - 1]
	return locatie

func _handle_client_data(force, torque) -> void:
	var kaak_locatie_onderkaak = Vector3(0.231, 0.062, 0)
	var tand_offset = Vector3(-0.01,0.02,0)
	var tand_locatie = kaak_locatie_onderkaak + tand_offset
	torque = convert_torque(torque, force, tand_locatie)
	# Convert to numbers around 1
	force = force / 40
	torque = torque / 3
#	
	transform.origin.x = force.x
	transform.origin.y = force.y
	transform.origin.z = force.z
	var rotation: Transform3D = Transform3D.IDENTITY
	rotation = rotation.rotated(Vector3( 1, 0, 0 ), torque.x)
	rotation = rotation.rotated(Vector3( 0, 1, 0 ), torque.y)
	rotation = rotation.rotated(Vector3( 0, 0, 1 ), torque.z)
	transform.basis = rotation.basis

func _handle_client_disconnected() -> void:
	emit_signal("disconnected")
	print("Client disconnected from server.")
	_connect_after_timeout(RECONNECT_TIMEOUT) # Try to reconnect after 3 seconds

func _handle_client_error() -> void:
	print("Client error.")
	_connect_after_timeout(RECONNECT_TIMEOUT) # Try to reconnect after 3 seconds
