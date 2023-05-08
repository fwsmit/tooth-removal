extends RichTextLabel

@export var typeList : ItemList

func quadrantChanged(selected: int):
	Global.selectedQuadrant = selected + 1
	updateText()
	
func toothChanged(selected: int):
	Global.selectedTooth = selected + 1
	updateText()
	
func typeChanged(selected: int):
	Global.selectedType = typeList.get_item_text(selected)
	updateText()

func updateText():
	if Global.selectedQuadrant and Global.selectedTooth:
		text = "Selected tooth: " + \
			str(Global.selectedQuadrant) \
			+ str(Global.selectedTooth)
		if Global.selectedType != null:
			text += " (" + Global.selectedType + ")"
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

