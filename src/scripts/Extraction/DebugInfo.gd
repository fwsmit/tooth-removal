extends RichTextLabel

var force = null
var torque = null
var connected = false

var timerStarted = false
var updateDelaySeconds = 0.5

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
	if Global.clinical_directions[0]['buccal/lingual'].size() > 0:
		text += "buccal/lingual: " + num_to_string_padded(Global.clinical_directions[0]['buccal/lingual'][-1])  + "\n"
		text += "mesial/distal: " + num_to_string_padded(Global.clinical_directions[0]['mesial/distal'][-1]) + "\n"
		text += "extrusion/intrusion: " + num_to_string_padded(Global.clinical_directions[0]['extrusion/intrusion'][-1]) + "\n"
		text += "mesial/distal angulation: " + num_to_string_padded(10*Global.clinical_directions[1]['mesial/distal angulation'][-1]) + "E-1\n"
		text += "bucco/linguoversion: " + num_to_string_padded(10*Global.clinical_directions[1]['bucco/linguoversion'][-1]) + "E-1\n"
		text += "mesiobuccal/lingual: " + num_to_string_padded(10*Global.clinical_directions[1]['mesiobuccal/lingual'][-1]) + "E-1\n"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not timerStarted:
		timerStarted = true
		updateText()
		await get_tree().create_timer(updateDelaySeconds).timeout
		updateText()
		timerStarted = false
