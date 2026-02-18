extends CanvasLayer

@onready var talking: AudioStreamPlayer = $"Tradervfx(2)"


func _on_dialogue_label_spoke(letter: String, letter_index: int, speed: float) -> void:
	if not letter in ["."," "]:
		talking.pitch_scale = randf_range(0.9, 1.1)
		talking.volume_db = -12
		talking.play()
