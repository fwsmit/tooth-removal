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

	Bar1.position.x = 176
	Bar1.position.y = 16.5
	Bar2.position.x = 176
	Bar2.position.y = 16.5
	Bar3.position.x = 176
	Bar3.position.y = 16.5
	
func _process(delta):
	var n = 1000
#	print(Global.get_avg_torque(n))
#	print(Global.get_avg_force(n))
	
	#Set parameters for the clustermeters:
	var min_rotation_degrees = -90
	var max_rotation_degrees = 90
	
	var min_position_x = 0
	var max_position_x = 352
	
	#Parameter input based on Data Analysis:
	
	var min_torque_m_d = -1.2
	var max_torque_m_d = 1.2
	var min_torque_b_l = -3
	var max_torque_b_l = 3
	var min_torque_m_l = -1
	var max_torque_m_l = 1
	
	var min_force_b_l = -20
	var max_force_b_l = 20
	var min_force_m_d = -20
	var max_force_m_d = 20
	var min_force_e_i = -30
	var max_force_e_i = 30
	
	
#	var weight_rot = (speed - min_speed) / (max_speed - min_speed)
#	var weight_pos = (speed - min_speed) / (max_speed - min_speed)
	
	
#	var D_rotation = lerp(min_rotation_degrees, max_rotation_degrees, weight_rot)
#	var D_position = lerp(min_position_x, max_position_x, weight_pos)
	
#	

	
	if Global.selectedQuadrant != null and Global.selectedTooth != null:
		if Global.selectedQuadrant == 1 or Global.selectedQuadrant == 2:
			
			var force_b_l = Global.get_avg_force(n).y
			var weight_pos_b_l = (force_b_l - min_force_b_l) / (max_force_b_l - min_force_b_l)
			var D_position_b_l = lerp(min_position_x, max_position_x, weight_pos_b_l)
			Bar2.position.x = 176 - D_position_b_l
			
#			Needle_2.rotation = -0.5*force_b_l
			
			var force_e_i = Global.get_avg_force(n).x
			var weight_pos_e_i = (force_e_i - min_force_e_i) / (max_force_e_i - min_force_e_i)
			var D_position_e_i = lerp(min_position_x, max_position_x, weight_pos_e_i)
			print(D_position_e_i)
			Bar3.position.x = 176 - D_position_e_i
#			Bar3.position.x = 179 - 10*(force_e_i)

			var torque_b_l = Global.get_avg_torque(n).z
			var weight_rot_b_l = (torque_b_l - min_torque_b_l) / (max_torque_b_l - min_torque_b_l)
			var D_rotation_b_l = lerp(min_rotation_degrees, max_rotation_degrees, weight_rot_b_l)
			print(D_rotation_b_l)
			Needle_1.rotation = -D_rotation_b_l
			
			if Global.selectedQuadrant == 1:
				var force_m_d = -Global.get_avg_force(n).z
				Bar1.position.x = 179 - 10*(force_m_d)
				
#				var torque_m_d = Global.get_avg_torque(n).y
#				Bar2.position.x = 179 - 10*(force_m_d)
#
#				Bar1.position.x = 176 - 10*(force_m_d)
				
				var torque_m_d = Global.get_avg_torque(n).y
				Needle_2.rotation = -0.5*torque_m_d
				
				var torque_m_l = Global.get_avg_torque(n).x
				Needle_3.rotation = torque_m_l
				
			if Global.selectedQuadrant == 2:
				var force_m_d = Global.get_avg_force(n).z
				
				Bar1.position.x = 179 - 10*(force_m_d)
				
				var torque_m_d = -Global.get_avg_torque(n).y
#				Bar2.position.x = 179 - 10*(force_m_d)
#
#				Bar1.position.x = 176 - 10*(force_m_d)
				
				var torque_m_l = -Global.get_avg_torque(n).x
				Needle_3.rotation = torque_m_l

		if Global.selectedQuadrant == 3 or Global.selectedQuadrant == 4:
			var force_b_l = Global.get_avg_force(n).x
			Needle_2.rotation = -0.5*force_b_l
			
			var force_e_i = Global.get_avg_force(n).y
			
#			Bar3.position.x = 179 - 10*(force_e_i)
#
#			Bar3.position.x = 176 - 10*(force_e_i)
			
			var torque_b_l = -Global.get_avg_torque(n).z
			Needle_1.rotation = -torque_b_l
			
			if Global.selectedQuadrant == 3:
				var force_m_d = Global.get_avg_force(n).z
				
				Bar1.position.x = 179 - 10*(force_m_d)
				
				var torque_m_d = Global.get_avg_torque(n).x
				Bar2.position.x = 179 - 10*(force_m_d)
				
#				Bar1.position.x = 176 - 10*(force_m_d)
				
				
			
				
				var torque_m_l = Global.get_avg_torque(n).y
				Needle_3.rotation = torque_m_l
				
			if Global.selectedQuadrant == 4:
				var force_m_d = -Global.get_avg_force(n).z
				
				Bar1.position.x = 179 - 10*(force_m_d)
				
				var torque_m_d = -Global.get_avg_torque(n).x
				Bar2.position.x = 176 - 10*(force_m_d)
				
				var torque_m_l = -Global.get_avg_torque(n).y
				Needle_3.rotation = torque_m_l
