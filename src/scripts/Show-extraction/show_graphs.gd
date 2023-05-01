extends Node


func _pressed():
	OS.execute("python3", ["../python/dataAnalysis.py", Global.selectedFile])
