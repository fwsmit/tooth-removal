extends ItemList

@export var extractionList : ItemList

# Called when the node enters the scene tree for the first time.
func _ready():
	var dir = DirAccess.open("user://")
	for filename in dir.get_files():
		extractionList.add_item(filename)
		
	Global.selectedFile = null
	connect("item_selected", itemSelected)
	
func itemSelected(index):
	Global.selectedFile = get_item_text(index)
