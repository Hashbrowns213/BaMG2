extends Control





func _on_pressed():
	get_tree().change_scene_to_file("res://UI/game_test.tscn")


func _on_settings_pressed():
	get_tree().change_scene_to_file("res://UI/setting_scene.tscn")


func _on_quit_pressed():
	get_tree().change_scene_to_file("res://quit.tscn")
