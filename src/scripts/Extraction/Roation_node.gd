extends MarginContainer

@onready var Needle_1: Sprite2D = $VBoxContainer/PanelContainer/Needle_1
#@onready var Needle_2: Sprite2D = $"Axis 2/Needle_2"
#@onready var Needle_3: Sprite2D = $"Axis 3/Needle_3"

@onready var Bar1: Sprite2D = $VBoxContainer/Bar/Bar1_slider
#@onready var Bar2: TextureProgressBar = $HBoxContainer/Bar2
#@onready var Bar3: TextureProgressBar = $HBoxContainer/Bar3

signal data 


# Called when the node enters the scene tree for the first time.
func _ready():
	Needle_1.rotation = 0.0
#	Bar1.postion = 0
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	if Global.clinical_directions[0]["mesial/distal"] != null:
#		var force_m_d = Global.clinical_directions[0]["mesial/distal"]
#		print(force_m_d)
#		Bar1.position.x[-1] = force_m_d.x
#	if Global.clinical_directions[1]['mesial/distal angulation'] != null:
#		var torque_m_d = Global.clinical_directions[1]['mesial/distal angulation']
#		Needle_1.rotation = torque_m_d
	
	
#	if len(Global.corrected_torques) > 0:
#		print(Global.corrected_torques[-1].x)
#		Needle_1.rotation = Global.corrected_torques[-1].x
#	print(len(Global.clinical_directions))
#	print('var force_m_d =', Global.clinical_directions[0]["mesial/distal"])
	print('var torque_m_d =', Global.clinical_directions[1]['mesial/distal angulation'])
	if len(Global.corrected_torques)> 0:
		print('cF:', Global.corrected_torques[-1].x)
	
	
		
#	if len(Global.clinical_directions) > 0:
#
#		# Set all variables (forces and torques from the directions array)
#		#Forces:
#		var force_m_d = Global.clinical_directions[0]["mesial/distal"]
#		var force_b_l = Global.clinical_directions[0]["buccal/lingual"]
#		var force_e_i = Global.clinical_directions[0]["extrusion/intrusion"]
#
#		#Torques:
#		var torque_m_d = Global.clinical_directions[1]['mesial/distal angulation']
#		var torque_b_l = Global.clinical_directions[1]["bucco/linguoversion"]
#		var torque_m_l = Global.clinical_directions[1]["mesiobuccal/lingual"]
##		
#		Needle_1.rotation = torque_m_d
#		Bar1.position.x = force_m_d
		
#		Needle_2.rotation = torque_b_l
#		Bar2.value = force_b_l
		
#		Needle_3.rotation = torque_m_l
#		Bar3.value = force_e_i
		
#	else:
#		print('werkt niet')
#
#func _get_vectors(vecs):
#	var vec1 = Data_user.
#
#func get_avg_vector(n, vecs):
#	var total = Vector3.ZERO
#	if len(vecs) < n:
#		return Vector3.ZERO
#
#	for i in range(n):
#		total += vecs[-(i+1)]
#	return total/n
#
#func get_avg_torque(n):
#	return get_avg_vector(n, corrected_torques)
#
## Remove noise by using average
#	var n = 100
#	var avg_force = Global.get_avg_force(n)
#	var avg_torque = Global.get_avg_torque(n)
#
#	# Convert to numbers around 1
#	avg_force = avg_force / 40
#	avg_torque = avg_torque / 3
#
#	transform.origin.x = avg_force.x
#	transform.origin.y = avg_force.y
#	transform.origin.z = avg_force.z
#
#	var rot: Transform3D = Transform3D.IDENTITY
#	rot = rot.rotated(Vector3( 1, 0, 0 ), avg_torque.x)
#	rot = rot.rotated(Vector3( 0, 1, 0 ), avg_torque.y)
#	rot = rot.rotated(Vector3( 0, 0, 1 ), avg_torque.z)
#	transform.basis = rot.basis

#func _cluster(force, torque) -> void:
#	var rotation = 
