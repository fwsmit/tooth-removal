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
	

var i = 0;
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
