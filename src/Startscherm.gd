extends Control

@export var list: ItemList
@export var loginButton: Button

func login():
	print("Loggin in as: ", list.get_item_text(list.get_selected_items()[0]))
	Global.goto_scene("res://main.tscn")

func _ready():
	list.select(0)
	loginButton.connect("pressed", login)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
