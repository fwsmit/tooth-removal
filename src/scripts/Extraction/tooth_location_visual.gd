@tool
extends EditorScript


const data_user = preload("res://scripts/Extraction/Sensor/data_user.gd")
var loc = data_user.new()
var no_quadrants = 4
var no_teeth = 8
var ax = 1


# Called when the node enters the scene tree for the first time.
func frame(ft: String):
	var l = 0.005
	var x = Vector3(l, 0, 0)
	var y = Vector3(0, l, 0)
	var z = Vector3(0, 0, l)
	
	var result = [{'buccal/lingual': [y, y, x, x, Color.RED], 'mesial/distal': [-z, z, z, -z, Color.GREEN], 'extrusion/intrusion': [x, x, y, y, Color.YELLOW]},\
	{'mesial/distal angulation': [y, -y, x, -x,  Color.RED], 'bucco/linguoversion': [z, z, -z, -z,  Color.GREEN], 'mesiobuccal/lingual': [x, -x, y, -y,  Color.YELLOW]}] # directions = [{forces}, {torques}]
	
	if ft == 'force':
		return result[0]
	if ft == 'torque':
		return result[1]

func _ready():
	for i1 in range(no_quadrants):
		var k = i1 + 1
		for i2 in range(no_teeth):
			var t = i2 + 1
			create_ball(loc.tand_locatie(k, t))
			draw_frame(k, t)
	

func _run():
	_ready()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# draws three lines for each axis of tooth frame
func draw_frame(k, t):
	var kwadrant = k
	var tand = t
	var locatie = loc.tand_locatie(kwadrant, tand)
	var ft = 'force'
	for key in frame(ft).keys():
		draw_vector(locatie, loc.vector_godot_frame(kwadrant, tand, frame(ft)[key][kwadrant - 1]), frame(ft)[key][-1])

# draws a line
func draw_vector(locatie, vector, color) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	var start = locatie
	var end = locatie + vector
	mesh_instance.mesh = immediate_mesh

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(start)
	immediate_mesh.surface_add_vertex(end)
	immediate_mesh.surface_end()	
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	
	get_scene().add_child(mesh_instance)
	return mesh_instance
	

# creates a ball, to visualize a tooth
func create_ball(position):
	var ball_instance = CSGSphere3D.new()
	ball_instance.set_radius(0.001)	
	ball_instance.transform.origin = position
	get_scene().add_child(ball_instance)
