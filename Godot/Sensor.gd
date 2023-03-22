extends CSGBox


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#@export var speed = 10

# Called when the node enters the scene tree for the first time.


var client = null
var wrapped_client = null
var debug = null
var connected = false


var CMD_TYPE_SENSOR_TRANSMIT 	= '07'
var SENSOR_TRANSMIT_TYPE_START 	= '01'
var SENSOR_TRANSMIT_TYPE_STOP 	= '00'

var CMD_TYPE_SET_CURRENT_TARE 	= '15'
var SET_CURRENT_TARE_TYPE_NEGATIVE	= '01'

func _ready():
	
	client = StreamPeerTCP.new()
	#connect_to_server("192.168.0.100", 2001)
	connect_to_server("127.0.0.1", 2001)
	
var count = 0
func _process(delta):
	
	#debug = self.get_child(0).get_child(0) # keep updating reference to debug
	
	# Check if client is connected and has data before attempting to read data
	if client.is_connected_to_host() && wrapped_client.get_available_packet_count() >0:
		print("Received: "+str(wrapped_client.get_var()))

	if client.get_status()==1: # if client is connecting
		count= count+delta
	if client.get_status()==2 and not connected:
		#var sendData = '03' + CMD_TYPE_SET_CURRENT_TARE + SET_CURRENT_TARE_TYPE_NEGATIVE
		var sendData = 0x031501
		send_to_server(sendData)
		
		#var sendData2 = '03' + CMD_TYPE_SENSOR_TRANSMIT + SENSOR_TRANSMIT_TYPE_START
		var sendData2 = 0x030701
		send_to_server(sendData2)
		#recvData = recvMsg()
		connected = true
		print("Connected")

	if count>1: # if it took more than 1s to connect, error
		print("Stuck connecting, disconnecting")
		client.disconnect_from_host() #interrupts connection to nothing
		set_process(false) # stop listening for packets

func update_debug_ref(debug_node):
	debug = debug_node
	
func connect_to_server(host,port):
	
	# If the client is not connected, connect
	
	print("Connecting...")
	# Connect to server
	client.connect_to_host(host,port)
	#Wrap the StreamPeerTCP in a PacketPeerStream
	wrapped_client = PacketPeerStream.new()
	wrapped_client.set_stream_peer(client)
	set_process(true) # start listening for packets
		
func send_to_server(data):
	
	# Check if client is connected before attempting to send data
	#debug = self.get_child(0).get_child(0)
	
	if client.is_connected_to_host():
	
		print("Sending: "+str(data))
		# Send data
		wrapped_client.put_var(data)

func disconnect_from_server():
	client.disconnect()
