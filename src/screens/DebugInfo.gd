extends RichTextLabel

var force = null
var torque = null
var connected = false

func receiveData(_force, _torque):
	force = _force
	torque = _torque

func on_sensor_connected():
	connected = true

func on_sensor_disconnected():
	connected = false
	
func round_vector_to_decimal(vec, num):
	vec = vec * pow(10,num)
	vec = vec.round()
	vec = vec * pow(10,-num)
	return vec

func num_to_string_padded(num):
	var num_str = str(num)
	num_str = num_str.pad_decimals(1)
	if num >= 0:
		num_str = " " + num_str
	return num_str

func vec_to_string(vec):
	if vec == null:
		return "<null>"
	else:
		return "(" + num_to_string_padded(vec.x) + ", "\
			+ num_to_string_padded(vec.y) + ", "\
			+ num_to_string_padded(vec.z) + ")"

func updateText():
	text = ""
	text += "Force: " + vec_to_string(force) + "\n"
	text += "Torque: " + vec_to_string(torque) + "\n"
	text += "Connected: " + str(connected) + "\n"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible:
		updateText()
