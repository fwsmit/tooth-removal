extends GridContainer


@onready var Needle_1: Sprite2D = $"Axis 1/VBoxContainer/PanelContainer/Needle_1"
@onready var Needle_2: Sprite2D = $"Axis 2/VBoxContainer/PanelContainer/Needle_2"
@onready var Needle_3: Sprite2D = $"Axis 3/VBoxContainer/PanelContainer/Needle_3"

@onready var Bar1: Sprite2D = $"Axis 1/VBoxContainer/Bar/Bar1_slider"
@onready var Bar2: Sprite2D = $"Axis 2/VBoxContainer/Bar2/Bar2_slider"
@onready var Bar3: Sprite2D = $"Axis 3/VBoxContainer/Bar3/Bar3_slider"

signal data 

func _ready():
	Needle_1.rotation = 0.0
	Needle_2.rotation = 0.0
	Needle_3.rotation = 0.0
	Bar1.position.x = 179
	Bar1.position.y = 16.5
	Bar2.position.x = 179
	Bar2.position.y = 16.5
	Bar3.position.x = 179
	Bar3.position.y = 16.5
	
func _process(delta):
	var n = 100
	print(Global.get_avg_torque(n))
	print(Global.get_avg_force(n))
	
	
	if Global.selectedQuadrant != null and Global.selectedTooth != null:
		if Global.selectedQuadrant == 1 or Global.selectedQuadrant == 2:
			var force_b_l = Global.get_avg_force(n).y
			Needle_2.rotation = -0.5*force_b_l
			
			var force_e_i = Global.get_avg_force(n).x
			Bar3.position.x = 179 - 10*(force_e_i)
			
			var torque_b_l = Global.get_avg_torque(n).z
			Needle_1.rotation = -torque_b_l
			
			if Global.selectedQuadrant == 1:
				var force_m_d = -Global.get_avg_force(n).z
				Bar1.position.x = 179 - 10*(force_m_d)
				
				var torque_m_d = Global.get_avg_torque(n).y
				Bar2.position.x = 179 - 10*(force_m_d)
				
				var torque_m_l = Global.get_avg_torque(n).x
				Needle_3.rotation = torque_m_l
#			
#
#			if kwadrant == 2:
#				result[0]['mesial/distal'] = force.z
#				result[1]['mesial/distal angulation'] = -torque.y
#				result[1]['mesiobuccal/lingual'] = -torque.x
#		if kwadrant == 3 or kwadrant == 4:
#			result[0]['buccal/lingual'] = force.x
#			result[0]['extrusion/intrusion'] = force.y
#			result[1]['bucco/linguoversion'] = -torque.z
#			if kwadrant == 3:
#				result[0]['mesial/distal'] = force.z
#				result[1]['mesial/distal angulation'] = torque.x
#				result[1]['mesiobuccal/lingual'] = torque.y
#			if kwadrant == 4:
#				result[0]['mesial/distal'] = -force.z
#				result[1]['mesial/distal angulation'] = -torque.x
#				result[1]['mesiobuccal/lingual'] = -torque.y
#	return result
