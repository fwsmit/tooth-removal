extends RichTextLabel

@onready var data_user = $"../../../PanelContainer/GridContainer/3D box container/Node3D/CSGBox3D2"

var force = null
var torque = null
var connected = false

var timerStarted = false
var updateDelaySeconds = 0.5

func _ready():
	var loc = Vector3(0,9,-80)
	print("Location: ", loc)
	var force = Vector3(1, 1, 100)
	print("Force: ", force)
	var torque = Vector3.ZERO
	torque = data_user.convert_torque(torque, force, loc)
	print("Torque: ", torque)
	var zeroloc = zero_torque_location(force, torque)
	print("Zeroloc: ", zeroloc)
	var samet = data_user.convert_torque(Vector3.ZERO, force, zeroloc)
	print("Same torque: ", samet)

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

func zero_torque_location(f, t):
	if f == null or t == null:
		return Vector3.ZERO
	var location = Vector3.ZERO
	
	return t.cross(f) / f.dot(f)

func updateText():
	text = ""
	text += "Raw force: " + vec_to_string(force) + "\n"
	text += "Raw torque: " + vec_to_string(torque) + "\n"
	text += "Tand locatie: " + str(data_user.tand_locatie(Global.selectedQuadrant, Global.selectedTooth)) + "\n"
	text += "Zero torque locatie: " + str(zero_torque_location(force, torque)) + "\n"
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
