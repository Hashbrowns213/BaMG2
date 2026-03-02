extends CharacterBody2D

# =========================
# NEW: Cooldown Signals
# =========================
signal ability1_cooldown_started(duration)
signal ability2_cooldown_started(duration)
signal player_died
const SPEED := 200.0
const JUMP_VELOCITY := -320.0
const IFRAME_DURATION := 1.0
const RESPAWN_DELAY := 3.0
const ABILITY_COOLDOWN := 1.5

var current_interactable: Node = null
var is_healing := false
var is_attacking := false
var attack_index := 0
var is_hit := false
var is_dead := false
var is_using_ability := false
var can_use_ability := true
var i_frame_timer := 0.0

@export var ability_projectile_scene: PackedScene
@export var max_health := 100
var current_health := 100
@export var heal_amount := 25
@export var heal_cooldown := 5.0
var can_use_heal := true

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var Hitbox: Area2D = $Hitbox
@onready var hitboxbox: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var Hurtbox: Area2D = $Hurtbox
@onready var death_timer: Timer = Timer.new()
@onready var Interaction: Area2D = $Interactabledetector
@onready var spawn_point: Marker2D = $"../Spawnpoint"
@onready var ability_spawn: Marker2D = $AbilitySpawnPoint

func _ready() -> void:
	add_to_group("player")

	anim.animation_finished.connect(_on_animation_finished)
	Hurtbox.area_entered.connect(_on_hurtbox_area_entered)

	death_timer.wait_time = RESPAWN_DELAY
	death_timer.one_shot = true
	death_timer.timeout.connect(_on_respawn_timeout)
	add_child(death_timer)

	if Interaction:
		Interaction.area_entered.connect(_on_interaction_area_entered)
		Interaction.area_exited.connect(_on_interaction_area_exited)

	Stats.reset_health()


# --- Interaction ---
func _on_interaction_area_entered(area: Area2D) -> void:
	if area.is_in_group("interactable"):
		current_interactable = area

func _on_interaction_area_exited(area: Area2D) -> void:
	if area == current_interactable:
		current_interactable = null


# --- Movement ---
func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return

	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if i_frame_timer > 0:
		i_frame_timer -= delta

	if is_hit or is_using_ability or is_healing:
		velocity.x = 0
		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("Jump") and is_on_floor() and not is_attacking:
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("Ability1") and can_use_ability and not is_attacking and Stats.player_unlocks["spread_ability"]:
		_use_ability()

	if Input.is_action_just_pressed("Ability2") and can_use_heal and not is_attacking and not is_healing and Stats.player_unlocks["heal_ability"]:
		_use_heal()

	var direction := Input.get_axis("Run_Left", "Run_Right")
	if not is_attacking:
		hitboxbox.disabled = true
		velocity.x = direction * SPEED if direction != 0 else move_toward(velocity.x, 0, SPEED)

	if direction != 0:
		sprite.flip_h = direction < 0

	_update_hit_and_hurtbox_flip()
	move_and_slide()

	if Input.is_action_just_pressed("kys"):
		SceneTransition.change_scene("res://Scenes/boss_arena.tscn")
	if Input.is_action_just_pressed("Interact") and current_interactable:
		current_interactable.interact()

	if not is_attacking and not is_hit and not is_using_ability and not is_healing:
		anim.play(
			"Jump" if not is_on_floor() and velocity.y < 0 else
			"Fall" if not is_on_floor() else
			"Running" if direction != 0 else "Idle"
		)


func _process(_delta: float) -> void:
	if is_hit or is_dead or is_using_ability or is_healing:
		return

	if Input.is_action_just_pressed("attack"):
		if not is_attacking:
			is_attacking = true
			attack_index = 1
			velocity.x = 0
			anim.play("Attack1")
		elif attack_index == 1:
			attack_index = 2


# --- Ability ---
func _use_ability() -> void:
	is_using_ability = true
	can_use_ability = false
	is_attacking = false
	attack_index = 0
	hitboxbox.disabled = true
	velocity.x = 0
	anim.play("Ability")

	# NEW: Notify HUD cooldown started
	emit_signal("ability1_cooldown_started", ABILITY_COOLDOWN)


func _spawn_spread_projectiles() -> void:
	print("SPAWNING PROJECTILES")

	if not ability_projectile_scene:
		print("NO PROJECTILE SCENE")
		return

	var base_dir = Vector2.LEFT if sprite.flip_h else Vector2.RIGHT
	var angles = [-15, 0, 15]

	for angle in angles:
		var projectile = ability_projectile_scene.instantiate()
		get_tree().root.add_child(projectile)
		projectile.global_position = ability_spawn.global_position

		var rotated_dir = base_dir.rotated(deg_to_rad(angle))
		print("Angle:", angle)
		projectile.setup(rotated_dir)


# --- Heal ---
func _use_heal() -> void:
	if not can_use_heal or not Stats.player_unlocks["heal_ability"]:
		return

	is_healing = true
	can_use_heal = false
	is_attacking = false
	attack_index = 0
	hitboxbox.disabled = true
	velocity.x = 0
	anim.play("Heal")

	Stats.heal_player(heal_amount)

	# NEW: Notify HUD cooldown started
	emit_signal("ability2_cooldown_started", heal_cooldown)


# --- Animations ---
func _on_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"Attack1":
			if attack_index == 2:
				anim.play("Attack2")
			else:
				is_attacking = false
				attack_index = 0
		"Attack2":
			is_attacking = false
			attack_index = 0
		"Hit":
			is_hit = false
			is_attacking = false
			attack_index = 0
		"Ability":
			is_using_ability = false
			await get_tree().create_timer(ABILITY_COOLDOWN).timeout
			can_use_ability = true
		"Heal":
			is_healing = false
			await get_tree().create_timer(heal_cooldown).timeout
			can_use_heal = true
		"Death":
			death_timer.start()


# --- Combat ---
func _update_hit_and_hurtbox_flip() -> void:
	if sprite.flip_h:
		Hitbox.position.x = -38
		Hurtbox.position.x = -8
	else:
		Hitbox.position.x = 8
		Hurtbox.position.x = 8


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if is_dead or i_frame_timer > 0:
		return

	if area.is_in_group("enemy_hitbox"):
		i_frame_timer = IFRAME_DURATION
		is_attacking = false
		attack_index = 0
		is_hit = true
		hitboxbox.disabled = true
		anim.play("Hit")
		Stats.take_damage(Stats.enemy_stats["attack"])

		if Stats.player_stats["health"] <= 0:
			_die()


func _die() -> void:
	is_dead = true
	Hitbox.monitoring = false
	Hurtbox.monitoring = false
	Stats.lose_life()
	remove_from_group("player")

	# Play death animation
	anim.play("Death")

	if Stats.player_stats["lives"] > 0:
		death_timer.start()
	else:
		print("GAME OVER")
		Stats.player_stats["lives"] = 3
		Stats.reset_all()
		emit_signal("player_died")
		# Slow motion
		Engine.time_scale = 0.3

		# Wait for death animation to finish
		await anim.animation_finished

		# Restore normal time
		Engine.time_scale = 1.0

		# Show death UI
		UiB.show()

		# Emit signal to notify other systems (like BossUI)


# --- Respawn ---
func _on_respawn_timeout() -> void:
	Stats.reset_health()

	if spawn_point:
		global_position = spawn_point.global_position

	Hitbox.monitoring = true
	Hurtbox.monitoring = true
	add_to_group("player")

	is_dead = false
	is_hit = false
	is_attacking = false
	is_using_ability = false
	is_healing = false
	attack_index = 0
	can_use_ability = true
	can_use_heal = true
