extends Node

signal connected
signal data
signal disconnected
signal error

var _status: int = 0
var initialized = false
var _stream: StreamPeerTCP = StreamPeerTCP.new()

var CMD_TYPE_SENSOR_TRANSMIT 	= '07'
var SENSOR_TRANSMIT_TYPE_START 	= '01'
var SENSOR_TRANSMIT_TYPE_STOP 	= '00'

var CMD_TYPE_SET_CURRENT_TARE 	= 0x15
var SET_CURRENT_TARE_TYPE_NEGATIVE	= '01'

func _ready() -> void:
	_stream.set_big_endian(true) # make sure to use big endian for network streams
	_status = _stream.get_status()

func reverse_bytearray(input):
	var output = PackedByteArray()
	output.append(input[7])
	output.append(input[6])
	output.append(input[5])
	output.append(input[4])
	output.append(input[3])
	output.append(input[2])
	output.append(input[1])
	output.append(input[0])
	return output
	
func to_double(input):
	var reversed = reverse_bytearray(input[1])
	return reversed.decode_double(0)

func consume_data_point():
	var length = _stream.get_partial_data(2)
	var Fx = _stream.get_double()
	var Fy = _stream.get_double()
	var Fz = _stream.get_double()
	var Tx = _stream.get_double()
	var Ty = _stream.get_double()
	var Tz = _stream.get_double()
	
	# Translate the axis from sensor definition to godot
	var force = Vector3(Fx, Fz, -Fy)
	var torque = Vector3(Tx, Tz, -Ty)
	# Check for read error.
	if length[0] != OK:
		print("Error getting data from stream: ", length[0])
		emit_signal("error")
	else:
		emit_signal("data", force, torque)

func _process(_delta: float) -> void:
	_stream.poll()
	var new_status: int = _stream.get_status()
	if new_status != _status:
		_status = new_status
		match _status:
			_stream.STATUS_NONE:
				print("Disconnected from host.")
				emit_signal("disconnected")
			_stream.STATUS_CONNECTING:
				print("Connecting to host.")
			_stream.STATUS_CONNECTED:
				print("Connected to host. Initializing sensor")
				initializeSensor()
				emit_signal("connected")
			_stream.STATUS_ERROR:
				print("Error with socket stream.")
				emit_signal("error")

	if _status == _stream.STATUS_CONNECTED and initialized:
		var available_bytes: int = _stream.get_available_bytes()
		while (available_bytes > 0):
			if available_bytes < 50:
				print("Error: data is in wrong format, size:", available_bytes)
				emit_signal("error")
				return
			else:
				consume_data_point()
				available_bytes = _stream.get_available_bytes()

func connect_to_host(host: String, port: int) -> void:
	print("Connecting to %s:%d" % [host, port])
	# Reset status so we can tell if it changes to error again.
	_status = _stream.STATUS_NONE
	if _stream.connect_to_host(host, port) != OK:
		print("Error connecting to host.")
		emit_signal("error")

func send(data: PackedByteArray) -> bool:
	if _status != _stream.STATUS_CONNECTED:
		print("Error: Stream is not currently connected.")
		return false
	var error: int = _stream.put_data(data)
	if error != OK:
		print("Error writing to stream: ", error)
		return false
	return true

func wait_for_response_and_consume():
	var available_bytes: int = 0
	
	while available_bytes <= 0:
		available_bytes = _stream.get_available_bytes()
	
	var data: Array = _stream.get_partial_data(available_bytes)
	if data[0] != OK:
		print("Error getting data from stream: ", data[0])
		emit_signal("error")

func initializeSensor():
	var messageTare: PackedByteArray = ['03', CMD_TYPE_SET_CURRENT_TARE, SET_CURRENT_TARE_TYPE_NEGATIVE] # Bytes for "ack" in ASCII
	send(messageTare)
	wait_for_response_and_consume()
	var startTransmit: PackedByteArray = ['03', CMD_TYPE_SENSOR_TRANSMIT, SENSOR_TRANSMIT_TYPE_START] # Bytes for "ack" in ASCII
	send(startTransmit)
	wait_for_response_and_consume()
	initialized = true
	print("Sensor is initialized")
	#emit_signal("initialized")
