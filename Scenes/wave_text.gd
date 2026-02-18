extends Label

func show_message(msg: String):
	arena.wave_warning.connect(show_warning_text)
	arena.wave_cleared.connect(show_cleared_text)
	text = msg
	visible = true

	await get_tree().create_timer(1.5).timeout
	visible = false
