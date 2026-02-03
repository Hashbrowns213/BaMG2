extends Node

# Signals
signal health_changed(current: float, max: float)
signal lives_changed(current: int)
signal coins_changed(current: int)

# Player Stats 
var player_stats := {
	"max_health": 100.0,
	"health": 100.0,
	"attack": 1,
	"lives": 3,
	"coins": 0
}

#  Enemy Stats 
var enemy_stats := {
	"attack": 25.0
}

# Health
func reset_health() -> void:
	player_stats["health"] = player_stats["max_health"]
	health_changed.emit(
		player_stats["health"],
		player_stats["max_health"]
	)

func take_damage(amount: float) -> void:
	player_stats["health"] = max(player_stats["health"] - amount, 0)
	health_changed.emit(
		player_stats["health"],
		player_stats["max_health"]
	)

#  Lives 
func lose_life() -> void:
	player_stats["lives"] = max(player_stats["lives"] - 1, 0)
	lives_changed.emit(player_stats["lives"])

func reset_lives() -> void:
	player_stats["lives"] = 3
	lives_changed.emit(player_stats["lives"])

# Coins 
func add_coins(amount: int) -> void:
	player_stats["coins"] += amount
	coins_changed.emit(player_stats["coins"])

func reset_coins() -> void:
	player_stats["coins"] = 0
	coins_changed.emit(player_stats["coins"])
