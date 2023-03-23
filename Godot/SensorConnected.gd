extends ColorRect

#const Client = preload("res://client.gd")
#export var _client: Client
#
#func _ready() -> void:
#	_client.connect("connected",Callable(self,"_handle_client_connected"))
#	_client.connect("disconnected",Callable(self,"_handle_client_disconnected"))
#	_client.connect("error",Callable(self,"_handle_client_error"))
#	_client.connect("data",Callable(self,"_handle_client_data"))
#
#
#func _handle_client_connected() -> void:
#	print("Connected from 2d rect")
#	pass
#
#func _handle_client_data(Fx, Fy, Fz, Tx, Ty, Tz) -> void:
#	pass
#	#var message: PackedByteArray = [97, 99, 107] # Bytes for "ack" in ASCII
#	#_client.send(message)
#
#func _handle_client_disconnected() -> void:
#	pass
#
#func _handle_client_error() -> void:
#	pass
