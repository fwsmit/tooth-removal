extends Panel


var custom_style = StyleBoxFlat.new()
#custom_style.change_bg_color

func _ready():
	custom_style.set_bg_color(Color("#212121"))
	custom_style.set_border_width_all(2)
	custom_style.set_border_color(Color("#212121"))
	
	
	$".".set('custom_styles/panel', custom_style)
	
	
func _on_mouse_entered():
	custom_style.set_bg_color(Color("#414141"))




func _on_mouse_exited():
	custom_style.set_bg_color(Color("#212121"))
	
