extends Node

# Signals
signal health_changed(current: float, max: float)
signal lives_changed(current: int)
signal coins_changed(current: int)
signal abilities_reset
# NEW: Ability unlock signal
signal ability_unlocked(ability_name: String)

# Player Stats 
var player_stats := {
	"max_health": 100.0,
	"health": 100.0,
	"attack": 1,
	"lives": 3,
	"coins": 0,
	"Projectile":2,
	"Slash":5
}
var Projectile := {
	"Projectile": 2
}

var Slash := {
	"Slash":5
}

var player_unlocks = {
	"spread_ability": false,
	"heal_ability": false,
	"slash_ability": false
}

# Enemy Stats 
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

# Lives 
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

func reset_stats():
	Stats.reset_all()

# --- Ability purchase / spread ability ---
func try_buy_spread():
	var cost := 15
	
	print("Trying to buy spread...")

	if player_unlocks["spread_ability"]:
		DialogueManager.show_dialogue_balloon(load("res://Dialogue/Shop.dialogue"), "already")
		print("Already owned.")
		return
	
	if player_stats["coins"] < cost:
		DialogueManager.show_dialogue_balloon(load("res://Dialogue/Shop.dialogue"), "notenough")
		print("Not enough coins.")
		return
	
	add_coins(-cost)
	player_unlocks["spread_ability"] = true
	
	# NEW: Notify HUD
	ability_unlocked.emit("spread_ability")
	
	DialogueManager.show_dialogue_balloon(load("res://Dialogue/Shop.dialogue"), "success")
	print("Spread ability unlocked!")

# --- Heal integration ---
func heal_player(amount: int = 25) -> void:
	if not player_unlocks["heal_ability"]:
		return

	player_stats["health"] += amount
	
	if player_stats["health"] > player_stats["max_health"]:
		player_stats["health"] = player_stats["max_health"]
	
	health_changed.emit(
		player_stats["health"],
		player_stats["max_health"]
	)

func try_buy_heal():
	var cost := 20
	
	print("Trying to buy heal...")

	if player_unlocks["heal_ability"]:
		DialogueManager.show_dialogue_balloon(load("res://Dialogue/Shop.dialogue"), "already")
		print("Heal already owned.")
		return
	
	if player_stats["coins"] < cost:
		DialogueManager.show_dialogue_balloon(load("res://Dialogue/Shop.dialogue"), "notenough")
		print("Not enough coins for heal.")
		return
	
	add_coins(-cost)
	player_unlocks["heal_ability"] = true
	
	# NEW: Notify HUD
	ability_unlocked.emit("heal_ability")
	
	DialogueManager.show_dialogue_balloon(load("res://Dialogue/Shop.dialogue"), "success")
	print("Heal ability unlocked!")

func open_shop_dialogue():
	DialogueManager.show_dialogue_balloon(
		load("res://Dialogue/Shop.dialogue"),
		"shop"
	)

func return_to_npc():
	DialogueManager.show_dialogue_balloon(
		load("res://Dialogue/npc1.dialogue"),
		"BeforeDoor"
	)

func return_to_npc_2():
	DialogueManager.show_dialogue_balloon(
		load("res://Dialogue/npc2.dialogue"),
		"BeforeDoor"
	)

# Resets all player abilities
func reset_abilities() -> void:
	for key in player_unlocks.keys():
		player_unlocks[key] = false
	print("All abilities have been reset.")
	abilities_reset.emit()
func reset_all() -> void:
	reset_abilities()
	reset_health()
	reset_lives()
	reset_coins()
	print("Player stats fully reset.")
