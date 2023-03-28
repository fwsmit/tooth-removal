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

func convert_torque(torque, force, location):
	print("Force cross: ", location.cross(force))
	print("Torque: ", torque)
	var result = torque + location.cross(force)
	return result
	

var i = 0;
func _handle_client_data(force, torque) -> void:
	#print(Fx, Fy, Fz, Tx, Ty, Tz)
#	uint64_t *p64 = (uint64_t *)buf;
#	*p64 = BSWAP64(*p64);
#	var Fx_d = encode_double(Fx)
	var kaak_locatie_onderkaak = Vector3(0.231, 0.062, 0)
	var tand_offset = Vector3(-0.01,0.02,0)
	var tand_locatie = kaak_locatie_onderkaak + tand_offset
	torque = convert_torque(torque, force, tand_locatie)
	# Convert to numbers around 1
	force = force * 0
	torque = torque
#	Fx = Fx/40
#	Fy = Fy/40
#	Fz = Fz/40
#	Tx = Tx/3
#	Ty = Ty/3
#	Tz = Tz/3
#	if i > 10: 
#		print(Fx[1])
#		var reversed = reverse_bytearray(Fx[1])
#		print(reversed)
#		print(reversed.decode_double(0))
#		print(Fx)
#		print(Fy)
#		i = 0
#	i += 1
	#if (Fx > 1):
		#print(Fx)
#	print(Fx, ", ", Fy)
	transform.origin.x = -force.x
	transform.origin.y = force.y
	transform.origin.z = force.z
	var rotation: Transform3D = Transform3D.IDENTITY
	rotation = rotation.rotated(Vector3( 1, 0, 0 ), torque.x)
	rotation = rotation.rotated(Vector3( 0, 1, 0 ), torque.y)
	rotation = rotation.rotated(Vector3( 0, 0, 1 ), torque.z)
	transform.basis = rotation.basis
	#var message: PackedByteArray = [97, 99, 107] # Bytes for "ack" in ASCII
	#_client.send(message)

func _handle_client_disconnected() -> void:
	print("Client disconnected from server.")
	_connect_after_timeout(RECONNECT_TIMEOUT) # Try to reconnect after 3 seconds

func _handle_client_error() -> void:
	print("Client error.")
	_connect_after_timeout(RECONNECT_TIMEOUT) # Try to reconnect after 3 seconds
