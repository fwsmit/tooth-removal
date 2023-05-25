extends Node

static func convert_torque(torque, force, location):
	var result = torque - location.cross(force)
	return result

#tandvectors = [[boven, onder],[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8]]
static func tand_locatie(kwadrant, tand):
	var tandvectors = [[Vector3(0.0395, 0.249, 0), Vector3(0.226, 0.0623, 0)],\
	[Vector3(0.0332, -0.00759, 0.00336),Vector3(0.0336, -0.0101, 0.011),Vector3(0.0344, -0.0133, 0.0189),Vector3(0.0321, -0.0225, 0.0193),Vector3(0.0321, -0.0295, 0.0232),Vector3(0.0311, -0.0371, 0.0241),Vector3(0.0308, -0.0481, 0.0253),Vector3(0.0299, -0.0583, 0.0258)],\
	[Vector3(0.0332, -0.00759, -0.00336),Vector3(0.0336, -0.0101, -0.011),Vector3(0.0344, -0.0133, -0.0189),Vector3(0.0321, -0.0225, -0.0193),Vector3(0.0321, -0.0295, -0.0232),Vector3(0.0311, -0.0371, -0.0241),Vector3(0.0308, -0.0481, -0.0253),Vector3(0.0299, -0.0583, -0.0258)],\
	[Vector3(-0.0131, 0.0261, -0.00207),Vector3(-0.0136, 0.0263, -0.00779),Vector3(-0.0164, 0.0264, -0.0135),Vector3(-0.0225, 0.0225, -0.0155),Vector3(-0.0291, 0.0237, -0.0189),Vector3(-0.0383, 0.0226, -0.0214),Vector3(-0.0494, 0.0225, -0.0211),Vector3(-0.0602, 0.0229, -0.0228)],\
	[Vector3(-0.0131, 0.0261, 0.00207),Vector3(-0.0136, 0.0263, 0.00779),Vector3(-0.0164, 0.0264, 0.0135),Vector3(-0.0225, 0.0225, 0.0155),Vector3(-0.0291, 0.0237, 0.0189),Vector3(-0.0383, 0.0226, 0.0214),Vector3(-0.0494, 0.0225, 0.0211),Vector3(-0.0602, 0.0229, 0.0228)]]
	var locatie = []
	if kwadrant == 1 or kwadrant == 2:
		locatie = tandvectors[0][0] + tandvectors[kwadrant][tand - 1] + Vector3(-0.002, 0, 0)
	if kwadrant == 3 or kwadrant == 4:
		locatie = tandvectors[0][1] + tandvectors[kwadrant][tand - 1] + Vector3(0, -0.002, 0)
	return locatie

const angles = [[0., -19.4, -53., -57.5, -66.3, -79.7, -79.7, -95.6], [0., 19.4, 53., 57.5, 66.3, 79.7, 79.7, 95.6],[0 , -19.7, -39.2, -67., -78., -78., -78., -90.],[0 , 19.7, 39.15, 67., 78., 78., 78., 90.]]

static func rotate_frame_lower(vector:Vector3, angle):
	angle = deg_to_rad(angle)
	return Vector3(cos(angle)*vector.x + sin(angle)*vector.z,vector.y, -sin(angle)*vector.x + cos(angle)*vector.z)

static func rotate_frame_upper(vector:Vector3, angle):
	angle = deg_to_rad(angle)
	return Vector3(vector.x, cos(angle)*vector.y - sin(angle)*vector.z, sin(angle)*vector.y + cos(angle)*vector.z)

static func rotate_frame(vector, angle, kwadrant):
	if kwadrant == 1 or kwadrant == 2:
		return rotate_frame_upper(vector, angle)
	if kwadrant == 3 or kwadrant == 4:
		return rotate_frame_lower(vector, angle)

static func vector_tand_frame(kwadrant, tand, vector):
	var angle = angles[kwadrant - 1][tand - 1]
	return rotate_frame(vector, angle, kwadrant)

static func vector_godot_frame(kwadrant, tand, vector):
	var angle = angles[kwadrant - 1][tand - 1]
	return rotate_frame(vector, -angle, kwadrant)

# deze functie ordent de kracht en momentvectoren in de richtingen gedefinieerd in tandheelkunde. 
# De eerstegnoemde is altijd positief, dus bij buccal lingual, geldt dat een positieve waarde in de buccale richting is
static func type_force_torque(kwadrant, _tand, force, torque):
	var result = [{'buccal/lingual': 0, 'mesial/distal': 0, 'extrusion/intrusion': 0},\
	{'mesial/distal angulation': 0, 'bucco/linguoversion': 0, 'mesiobuccal/lingual': 0}] # directions = [{forces}, {torques}]
	if kwadrant == 1 or kwadrant == 2:
		result[0]['buccal/lingual'] = force.y
		result[0]['extrusion/intrusion'] = force.x
		result[1]['bucco/linguoversion'] = torque.z
		if kwadrant == 1:
			result[0]['mesial/distal'] = -force.z
			result[1]['mesial/distal angulation'] = torque.y
			result[1]['mesiobuccal/lingual'] = torque.x
		if kwadrant == 2:
			result[0]['mesial/distal'] = force.z
			result[1]['mesial/distal angulation'] = -torque.y
			result[1]['mesiobuccal/lingual'] = -torque.x
	if kwadrant == 3 or kwadrant == 4:
		result[0]['buccal/lingual'] = force.x
		result[0]['extrusion/intrusion'] = force.y
		result[1]['bucco/linguoversion'] = -torque.z
		if kwadrant == 3:
			result[0]['mesial/distal'] = force.z
			result[1]['mesial/distal angulation'] = torque.x
			result[1]['mesiobuccal/lingual'] = torque.y
		if kwadrant == 4:
			result[0]['mesial/distal'] = -force.z
			result[1]['mesial/distal angulation'] = -torque.x
			result[1]['mesiobuccal/lingual'] = -torque.y
	return result
