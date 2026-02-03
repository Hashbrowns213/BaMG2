extends Node2D

@export var coin_value: int = 1

@onready var area: Area2D = $Area2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	area.area_entered.connect(_on_area_entered)

func _on_area_entered(other: Area2D) -> void:
	if other.is_in_group("player"):
		Stats.add_coins(coin_value)
		_play_collect_effect()

func _play_collect_effect() -> void:
	if anim_player.has_animation("collect"):
		anim_player.play("collect")
		anim_player.animation_finished.connect(queue_free)
	else:
		queue_free()
