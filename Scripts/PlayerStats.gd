extends Node

signal health_changed(current: float, max: float)

var player_stats := {
	"max_health": 100.0,
	"health": 100.0,
	"attack": 1,
	"lives": 3
}

var enemy_stats := {
	"attack": 25.0
}

signal lives_changed(current: int)

func lose_life() -> void:
	player_stats["lives"] = max(player_stats["lives"] - 1, 0)
	emit_signal("lives_changed", player_stats["lives"])

	
func reset_health() -> void:
	player_stats["health"] = player_stats["max_health"]
	emit_signal("health_changed",
		player_stats["health"],
		player_stats["max_health"]
	)

func take_damage(amount: float) -> void:
	player_stats["health"] = max(player_stats["health"] - amount, 0)
	emit_signal("health_changed",
		player_stats["health"],
		player_stats["max_health"]
	)
