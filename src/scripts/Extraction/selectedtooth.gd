extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	text = text + str(Global.selectedTooth) # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
