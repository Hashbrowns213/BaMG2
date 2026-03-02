extends Node2D
func _ready():
	# Replace 'YourAutoloadName' with the name in Project Settings
	# Replace 'Container' with the name of the child node inside the CanvasLayer
	Hud.hide()


func _exit_tree():
	# Make it visible again when leaving this scene
	Hud.show()

func _on_button_pressed() -> void:
	pass # Replace with function body.


func _on_button_2_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/controls.tscn")


func _on_button_3_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/main_menu.tscn")
