extends ItemList


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_ready():
	if Global.selectedType != null:
		if Global.selectedType == 'Plastic':
			select(0)
		else:
			select(1)
