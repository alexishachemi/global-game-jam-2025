extends Control

func _menu_btn_pressed():
	get_tree().reload_current_scene()

func _quit_btn_pressed():
	get_tree().quit()
