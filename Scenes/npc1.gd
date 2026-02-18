extends Node2D


@export var dialogue_resource: DialogueResource
@export var start_node := "start"

func interact() -> void:
	if DialogueManager.is_dialogue_running():
		return

	DialogueManager.start_dialogue(dialogue_resource, start_node)
