extends Control

@export var list: ItemList
@export var loginButton: Button

func login():
	Global.loggedInAs = list.get_item_text(list.get_selected_items()[0])
	print("Loggin in as: ", Global.loggedInAs)
	Global.goto_scene("res://scenes/dashboard2.tscn")

func _ready():
	list.select(0)
	loginButton.connect("pressed", login)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
