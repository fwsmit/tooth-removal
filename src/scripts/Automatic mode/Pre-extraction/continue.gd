extends Button

@export var jawSelection : ItemList
@export var typeSelection : ItemList

func get_selected_item_text(list):
	var items = list.get_selected_items()
	if items.size() > 0:
		return list.get_item_text(items[0])
	else:
		return null

func _ready():
	Global.selectedJaw = null
	Global.selectedType = null

func _pressed():
	Global.selectedJaw = get_selected_item_text(jawSelection)
	Global.selectedType = get_selected_item_text(typeSelection)

	if Global.is_pre_automatic_extraction_data_valid():
		Global.automaticModeStarted = false
		Global.goto_scene("res://scenes/automatic-tooth-selector.tscn")
	else:
		OS.alert("Please select the jaw and type")
