extends MarginContainer

@onready var Needle_1: Sprite2D = $VBoxContainer/PanelContainer/Needle_1
#@onready var Needle_2: Sprite2D = $"Axis 2/Needle_2"
#@onready var Needle_3: Sprite2D = $"Axis 3/Needle_3"

@onready var Bar1: TextureProgressBar = $VBoxContainer/Bar/Bar1_slider
#@onready var Bar2: TextureProgressBar = $HBoxContainer/Bar2
#@onready var Bar3: TextureProgressBar = $HBoxContainer/Bar3

signal data 


# Called when the node enters the scene tree for the first time.
func _ready():
	Needle_1.rotation = 0.0
	Bar1.postion = 0
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	if len(Global.corrected_torques) > 0:
#		print(Global.corrected_torques[-1].x)
#		Needle_1.rotation = Global.corrected_torques[-1].x

	if len(Global.clinical_directions) > 0:
	
		# Set all variables (forces and torques from the directions array)
		#Forces:
		var force_m_d = Global.clinical_directions[0]["mesial/distal"]
		var force_b_l = Global.clinical_directions[0]["buccal/lingual"]
		var force_e_i = Global.clinical_directions[0]["extrusion/intrusion"]

		#Torques:
		var torque_m_d = Global.clinical_directions[1]['mesial/distal angulation']
		var torque_b_l = Global.clinical_directions[1]["bucco/linguoversion"]
		var torque_m_l = Global.clinical_directions[1]["mesiobuccal/lingual"]
#		
		Needle_1.rotation = torque_m_d
		Bar1.position.x = force_m_d
		
#		Needle_2.rotation = torque_b_l
#		Bar2.value = force_b_l
		
#		Needle_3.rotation = torque_m_l
#		Bar3.value = force_e_i
		
	else:
		print('werkt niet')

#func _cluster(force, torque) -> void:
#	var rotation = 
