extends CSGBox3D

#const HOST: String = "127.0.0.1"
const HOST: String = "192.168.0.100"
const PORT: int = 2001
const RECONNECT_TIMEOUT: float = 3.0

const Client = preload("res://client.gd")
var _client: Client = Client.new()


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
	print("Client connected to server.")


var i = 0;
func _handle_client_data(Fx, Fy, Fz, Tx, Ty, Tz) -> void:
	#print(Fx, Fy, Fz, Tx, Ty, Tz)
	if i > 10: 
		print(Fx)
		i = 0
	i += 1
	#if (Fx > 1):
		#print(Fx)
#	print(Fx, ", ", Fy)
	transform.origin.x = Fx 
	transform.origin.y = Fy
	transform.origin.z = Fz
	var rotation: Transform3D = Transform3D.IDENTITY
	rotation = rotation.rotated(Vector3( 1, 0, 0 ), Tx)
	rotation = rotation.rotated(Vector3( 0, 1, 0 ), Ty)
	rotation = rotation.rotated(Vector3( 0, 0, 1 ), Tz)
	transform.basis = rotation.basis
	#var message: PackedByteArray = [97, 99, 107] # Bytes for "ack" in ASCII
	#_client.send(message)

func _handle_client_disconnected() -> void:
	print("Client disconnected from server.")
	_connect_after_timeout(RECONNECT_TIMEOUT) # Try to reconnect after 3 seconds

func _handle_client_error() -> void:
	print("Client error.")
	_connect_after_timeout(RECONNECT_TIMEOUT) # Try to reconnect after 3 seconds
