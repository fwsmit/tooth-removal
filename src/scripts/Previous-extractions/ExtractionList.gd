extends ItemList

@export var extractionList : ItemList
@export var filterOptions : OptionButton
var index

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Updating index")
	if OS.get_name() == "Windows":
		OS.execute("python/windows/python.exe", ["../python/dataAnalysis.py", "--update-index"])
	else: # assume python is present in path
		OS.execute("python3", ["../python/dataAnalysis.py", "--update-index"])
	var filepath = FileAccess.open("user://index.json", FileAccess.READ)
	index = JSON.parse_string(filepath.get_as_text())
	for filename in index:
		extractionList.add_item(filename)
	
	for q in range(4):
		for t in range(8):
			filterOptions.add_item("Quadrant " + str(q+1) + ", tooth "+ str(t+1), (q+1)*10+t+1)
	
	Global.selectedFile = null
	connect("item_selected", itemSelected)
	
func itemSelected(index):
	Global.selectedFile = get_item_text(index)

func addUpperJawFiles(list):
	for f in index:
		if index[f]["quadrant"] == 1 or index[f]["quadrant"] == 2:
			list.add_item(f)

func addLowerJawFiles(list):
	for f in index:
		if index[f]["quadrant"] == 3 or index[f]["quadrant"] == 4:
			list.add_item(f)

func addTeethFiles(list, q, t):
	for f in index:
		if index[f]["quadrant"] == q and index[f]["tooth"] == t:
			list.add_item(f)

func filterSelected(filter):
	print("Filter selected: ", filter)
	extractionList.clear()
	if filter == 0:
		for f in index:
			extractionList.add_item(f)
		return
	if filter == 1:
		extractionList.clear()
		addUpperJawFiles(extractionList)
		return
	if filter == 2:
		addLowerJawFiles(extractionList)
		return
	var id = filterOptions.get_item_id(filter)
	var q = floor(float(id)/10)
	var t = id % 10
	print("Quadrant "+str(q)+", tooth ", str(t))
	addTeethFiles(extractionList, q, t)
	pass
