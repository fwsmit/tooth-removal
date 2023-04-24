extends RichTextLabel

@export var quadrantList : ItemList
@export var toothList : ItemList

func quadrantChanged(selected: int):
	Global.selectedQuadrant = selected + 1
	updateText()
	pass
	#quadrantList
	
func toothChanged(selected: int):
	Global.selectedTooth = selected + 1
	updateText()
	pass
	#quadrantList

func updateText():
	if Global.selectedQuadrant > 0 and Global.selectedTooth > 0:
		text = "Selected tooth: " + \
			str(Global.selectedQuadrant) \
			+ str(Global.selectedTooth)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
