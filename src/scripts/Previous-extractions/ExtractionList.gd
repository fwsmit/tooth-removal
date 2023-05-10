extends ItemList

@export var quadrantFilter : GridContainer
@export var toothFilter : GridContainer
@export var personFilter : GridContainer

var filters
var index

func checkChildButtons(node):
	for child in node.get_children():
		child.button_pressed = true

func connectUpdate(node):
	for child in node.get_children():
		child.connect("pressed", updateFilter)

# Called when the node enters the scene tree for the first time.
func _ready():
	var filepath = FileAccess.open("user://index.json", FileAccess.READ)
	index = JSON.parse_string(filepath.get_as_text())
	for filename in index:
		add_item(filename)
	
	filters = [quadrantFilter, toothFilter, personFilter]
	for f in filters:
		checkChildButtons(f)
		connectUpdate(f)
	
	Global.selectedFile = null
	connect("item_selected", itemSelected)

func itemSelected(i):
	Global.selectedFile = get_item_text(i)

func n_th_button_checked(filter, n):
	return filter.get_children()[n].button_pressed

func filter_quadrant(filename):
	var q = index[filename]["quadrant"]
	return n_th_button_checked(quadrantFilter, q-1)

func filter_tooth(filename):
	var t = index[filename]["tooth"]
	return n_th_button_checked(toothFilter, t-1)

func filter_person(filename):
	var p = index[filename]["person_type"]
	for b in personFilter.get_children():
		if b.button_pressed and b.text == p:
			return true

	return false

func updateFilter():
	print("Updating filter")
	clear()
	for filename in index:
		if filter_quadrant(filename) and filter_tooth(filename) and filter_person(filename):
			add_item(filename)
