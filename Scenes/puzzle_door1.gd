extends Area2D

@export var dialogue_resource: DialogueResource
@export var next_scene: String
@onready var anim: AnimatedSprite2D = $"../AnimatedSprite2D"

var solved := false

func interact(): 
	if solved:
		return

	# Show dialogue
	DialogueManager.show_dialogue_balloon(dialogue_resource, "Puzzle1")

	# Wait until dialogue ends
	await DialogueManager.dialogue_ended

	# Check if player answered correctly
	_check_result()


func _check_result():
	if State.door_correct1 == "True":
		_open_door()


func _open_door():
	if solved:
		return

	solved = true
	anim.play("Open")  # Now this should work because we reference the parent

	# Reset answer so it doesn't auto-trigger again
	State.door_correct1 = ""

	# Small delay before changing scene
	await get_tree().create_timer(2.0).timeout
	SceneTransition.change_scene("res://Scenes/arena2.tscn")
