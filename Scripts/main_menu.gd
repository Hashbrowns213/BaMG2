extends Node2D

func _on_start_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/main.tscn")


func _on_settings_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/settings.tscn")


func _on_quit_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/quit.tscn")
