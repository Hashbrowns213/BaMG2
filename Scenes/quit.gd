extends Node2D
func _ready():
	# Replace 'YourAutoloadName' with the name in Project Settings
	# Replace 'Container' with the name of the child node inside the CanvasLayer
	Hud.hide()


func _exit_tree():
	# Make it visible again when leaving this scene
	Hud.show()

func _on_yes_pressed() -> void:
	get_tree().quit()


func _on_no_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
