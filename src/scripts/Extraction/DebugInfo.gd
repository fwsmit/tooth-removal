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
	var zeroloc = zero_torque_location(force, torque, loc)
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

func num_to_string_padded(num, n_dec=1):
	var num_str = str(num)
	num_str = num_str.pad_decimals(n_dec)
	if num >= 0:
		num_str = " " + num_str
	return num_str

func vec_to_string(vec, n_dec=1):
	if vec == null:
		return "<null>"
	else:
		return "(" + num_to_string_padded(vec.x, n_dec) + ", "\
			+ num_to_string_padded(vec.y, n_dec) + ", "\
			+ num_to_string_padded(vec.z, n_dec) + ")"

func closest_point_on_line(linePnt, lineDir, pnt):
	lineDir = lineDir.normalized();
	var v = pnt - linePnt;
	var d = v.dot(lineDir);
	return linePnt + lineDir * d;

func zero_torque_location(f, t, realloc):
	if f == null or t == null:
		return Vector3.ZERO
	var location = t.cross(f) / f.dot(f)
	var direction = f
	return closest_point_on_line(location, direction, realloc)

func updateText():
	text = ""
	text += "Raw force: " + vec_to_string(force, 3) + "\n"
	text += "Raw torque: " + vec_to_string(torque, 3) + "\n"

	var location = data_user.tand_locatie(Global.selectedQuadrant, Global.selectedTooth)
	var zero_torque_l = zero_torque_location(force, torque, location)
	text += "Tand locatie: " + str(location) + "\n"
	text += "Zero torque locatie(m): " + str(zero_torque_l) + "\n"
	text += "Zero torque distance(cm): " + num_to_string_padded((location-zero_torque_l).length()*100) + "\n"
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
