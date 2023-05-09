extends Node


func _pressed():
	OS.execute("python3", ["../python/analysis/dataAnalysis.py", Global.selectedFile])
