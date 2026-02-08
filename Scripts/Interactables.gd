extends Area2D

@export var dialogue_resource: DialogueResource
@export var start_node := "start"

func _ready():
	get_tree().root.get_node("/root/DialogueManager")

func interact() -> void:
	# Check if a dialogue is already running
	


	DialogueManager.show_example_dialogue_balloon(dialogue_resource, start_node)
