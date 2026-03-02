extends Node2D
func _ready():
	# Replace 'YourAutoloadName' with the name in Project Settings
	# Replace 'Container' with the name of the child node inside the CanvasLayer
	Hud.hide()


func _exit_tree():
	# Make it visible again when leaving this scene
	Hud.show()

func _on_start_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/openingcutscene.tscn")


func _on_settings_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/settings.tscn")


func _on_quit_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/quit.tscn")
