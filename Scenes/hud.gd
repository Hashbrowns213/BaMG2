extends CanvasLayer

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var life_1: TextureRect = $"Lives/Life 1"
@onready var life_2: TextureRect = $"Lives/Life 2"
@onready var life_3: TextureRect = $"Lives/Life 3"
@onready var CoinCounter: Label = %CoinLabel

@onready var spread_icon: TextureRect = $AbilityIcons/SpreadIcon
@onready var spread_cd: ColorRect = $AbilityIcons/SpreadIcon/Cooldown

@onready var heal_icon: TextureRect = $AbilityIcons/HealIcon
@onready var heal_cd: ColorRect = $AbilityIcons/HealIcon/Cooldown

var spread_cd_time := 0.0
var spread_cd_duration := 0.0

var heal_cd_time := 0.0
var heal_cd_duration := 0.0

var player_ref = null


func _ready() -> void:
	Stats.health_changed.connect(_on_health_changed)
	Stats.lives_changed.connect(_on_lives_changed)
	Stats.coins_changed.connect(_on_coins_changed)
	Stats.ability_unlocked.connect(_on_ability_unlocked)
	Stats.abilities_reset.connect(_on_abilities_reset) # ✅ NEW

	# FORCE correct visibility on start
	spread_icon.visible = Stats.player_unlocks["spread_ability"]
	heal_icon.visible = Stats.player_unlocks["heal_ability"]

	spread_cd.visible = false
	heal_cd.visible = false

	_connect_to_player()

	_on_health_changed(
		Stats.player_stats["health"],
		Stats.player_stats["max_health"]
	)
	_on_lives_changed(Stats.player_stats["lives"])
	_on_coins_changed(Stats.player_stats["coins"])


func _process(delta: float) -> void:
	if player_ref == null:
		_connect_to_player()

	_update_cooldown(delta)


# =========================
# PLAYER CONNECTION
# =========================
func _connect_to_player():
	var p = get_tree().get_first_node_in_group("player")
	if p and p != player_ref:
		player_ref = p
		player_ref.ability1_cooldown_started.connect(_start_spread_cd)
		player_ref.ability2_cooldown_started.connect(_start_heal_cd)


# =========================
# BASIC UI
# =========================
func _on_health_changed(current: float, max: float) -> void:
	health_bar.max_value = max
	health_bar.value = current

func _on_lives_changed(current_lives: int) -> void:
	life_1.visible = current_lives >= 3
	life_2.visible = current_lives >= 2
	life_3.visible = current_lives >= 1

func _on_coins_changed(amount: int) -> void:
	CoinCounter.text = str(amount)


# =========================
# ABILITY UNLOCK
# =========================
func _on_ability_unlocked(ability_name: String) -> void:
	if ability_name == "spread_ability":
		spread_icon.visible = true
	elif ability_name == "heal_ability":
		heal_icon.visible = true


# =========================
# ✅ ABILITY RESET FIX
# =========================
func _on_abilities_reset() -> void:
	spread_icon.visible = false
	heal_icon.visible = false

	# Reset cooldown visuals too
	spread_cd.visible = false
	heal_cd.visible = false
	spread_cd_time = 0
	heal_cd_time = 0


# =========================
# COOLDOWN START
# =========================
func _start_spread_cd(duration: float) -> void:
	spread_cd_duration = duration
	spread_cd_time = duration
	spread_cd.visible = true
	spread_cd.size.y = spread_icon.size.y

func _start_heal_cd(duration: float) -> void:
	heal_cd_duration = duration
	heal_cd_time = duration
	heal_cd.visible = true
	heal_cd.size.y = heal_icon.size.y


# =========================
# COOLDOWN UPDATE
# =========================
func _update_cooldown(delta: float) -> void:

	if spread_cd_time > 0:
		spread_cd_time -= delta
		var ratio = spread_cd_time / spread_cd_duration
		spread_cd.size.y = spread_icon.size.y * ratio
		if spread_cd_time <= 0:
			spread_cd.visible = false

	if heal_cd_time > 0:
		heal_cd_time -= delta
		var ratio2 = heal_cd_time / heal_cd_duration
		heal_cd.size.y = heal_icon.size.y * ratio2
		if heal_cd_time <= 0:
			heal_cd.visible = false
