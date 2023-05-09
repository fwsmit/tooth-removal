extends Node


func _pressed():
	Global.python_run(["../python/analysis/dataAnalysis.py", Global.selectedFile])
