extends CanvasLayer

@onready var label: Label = $WaveMessage


func _ready():
	print("Arena UI ready")
	label.visible = false


func show_message(msg: String):
	print("UI SHOW MESSAGE:", msg)

	label.text = msg
	label.visible = true

	await get_tree().create_timer(2.0).timeout

	label.visible = false
