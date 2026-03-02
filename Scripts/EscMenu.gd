extends CanvasLayer

@onready var hud = Hud   # your autoload

var is_open := false

func _ready() -> void:
	hide()  # start hidden


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not get_tree().paused:
		toggle_menu()
	elif event.is_action_pressed("ui_cancel") and get_tree().paused:
		toggle_menu

func toggle_menu() -> void:
	is_open = !is_open

	if is_open:
		show()
		get_tree().paused = true
		
			
	else:
		hide()
		get_tree().paused = false
		
			

func close_menu() -> void:
	is_open = false
	hide()
	get_tree().paused = false



func _on_main_menu_pressed() -> void:
	close_menu()
	get_tree().paused = false
	SceneTransition.change_scene("res://Scenes/settings.tscn")


func _on_back_pressed() -> void:
	toggle_menu()


func _on_main_menu_2_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/main_menu.tscn")
