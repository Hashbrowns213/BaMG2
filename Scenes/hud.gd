extends CanvasLayer

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var life_1: TextureRect = $"Lives/Life 1"
@onready var life_2: TextureRect = $"Lives/Life 2"
@onready var life_3: TextureRect = $"Lives/Life 3"
func _ready() -> void:
	Stats.health_changed.connect(_on_health_changed)
	Stats.lives_changed.connect(_on_lives_changed)

	# Force initial sync
	_on_health_changed(
		Stats.player_stats["health"],
		Stats.player_stats["max_health"]
	)
	_on_lives_changed(Stats.player_stats["lives"])


func _on_health_changed(current: float, max: float) -> void:
	health_bar.max_value = max
	health_bar.value = current



func _on_lives_changed(current_lives: int) -> void:
	life_1.visible = current_lives >= 3
	life_2.visible = current_lives >= 2
	life_3.visible = current_lives >= 1
