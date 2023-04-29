extends ItemList

@export var extractionList : ItemList

# Called when the node enters the scene tree for the first time.
func _ready():
	var dir = DirAccess.open("user://")
	for filename in dir.get_files():
		extractionList.add_item(filename)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
