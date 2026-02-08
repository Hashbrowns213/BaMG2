extends CanvasLayer
@onready var fade: ColorRect = $ColorFade

var is_fading := false


func _ready():
	fade.modulate.a = 0.0   # start invisible


func fade_out(time := 0.4):
	if is_fading:
		return
	is_fading = true

	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, time)
	await tween.finished


func fade_in(time := 0.4):
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, time)
	await tween.finished
	is_fading = false


func change_scene(path: String):
	await fade_out()
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame   # wait one frame so scene loads
	await fade_in()
