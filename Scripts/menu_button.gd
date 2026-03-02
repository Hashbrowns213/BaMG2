extends MenuButton

func _on_try_again_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/main.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit(
		
	)
