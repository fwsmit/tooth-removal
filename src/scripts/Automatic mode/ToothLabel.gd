extends Label

func updateText():
	text = "Selected tooth: " + str(Global.selectedQuadrant) + str(Global.selectedTooth)

# Select teeth in the linear order (from back to front, to back)
# Start with Q1 or Q2 and finish with Q2 or Q4
func selectNewTooth():
	if Global.automaticModeStarted == true:
		var q = Global.selectedQuadrant
		if q == 3 or q == 1:
			if Global.selectedTooth > 1:
				Global.selectedTooth -= 1
			else:
				Global.selectedQuadrant += 1
				Global.selectedTooth = 1
		if q == 2 or q == 4:
			if Global.selectedTooth < 8:
				Global.selectedTooth += 1
			else:
				print("Finished whole jaw")
				Global.goto_scene("res://scenes/pre-extraction-automatic.tscn")
	else:
		# Select first tooth
		if Global.selectedJaw == "Lower jaw":
			Global.selectedQuadrant = 3
		else:
			Global.selectedQuadrant = 1
		Global.selectedTooth = 8
		Global.automaticModeStarted = true
	
	updateText()

# Called when the node enters the scene tree for the first time.
func _ready():
	selectNewTooth()

func skipTooth():
	selectNewTooth()

func gotoExtraction():
	Global.goto_scene("res://scenes/extraction.tscn")
